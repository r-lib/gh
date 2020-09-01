#' Info on current GitHub user and token
#'
#' Reports wallet name, GitHub login, and GitHub URL for the current
#' authenticated user, the first bit of the token, and the associated scopes.

#'
#' Get a personal access token for the GitHub API from
#' <https://github.com/settings/tokens> and select the scopes necessary for
#' your planned tasks. The `repo` scope, for example, is one many are
#' likely to need. The token itself is a string of 40 letters and digits. You
#' can store it any way you like and provide explicitly via the `.token`
#' argument to [gh()].
#'
#' However, many prefer to define an environment variable `GITHUB_PAT` (or
#' `GITHUB_TOKEN`) with this value in their `.Renviron` file. Add a
#' line that looks like this, substituting your PAT:
#'
#' ```
#' GITHUB_PAT=8c70fd8419398999c9ac5bacf3192882193cadf2
#' ```
#'
#' Put a line break at the end! If you're using an editor that shows line
#' numbers, there should be (at least) two lines, where the second one is empty.
#' Restart R for this to take effect. Call `gh_whoami()` to confirm
#' success.
#'
#' To get complete information on the authenticated user, call
#' `gh("/user")`.
#'
#' For token management via API (versus the browser), use the
#' [OAuth Authorizations API](https://docs.github.com/v3/oauth_authorizations/).
#' This API requires Basic Authentication using your username and password,
#' not tokens, and is outside the scope of the gh package.
#'
#' @inheritParams gh
#'
#' @return A `gh_response` object, which is also a `list`.
#' @export
#'
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' gh_whoami()
#'
#' @examplesIf FALSE
#' ## explicit token + use with GitHub Enterprise
#' gh_whoami(.token = "8c70fd8419398999c9ac5bacf3192882193cadf2",
#'           .api_url = "https://github.foobar.edu/api/v3")

gh_whoami <- function(.token = NULL, .api_url = NULL, .send_headers = NULL) {
  .token <- .token %||% gh_token(.api_url)
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
  res$token <- format(gh_pat(.token))
  ## 'gh_response' class has to be restored
  class(res) <- c("gh_response", "list")
  res
}
