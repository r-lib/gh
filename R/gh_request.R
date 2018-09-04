## Main API URL
default_github_url <- "https://github.com"
default_api_url <- "https://api.github.com"

## Headers to send with each API request
default_send_headers <- c("Accept" = "application/vnd.github.v3+json",
                          "User-Agent" = "https://github.com/r-lib/gh")

gh_build_request <- function(endpoint = "/user", params = list(),
                             token = NULL, destfile = NULL, overwrite = NULL,
                             send_headers = NULL,
                             api_url = NULL, method = "GET") {

  working <- list(method = method, url = character(), headers = NULL,
                  query = NULL, body = NULL,
                  endpoint = endpoint, params = params,
                  token = token, send_headers = send_headers, api_url = api_url,
                  dest = destfile, overwrite = overwrite)

  working <- gh_set_verb(working)
  working <- gh_set_endpoint(working)
  working <- gh_set_query(working)
  working <- gh_set_body(working)
  working <- gh_set_headers(working)
  working <- gh_set_url(working)
  working <- gh_set_dest(working)
  working[c("method", "url", "headers", "query", "body", "dest")]

}


## gh_set_*(x)
## x = a list in which we build up an httr request
## x goes in, x comes out, possibly modified

gh_set_verb <- function(x) {
  if (!nzchar(x$endpoint)) return(x)

  # No method defined, so use default
  if (grepl("^/", x$endpoint) || grepl("^http", x$endpoint)) {
    return(x)
  }

  x$method <- gsub("^([^/ ]+)\\s+.*$", "\\1", x$endpoint)
  stopifnot(x$method %in% c("GET", "POST", "PATCH", "PUT", "DELETE"))
  x$endpoint <- gsub("^[A-Z]+ ", "", x$endpoint)
  x
}

gh_set_endpoint <- function(x) {
  params <- x$params
  if (!grepl(":", x$endpoint) || length(params) == 0L || has_no_names(params)) {
    return(x)
  }

  named_params <- which(has_name(params))
  done <- rep_len(FALSE, length(params))
  endpoint <- endpoint2 <- x$endpoint

  for (i in named_params) {
    n <- names(params)[i]
    p <- params[[i]][1]
    endpoint2 <- gsub(paste0(":", n, "\\b"), p, endpoint)
    if (endpoint2 != endpoint) {
      endpoint <- endpoint2
      done[i] <- TRUE
    }
  }

  x$endpoint <- endpoint
  x$params <- x$params[!done]
  x$params <- cleanse_names(x$params)
  x

}

gh_set_query <- function(x) {
  params <- x$params
  if (x$method != "GET" || length(params) == 0L) {
    return(x)
  }
  stopifnot(all(has_name(params)))
  x$query <- params
  x$params <- NULL
  x
}

gh_set_body <- function(x) {
  if (length(x$params) == 0L) return(x)
  if (x$method == "GET") {
    warning("This is a 'GET' request and unnamed parameters are being ignored.")
    return(x)
  }
  x$body <- toJSON(x$params, auto_unbox = TRUE)
  x
}

gh_set_headers <- function(x) {
  auth <- gh_auth(x$token %||% gh_token())
  send_headers <- gh_send_headers(x$send_headers)
  x$headers <- c(send_headers, auth)
  x
}

gh_set_url <- function(x) {
  if (grepl("^https?://", x$endpoint)) {
    x$url <- URLencode(x$endpoint)
  } else {
    api_url <- x$api_url %||% Sys.getenv('GITHUB_API_URL', unset = default_api_url)
    x$url <- URLencode(paste0(api_url, x$endpoint))
  }

  x
}

#' @importFrom httr write_disk write_memory
gh_set_dest <- function(x) {
  if (is.null(x$dest)) {
    x$dest <- write_memory()
  } else {
    x$dest <- write_disk(x$dest, overwrite = x$overwrite)
  }
  x
}

## functions to retrieve request elements
## possibly consult an env var or combine with a built-in default

