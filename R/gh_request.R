## Main API URL
default_api_url <- "https://api.github.com"

## Headers to send with each API request
default_send_headers <- c("Accept" = "application/vnd.github.v3+json",
                          "User-Agent" = "https://github.com/r-lib/gh")

gh_build_request <- function(endpoint = "/user", params = list(),
                             token = NULL, send_headers = NULL,
                             api_url = NULL, method = "GET") {

  working <- list(method = method, url = character(), headers = NULL,
                  query = NULL, body = NULL,
                  endpoint = endpoint, params = params,
                  token = token, send_headers = send_headers, api_url = api_url)

  working <- gh_set_verb(working)
  working <- gh_set_endpoint(working)
  working <- gh_set_query(working)
  working <- gh_set_body(working)
  working <- gh_set_headers(working)
  working <- gh_set_url(working)
  working[c("method", "url", "headers", "query", "body")]

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

## functions to retrieve request elements
## possibly consult an env var or combine with a built-in default

gh_token <- function() {
  token <- Sys.getenv('GITHUB_PAT', "")
  if (token == "") Sys.getenv("GITHUB_TOKEN", "") else token
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
