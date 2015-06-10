
#' GitHub API
#'
#' Minimal wrapper to access GitHub's API.
#'
#' @docType package
#' @name gh
NULL

## Main API URL

api_url <- "https://api.github.com/"

## Headers to send with each API request

send_headers <- c("accept" = "application/vnd.github.v3+json",
                  "user-agent" = "https://github.com/gaborcsardi/whoami")

#' Query the GitHub API
#'
#' TODO
#'
#' @param end_point GitHub API end point. See examples below.
#' @param ... Additional parameters
#' @param .token Authentication token.
#' @return Answer from the API.
#'
#' @importFrom httr VERB stop_for_status content add_headers headers
#'   status_code
#' @importFrom jsonlite fromJSON
#' @export
#' @examples
#' \dontrun{
#' ## Repositories of a user
#' gh(users/hadley/repos)
#'
#' ## Issues of a repository
#' gh(repos/hadley/dplyr/issues)
#'
#' ## Using variables in the end point, just put them in a paren
#' myuser <- "gaborcsardi"
#' gh(users/(myuser)/repos)
#' }

gh <- function(end_point, ...){
  end_point <- parse_end_point(end_point, env = parent.frame())
  do.call(gh_, c(end_point$method, end_point$end_point, list(...)))
}

#' @export

gh_ <- function(..., .token = Sys.getenv('GITHUB_TOKEN')) {

  args <- list(...)
  method <- "GET"
  if (args[[1]] %in% github_verbs) {
    method <- args[[1]]
    args <- args[-1]
  }

  if (is.null(names(args))) {
    end_point <- unlist(args)
    params <- list()
  } else {
    end_point <- unlist(args[names(args) == ""])
    params <- args[names(args) != ""]
  }

  auth <- character()
  if (.token != "") auth <- c("Authorization" = paste("token", .token))

  url <- paste0(api_url, paste(end_point, collapse = "/"))

  response <- VERB(
    verb = method,
    url = url,
    add_headers(.headers = c(send_headers, auth))
  )

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
