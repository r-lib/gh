## Main API URL
default_api_url <- function() {
  Sys.getenv('GITHUB_API_URL', unset = "https://api.github.com")
}

## Headers to send with each API request
default_send_headers <- c("User-Agent" = "https://github.com/r-lib/gh")

gh_build_request <- function(endpoint = "/user", params = list(),
                             token = NULL, destfile = NULL, overwrite = NULL,
                             accept = NULL, send_headers = NULL,
                             api_url = NULL, method = "GET") {

  working <- list(method = method, url = character(), headers = NULL,
                  query = NULL, body = NULL,
                  endpoint = endpoint, params = params,
                  token = token, accept = c(Accept = accept),
                  send_headers = send_headers, api_url = api_url,
                  dest = destfile, overwrite = overwrite)

  working <- gh_set_verb(working)
  working <- gh_set_endpoint(working)
  working <- gh_set_query(working)
  working <- gh_set_body(working)
  working <- gh_set_url(working)
  working <- gh_set_headers(working)
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
  if (length(x$params) == 1 && is.raw(x$params[[1]])) {
    x$body <- x$params[[1]]
  } else {
    x$body <- toJSON(x$params, auto_unbox = TRUE)
  }
  x
}

gh_set_headers <- function(x) {
  # x$api_url must be set properly at this point
  auth <- gh_auth(x$token %||% gh_token(x$api_url))
  send_headers <- gh_send_headers(x$accept, x$send_headers)
  x$headers <- c(send_headers, auth)
  x
}

gh_set_url <- function(x) {
  if (grepl("^https?://", x$endpoint)) {
    x$url <- URLencode(x$endpoint)
    x$api_url <- get_baseurl(x$url)
  } else {
    x$api_url <- x$api_url %||% default_api_url()
    x$url <- URLencode(paste0(x$api_url, x$endpoint))
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

gh_send_headers <- function(accept_header = NULL, headers = NULL) {
  modify_vector(
    modify_vector(default_send_headers, accept_header),
    headers
  )
}
