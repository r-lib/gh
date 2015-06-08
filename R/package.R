
function() {

  gh <- function(...) lazyeval::lazy_dots(...)

  ## Design ideas:

  ## The first idea is just to list the pieces of the API URL as
  ## seperate arguments:

  gh("user/repos")
  gh("user", "repos")
  gh("users", "gaborcsardi", "repos")
  gh("orgs", "igraph", "repos")
  gh("repositories")

  ## For non-GET operations, we can specify the operation explicitly

  gh("POST", "user", "repos")
  gh("POST", "orgs", "igraph", "repos")

  ## Not too bad, but it does feel a bit clumsy.

  gh(user/repos)
  gh(users/gaborcsardi/repos)
  user <- "gaborcsardi"
  gh(users/(user)/repos)

  gh(POST/user/repos)
  gh(POST/orgs/igraph/repos)
  org <- "igraph"
  gh(POST/orgs/(org)/repos)

  ## Well, this is much better, but involves a lot of NSE. :/
  ## Alternative:

  gh("user/repos")
  gh("user/gaborcsardi/repos")
  gh("users"/user/"repos")

  gh("POST/user/repos")
  gh("POST/orgs"/igraph/"repos")

  ## This could be done with less (or maybe no) NSE,
  ## but it looks somewhat confusing.

}

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

api <- list(GET = list(), POST = list())

api$GET$`user/repos` <- list(
  path = "/user/repos",
  parameters = list(
    type = list(
      type = "string",
      desc = "Can be one of all, owner, public, private, member. Default: all"
    ),
    sort = list(
      type = "string",
      desc = "Can be one of created, updated, pushed, full_name. Default: full_name"
    ),
    direction = list(
      type = "string",
      desc = "Can be one of asc or desc. Default: when using full_name: asc; otherwise desc"
    )
  )
)

#' Query the GitHub API
#'
#' TODO
#'
#' @param end_point GitHub API end point. See examples below.
#' @param ... Additional parameters
#' @param .token Authentication token.
#' @return Answer from the API.
#'
#' @importFrom httr VERB stop_for_status content add_headers
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

gh <- function(end_point, ..., .token = Sys.getenv('GITHUB_TOKEN')) {
  end_point <- parse_end_point(end_point, env = parent.frame())
  params <- list(...)

  auth <- character()
  if (.token != "") auth <- c("Authorization" = paste("token", .token))

  url <- paste0(api_url, paste(end_point$end_point, collapse = "/"))

  response <- VERB(
    verb = end_point$method,
    url = url,
    add_headers(.headers = c(send_headers, auth))
  )

  stop_for_status(response)

  res <- fromJSON(content(response, as = "text"), simplifyVector = FALSE)
  class(res) <- "gh_response"
  res
}
