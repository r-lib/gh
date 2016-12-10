#' Info on current GitHub user and token
#'
#' Reports wallet name, GitHub login, and GitHub URL for the current
#' authenticated user, the first bit of the token, and the associated scopes.

#'
#' Get a personal access token for the GitHub API from
#' \url{https://github.com/settings/tokens} and select the scopes necessary for
#' your planned tasks. The \code{repo} scope, for example, is one many are
#' likely to need. The token itself is a string of 40 letters and digits. You
#' can store it any way you like and provide explicitly via the \code{.token}
#' argument to \code{\link{gh}()}.
#'
#' However, many prefer to define an environment variable \code{GITHUB_PAT} (or
#' \code{GITHUB_TOKEN}) with this value in their \code{.Renviron} file. Add a
#' line that looks like this, substituting your PAT:
#'
#' \preformatted{
#' GITHUB_PAT=8c70fd8419398999c9ac5bacf3192882193cadf2
#' }
#'
#' Put a line break at the end! If you’re using an editor that shows line
#' numbers, there should be (at least) two lines, where the second one is empty.
#' Restart R for this to take effect. Call \code{gh_whoami()} to confirm
#' success.
#'
#' To get complete information on the authenticated user, call
#' \code{gh("/user")}.
#'
#' For token management via API (versus the browser), use the
#' \href{https://developer.github.com/v3/oauth_authorizations/}{OAuth
#' Authorizations API}. This API requires Basic Authentication using your
#' username and password, not tokens, and is outside the scope of the \code{gh}
#' package.
#'
#' @inheritParams gh
#'
#' @return A \code{gh_response} object, which is also a \code{list}.
#' @export
#'
#' @examples
#' \dontrun{
#' gh_whoami()
#'
#' ## explicit token + use with GitHub Enterprise
#' gh_whoami(.token = "8c70fd8419398999c9ac5bacf3192882193cadf2",
#'           .api_url = "https://github.foobar.edu/api/v3")
#' }
gh_whoami <- function(.token = NULL, .api_url = NULL, .send_headers = NULL) {
  .token <- .token %||% gh_token()
  if (isTRUE(.token == "")) {
    message("No personal access token (PAT) available.\n",
            "Obtain a PAT from here:\n",
            "https://github.com/settings/tokens\n",
            "For more on what to do with the PAT, see ?gh_whoami.")
    return(invisible(NULL))
  }
  res <- gh(endpoint = "/user", .token = .token,
            .api_url = .api_url, .send_headers = .send_headers)
  scopes <- attr(res, "response")[["x-oauth-scopes"]]
  res <- res[c("name", "login", "html_url")]
  res$scopes <- scopes
  res$token <- obfuscate(.token)
  ## 'gh_response' class has to be restored
  class(res) <- c("gh_response", "list")
  res
}

obfuscate <- function(x, first = 2, last = 0) {
  paste0(substr(x, start = 1, stop = first),
         "...",
         substr(x, start = nchar(x) - last + 1, stop = nchar(x)))
}
