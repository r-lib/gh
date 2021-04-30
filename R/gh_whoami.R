#' Info on current GitHub user and token
#'
#' Reports wallet name, GitHub login, and GitHub URL for the current
#' authenticated user, the first bit of the token, and the associated scopes.
#'
#' Get a personal access token for the GitHub API from
#' <https://github.com/settings/tokens> and select the scopes necessary for your
#' planned tasks. The `repo` scope, for example, is one many are likely to need.
#'
#' On macOS and Windows it is best to store the token in the git credential
#' store, where most GitHub clients, including gh, can access it. You can
#' use the gitcreds package to add your token to the credential store:
#'
#' ```r
#' gitcreds::gitcreds_set()
#' ```
#'
#' See <https://gh.r-lib.org/articles/managing-personal-access-tokens.html>
#' and <https://usethis.r-lib.org/articles/articles/git-credentials.html>
#' for more about managing GitHub (and generic git) credentials.
#'
#' On other systems, including Linux, the git credential store is
#' typically not as convenient, and you might want to store your token in
#' the `GITHUB_PAT` environment variable, which you can set in your
#' `.Renviron` file.
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
