#' Return the local user's GitHub Personal Access Token (PAT)
#'
#' @description
#' If gh can find a personal access token (PAT) via `gh_token()`, it includes
#' the PAT in its requests. Some requests succeed without a PAT, but many
#' require a PAT to prove the request is authorized by a specific GitHub user. A
#' PAT also helps with rate limiting. If your gh use is more than casual, you
#' want a PAT.
#'
#' gh calls [gitcreds::gitcreds_get()] with the `api_url`, which checks session
#' environment variables and then the local Git credential store for a PAT
#' appropriate to the `api_url`. Therefore, if you have previously used a PAT
#' with, e.g., command line Git, gh may retrieve and re-use it. You can call
#' [gitcreds::gitcreds_get()] directly, yourself, if you want to see what is
#' found for a specific URL. If no matching PAT is found,
#' [gitcreds::gitcreds_get()] errors, whereas `gh_token()` does not and,
#' instead, returns `""`.
#'
#' See GitHub's documentation on [Creating a personal access
#' token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token),
#' or use `usethis::create_github_token()` for a guided experience, including
#' pre-selection of recommended scopes. Once you have a PAT, you can use
#' [gitcreds::gitcreds_set()] to add it to the Git credential store. From that
#' point on, gh (via [gitcreds::gitcreds_get()]) should be able to find it
#' without further effort on your part.
#'
#' @param api_url GitHub API URL. Defaults to the `GITHUB_API_URL` environment
#'   variable, if set, and otherwise to <https://api.github.com>.
#'
#' @return A string of 40 hexadecimal digits, if a PAT is found, or the empty
#'   string, otherwise. For convenience, the return value has an S3 class in
#'   order to ensure that simple printing strategies don't reveal the entire
#'   PAT.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' gh_token()
#'
#' format(gh_token())
#'
#' str(gh_token())
#' }
gh_token <- function(api_url = NULL) {
  api_url <- api_url %||% default_api_url()
  stopifnot(is.character(api_url), length(api_url) == 1)
  token <- tryCatch(
    gitcreds::gitcreds_get(get_hosturl(api_url)),
    error = function(e) NULL
  )
  gh_pat(token$password %||% "")
}

gh_auth <- function(token) {
  if (isTRUE(token != "")) {
    c("Authorization" = paste("token", token))
  } else {
    character()
  }
}

# gh_pat class: exists in order have a print method that hides info ----
new_gh_pat <- function(x) {
  if (is.character(x) && length(x) == 1) {
    structure(x, class = "gh_pat")
  } else {
    throw(new_error("A GitHub PAT must be a string"))
  }
}

# validates PAT only in a very narrow, technical, and local sense
validate_gh_pat <- function(x) {
  stopifnot(inherits(x, "gh_pat"))
  if (x == "" || grepl("[[:xdigit:]]{40}", x)) {
    x
  } else {
    throw(new_error("A GitHub PAT must consist of 40 hexadecimal digits"))
  }
}

gh_pat <- function(x) {
  validate_gh_pat(new_gh_pat(x))
}

#' @export
format.gh_pat <- function(x, ...) {
  if (x == "") {
    "<no PAT>"
  } else {
    obfuscate(x)
  }
}

#' @export
print.gh_pat <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}

#' @export
str.gh_pat <- function(object, ...) {
  cat(paste0("<gh_pat> ", format(object), "\n", collapse = ""))
  invisible()
}

obfuscate <- function(x, first = 4, last = 2) {
  paste0(
    substr(x, start = 1, stop = first),
    "...",
    substr(x, start = nchar(x) - last + 1, stop = nchar(x))
  )
}
