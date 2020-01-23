
#' Return the local user's GitHub Personal Access Token (PAT)
#'
#' You can read more about PATs here:
#' <https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/>
#' and you can access your PATs here (if logged in to GitHub):
#' <https://github.com/settings/tokens>.
#'
#' Set the `GITHUB_PAT` environment variable to avoid having to include
#' your PAT in the code. If you work with multiple GitHub deployments,
#' e.g. via GitHub Enterprise, then read on.
#'
#' @section: PATs for multiple GitHub deployments:
#'
#' gh lets you use different PATs for different GitHub API URLs, by looking
#' for the PAT in an URL specific environment variable first. It uses
#' [slugify_url()] to compute a suffix from the API URL, by extracting the
#' host name and removing the protocol and the path from it, and replacing
#' special characters with underscores. This suffix is added to
#' `GITHUB_PAT_` then. For example for the default API URL:
#' <https://api.github.com>, the `GITHUB_PAT_API_GITHUB_COM` environment
#' variable is consulted first.
#'
#' If the API URL specific environment variable is not set, then gh falls
#' back to `GITHUB_PAT` and then to `GITHUB_TOKEN'.
#'
#' @param api_url Github API url. Defaults to `GITHUB_API_URL`
#' environment variable if set, otherwise <https://api.github.com>.
#'
#' @return A string, with the token, or a zero length string scalar,
#' if no token is available.
#'
#' @seealso [slugify_url()] for computing the environment variables that
#' gh uses to search for API URL specific PATs.
#' @export

gh_token <- function(api_url = NULL) {
  api_url <- api_url %||% default_api_url()
  token_env_var <- paste0("GITHUB_PAT_", slugify_url(api_url))
  Sys.getenv(
    token_env_var,
    Sys.getenv(
      "GITHUB_PAT",
      Sys.getenv("GITHUB_TOKEN")
    )
  )
}

gh_auth <- function(token) {
  if (isTRUE(token != "")) {
    c("Authorization" = paste("token", token))
  } else {
    character()
  }
}

#' Compute the suffix that gh uses for GitHub API URL specific PATs
#'
#' @param url Character vector HTTP/HTTPS URLs.
#' @return Character vector of suffixes.
#'
#' @seealso [gh_token()]
#' @export
#' @examples
#' # The main GH site
#' slugify_url("https://api.github.com")
#'
#' # A custom one
#' slugify_url("https://github.acme.com")

slugify_url <- function(url) {
  if (!any(grepl("^https?://", url))) {
    stop("Only works with HTTP(S) protocols")
  }
  x2 <- sub("^.*://([^/]*@)?", "", url)
  x3 <- sub("/+$", "", x2)
  x4 <- gsub("[./]+", "_", x3)
  x5 <- gsub("[^-a-zA-Z0-9_]", "", x4)
  toupper(x5)
}

get_baseurl <- function(x) {
  if (!any(grepl("^https?://", x))) stop("Only works with HTTP(S) protocols")
  prot <- sub("^(https?://).*$", "\\1", x)
  rest <- sub("^https?://(.*)$", "\\1", x)
  host <- sub("/.*$", "", rest)
  paste0(prot, host)
}
