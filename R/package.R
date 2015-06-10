
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
#'     \code{end_point}, using the \code{:parameter} notation.
#'   \item If a GET request (the default), then adds
#'     all other listed parameters as query parameters.
#'   \item If not a GET request, then sends the other parameters
#'     in the request body, as JSON.
#'   \item Converts the response to an R list using
#'     \code{jsonline::fromJSON}.
#' }
#'
#' @param end_point GitHub API end point. See examples below.
#' @param ... Additional parameters
#' @param .token Authentication token.
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
#' ## Create a repository
#' gh("POST /user/repos", name = "foobar")
#'
#' ## Issues of a repository
#' gh("/repos/hadley/dplyr/issues")
#' gh("/repos/:owner/:repo/issues", owner = "hadley", repo = "dplyr")
#' }

gh <- function(end_point, ..., .token = Sys.getenv('GITHUB_TOKEN')) {

  params <- list(...)

  parsed <- parse_end_point(end_point, params)
  method <- parsed$method
  end_point <- parsed$end_point
  params <- parsed$params

  method_fun <- list("GET" = GET, "POST" = POST, "PATCH" = PATCH,
                     "PUT" = PUT, "DELETE" = DELETE)[[method]]

  if (is.null(method_fun)) stop("Unknown HTTP verb")

  auth <- character()
  if (.token != "") auth <- c("Authorization" = paste("token", .token))

  url <- paste0(api_url, end_point)

  if (method == "GET") {
    response <- GET(
      url = url,
      add_headers(.headers = c(send_headers, auth)),
      query = params
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
      content = res,
      headers = heads,
      message = "GitHub API error"
    ), class = "condition")
    stop(cond)
  }

  attr(res, "response") <- headers(response)
  class(res) <- "gh_response"
  res
}
