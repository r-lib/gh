#' A simple interface for the GitHub GraphQL API v4.
#'
#' See more about the GraphQL API here:
#' <https://docs.github.com/graphql>
#'
#' Note: pagination and the `.limit` argument does not work currently,
#' as pagination in the GraphQL API is different from the v3 API.
#' If you need pagination with GraphQL, you'll need to do that manually.
#'
#' @inheritParams gh
#' @param query The GraphQL query, as a string.
#' @export
#' @seealso [gh()] for the GitHub v3 API.
#' @examplesIf FALSE
#' gh_gql("query { viewer { login }}")
#'
#' # Get rate limit
#' ratelimit_query <- "query {
#'   viewer {
#'     login
#'   }
#'   rateLimit {
#'     limit
#'     cost
#'     remaining
#'     resetAt
#'   }
#' }"
#'
#' gh_gql(ratelimit_query)
gh_gql <- function(query, ...) {
  if (".limit" %in% names(list(...))) {
    stop("`.limit` does not work with the GraphQL API")
  }

  gh(endpoint = "POST /graphql", query = query, ...)
}
