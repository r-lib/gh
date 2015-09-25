
#' GitHub API
#'
#' Minimal wrapper to access GitHub's API.
#'
#' @docType package
#' @name gh
NULL

## Main API URL

api_url <- "https://api.github.com"

## Headers to send with each API request

send_headers <- c("accept" = "application/vnd.github.v3+json",
                  "user-agent" = "https://github.com/gaborcsardi/whoami")

#' Query the GitHub API
#'
#' This is an extremely minimal client. You need to know the API
#' to be able to use this client. All this function does is
#' \itemize{
#'   \item Tries to substitute each listed parameter into
#'     \code{endpoint}, using the \code{:parameter} notation.
#'   \item If a GET request (the default), then adds
#'     all other listed parameters as query parameters.
#'   \item If not a GET request, then sends the other parameters
#'     in the request body, as JSON.
#'   \item Converts the response to an R list using
#'     \code{jsonline::fromJSON}.
#' }
#'
#' @param endpoint GitHub API endpoint. See examples below.
#' @param ... Additional parameters
#' @param .token Authentication token.
#' @param .limit Number of records to return. This can be used
#'   instead of manual pagination. By default it is \code{NULL},
#'   which means that the defaults of the GitHub API are used.
#'   You can set it to a number to request more (or less)
#'   records, and also to \code{Inf} to request all records.
#'   Note, that if you request many records, then multiple GitHub
#'   API calls are used to get them, and this can take a potentially
#'   long time.
#' @return Answer from the API.
#'
#' @importFrom httr content add_headers headers
#'   status_code GET POST PATCH PUT DELETE
#' @importFrom jsonlite fromJSON toJSON
#' @export
#' @examples
#' \dontrun{
#' ## Repositories of a user, these are equivalent
#' gh("/users/hadley/repos")
#' gh("/users/:username/repos", username = "hadley")
#'
#' ## Create a repository, needs a token in GITHUB_TOKEN
#' ## environment variable
#' gh("POST /user/repos", name = "foobar")
#'
#' ## Issues of a repository
#' gh("/repos/hadley/dplyr/issues")
#' gh("/repos/:owner/:repo/issues", owner = "hadley", repo = "dplyr")
#'
#' ## Automatic pagination
#' users <- gh("/users", .limit = 50)
#' length(users)
#' }

gh <- function(endpoint, ..., .token = Sys.getenv('GITHUB_TOKEN'),
               .limit = NULL) {

  params <- list(...)

  parsed <- parse_endpoint(endpoint, params)
  method <- parsed$method
  endpoint <- parsed$endpoint
  params <- parsed$params

  auth <- get_auth(.token)

  url <- paste0(api_url, endpoint)

  res <- gh_url(method, url, auth, params)

  while (! is.null(.limit) && length(res) < .limit && gh_has_next(res)) {
    res2 <- gh_next(res, .token = .token)
    res3 <- c(res, res2)
    attributes(res3) <- attributes(res2)
    res <- res3
  }

  res
}


get_auth <- function(token) {
  auth <- character()
  if (token != "") auth <- c("Authorization" = paste("token", token))
  auth
}


gh_url <- function(method, url, auth, params) {

  method_fun <- list("GET" = GET, "POST" = POST, "PATCH" = PATCH,
                     "PUT" = PUT, "DELETE" = DELETE)[[method]]

  if (is.null(method_fun)) stop("Unknown HTTP verb")

  ## GET ignores parameters within `url`, if `query` is specified,
  ## so we separate out the case when `query = params` is empty.

  if (method == "GET" && length(params) > 0) {
    response <- GET(
      url = url,
      add_headers(.headers = c(send_headers, auth)),
      query = params
    )
  } else if (method == "GET") {
    response <- GET(
      url = url,
      add_headers(.headers = c(send_headers, auth))
    )
  } else {
    response <- method_fun(
      url = url,
      add_headers(.headers = c(send_headers, auth)),
      body = toJSON(params, auto_unbox = TRUE)
    )
  }

  heads <- headers(response)

  if (grepl("^application/json", heads$`content-type`,
            ignore.case = TRUE)) {
    res <- fromJSON(content(response, as = "text"), simplifyVector = FALSE)
  } else {
    res <- content(response, as = "text")
  }

  if (status_code(response) >= 300) {
    cond <- structure(list(
      call = sys.call(-1),
      content = res,
      headers = heads,
      message = paste("GitHub API error", heads$`status`)
    ), class = c("condition", "error"))
    stop(cond)
  }

  attr(res, "method") <- method
  attr(res, "response") <- headers(response)
  class(res) <- "gh_response"
  res
}