#' Return the local user's GitHub Personal Access Token (PAT)
#'
#' You can read more about PATs here:
#' <https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/>
#' and you can access your PATs here (if logged in to GitHub):
#' <https://github.com/settings/tokens>.
#'
#' Currently it consults the `GITHUB_PAT` and `GITHUB_TOKEN`
#' environment variables, in this order. If none of these are set and
#' the session is interactive, [gh_interactive_oauth_token()] is invoked
#' to obtain an oauth token interactively.
#'
#' @return A string, with the token, or a zero length string scalar,
#' if no token is available.
#'
#' @export
gh_token <- function() {
  token <- Sys.getenv('GITHUB_PAT', "")
  if (token == "") token <- Sys.getenv("GITHUB_TOKEN", "")
  if (token == "" && interactive()) {
    gh_interactive_oauth_token()$credentials$access_token
  } else {
    token
  }
}

#' Obtain a Github OAuth Token Interactively
#'
#' Under an interactive R session, this opens the browser and acquires an OAuth
#' token interactively. This provides a simplified authorization experience than
#' manually creating PAT and setting the environment variable.
#'
#' If `client_id` and `client_secret` are not provided, a default pair is used
#' for github.com. Refer to [Github documentation](https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/)
#' on how to create your own application. The callback URL shall be the value of
#' [httr::oauth_callback()], namely, `http://localhost:1410/`.
#'
#' This can be useful for Github Enterprise installation where an internal
#' R package can create a Github application such that users may obtain authroization
#' tokens interactively. The package may further wrap this token in helper functions
#' such as streamlining internal `install_github` usage. See examples section for more details.
#'
#' @param client_id The client ID you received from GitHub when you
#' [registered](https://github.com/settings/applications/new) your Github app.
#' @param client_secret The client secret you received from GitHub for your GitHub App.
#' @param github_url The base url of Github or Github Enterprise.
#' @return An [httr::oauth2.0_token()]
#'
#' @references [http://developer.github.com/guides/basics-of-authentication/]
#' @importFrom httr modify_url oauth_endpoint oauth2.0_token oauth_app
#' @export
#' @examples
#' \dontrun{
#' # obtain an OAuth token with GHE
#' token <- withr::with_options(
#'   # share GHE OAuth token across projects
#'   httr_oauth_cache = "~/.httr_oauth_ghe",
#'   gh_interactive_oauth_token("{client_id}", "{client_secret}", "{ghe_host}")
#' )
#' # use obtained OAuth token temporarily
#' withr::with_envvar(
#'   GITHUB_PAT = token$credentials$access_token,
#'   gh_whoami()
#' )
#' # wrap it to create custom install_github function
#' install_github <- function(...) {
#'   devtools::install_github(host = "{ghe_api}", auth_token = token$credentials$access_token, ...)
#' }
#' }
gh_interactive_oauth_token <- function(client_id, client_secret, github_url) {
  if (!interactive()) {
    stop("OAuth cannot proceed under a non-interactive session!")
  }
  if (missing(client_id) && missing(client_secret)) {
    # TODO: replace with r-lib id and oauth secret
    client_id <- "1ce1de9d27bd86ce924d"
    client_secret <- "67f526618a826e6149ce00b4a07bc4c2aca90df1"
  }
  if (missing(github_url)) {
    github_url <- Sys.getenv('GITHUB_URL', unset = default_github_url)
  }
  base_url <- modify_url(github_url, path = "login/oauth")
  github <- oauth_endpoint(NULL, "authorize", "access_token", base_url = base_url)
  app <- oauth_app("github", client_id, client_secret)
  oauth2.0_token(github, app, as_header=FALSE)
}

gh_auth <- function(token) {
  if (isTRUE(token != "")) {
    c("Authorization" = paste("token", token))
  } else {
    character()
  }
}

gh_send_headers <- function(headers = NULL) {
  modify_vector(default_send_headers, headers)
}
