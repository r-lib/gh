#' @describeIn gh A simple interface for the GitHub GraphQL API v4.
#' @param query The GraphQL query, as a string.
#' @export
#' @examples
#' \dontrun{
#' gh_gql("query { viewer { login }}")
#' }
gh_gql <- function(query, ..., .token = NULL, .destfile = NULL,
  .overwrite = FALSE, .api_url = NULL, .limit = NULL, .send_headers = NULL) {

  gh(endpoint = "POST /graphql", query = query, ..., .token = .token)
}
