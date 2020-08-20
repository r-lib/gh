#' Return the local user's GitHub Personal Access Token (PAT)
#'
#' @description
#' If gh can find a personal access token (PAT) via `gh_token()`, it includes
#' the PAT in its requests. Some requests succeed without a PAT, but many
#' require a PAT to prove the request is authorized by a specific GitHub user. A
#' PAT also helps with rate limiting. If your gh use is more than casual, you
#' want a PAT.
#'
#' The PAT corresponding to `api_url` is searched for with a `strategy` that
#' looks in one or more of these places:
#' * `"env"`: environment variable(s)
#' * `"git"`: Git credential store (requires the credentials package)
#' * `"key"`: OS-level keychain (requires the keyring package)
#'
#' Details are in the [Managing Personal Access Tokens](https://gh.r-lib.org/articles/managing-personal-access-tokens.html) vignette.
#'
#' @param api_url GitHub API URL. Defaults to the `GITHUB_API_URL` environment
#'   variable, if set, and otherwise to <https://api.github.com>.
#' @param strategy Where to look for a PAT. If specified, must be a
#'   comma-delimited string consisting of "env", "git", and/or "key". Examples:
#'   "env", "env,git", "key,git,env". gh searches for a PAT in these places, in
#'   this order.
#'
#'   By default, `strategy` is "env,git" if the credential package is available
#'   and "env" if it is not.
#'
#' @return A string of 40 hexadecimal digits, if a PAT is found, or the empty
#'   string, otherwise. For convenience, the return value has an S3 class in
#'   order to ensure that simple printing strategies don't reveal the entire
#'   PAT.
#'
#' @seealso [slugify_url()] for computing the environment variables or keys that
#'   gh uses to search for URL-specific PATs. [gh_whoami()] to see details
#'   about a token.
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
gh_token <- function(api_url = NULL, strategy = NULL) {
  api_url <- api_url %||% default_api_url()
  stopifnot(is.character(api_url), length(api_url) == 1)

  strategy <- strategy %||% default_pat_strategy()
  stopifnot(is.character(strategy), length(strategy) == 1)

  strategy <- strsplit(strategy, split = ",")[[1]]
  match.arg(strategy, c("env", "git", "key"), several.ok = TRUE)
  pat <- ""
  for(s in strategy) {
    f <- switch(
      s,
      env = pat_envvar,
      git = pat_gitcred,
      key = pat_keyring
    )
    if ((pat <- f(api_url)) != "") break
  }
  gh_pat(pat)
}

default_pat_strategy <- function() {
  out <- c(
    "env",
    if (can_load("credentials")) "git",
    if (should_use_keyring()) "key"
  )
  paste0(out, collapse = ",")
}

pat_envvar <- function(api_url = default_api_url()) {
  val <- ""
  vars <- make_envvar_names(api_url)
  if (length(vars) == 0) {
    return(val)
  }
  for (var in vars) {
    if ((val <- Sys.getenv(var, "")) != "") break
  }
  val
}

pat_gitcred <- function(api_url = default_api_url()) {
  # TODO: drop Gabor's git credentials approach in here
  if (is_github_dot_com(api_url) && can_load("credentials")) {
    tryCatch(
      {
        suppressMessages(credentials::set_github_pat())
        Sys.getenv("GITHUB_PAT")
      },
      error = function(e) ""
    )
  } else {
    ""
  }
}

pat_keyring <- function(api_url = default_api_url()) {
  vars <- make_envvar_names(api_url)
  val <- ""
  if (length(vars) == 0 || !should_use_keyring()) {
    return(val)
  }
  key_get <- function(v) {
    tryCatch(keyring::key_get(v), error = function(e) NULL)
  }
  for (var in vars) {
    if ((val <- key_get(var) %||% "") != "") break
  }
  val
}

#' @importFrom cli cli_alert_info
should_use_keyring <- function() {
  # Opt in?
  if (tolower(Sys.getenv("GH_KEYRING", "")) != "true") return(FALSE)

  # Can we load the package?
  if (!can_load("keyring")) {
    cli_alert_info("{.pkg gh}: the {.pkg keyring} package is not available")
    return(FALSE)
  }

  # If is_locked() errors, the keyring cannot be locked, and we'll use it
  err <- FALSE
  tryCatch(
    locked <- keyring::keyring_is_locked(),
    error = function(e) err <<- TRUE
  )
  if (err) return(TRUE)

  # Otherwise if locked, and non-interactive session, we won't use it
  if (locked && ! is_interactive()) {
    cli_alert_info("{.pkg gh}: default keyring is locked")
    return(FALSE)
  }

  # Otherwise if locked, we try to unlock it here. Otherwise key_get()
  # would unlock it, but if that fails, we'll get multiple unlock dialogs
  # It is better to fail here, once and for all.
  if (locked) {
    err <- FALSE
    tryCatch(keyring::keyring_unlock(), error = function(e) err <<- TRUE)
    if (err) {
      cli_alert_info("{.pkg gh}: failed to unlock default keyring")
      return(FALSE)
    }
  }

  TRUE
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
#' @description
#' `slugify_url()` determines a suffix from a URL and this suffix is used to
#' construct the name of an environment variable that holds the PAT for a
#' specific GitHub URL. This is mostly relevant to people using GitHub
#' Enterprise. `slugify_url()` processes the API URL like so:
#' * Extract the host name, i.e. drop both the protocol and any path
#' * Substitute "github.com" for "api.github.com"
#' * Replace special characters with underscores
#' * Convert to ALL CAPS
#'
#' This suffix is then added to `GITHUB_PAT_` to form the name of an environment
#' variable. It's probably easiest to just look at some examples.
#'
#' ```{r}
#' # both give same result
#' slugify_url("https://api.github.com")
#' slugify_url("https://github.com")
#'
#' # an instance of GitHub Enterprise
#' # both give same result
#' slugify_url("https://github.acme.com")
#' slugify_url("https://github.acme.com/api/v3")
#' ```
#'
#' @param url Character vector of HTTP/HTTPS URLs. They don't have to be in the
#'   API-specific form, although they can be.
#' @return Character vector of suffixes.
#'
#' @seealso [gh_token()]
#' @export
#' @examples
#' # main github.com site
#' slugify_url("https://api.github.com")
#' slugify_url("https://github.com")
#'
#' # an instance of GitHub Enterprise
#' slugify_url("https://github.acme.com")
#' slugify_url("https://github.acme.com/api/v3")
slugify_url <- function(url) {           # https://jane@github.uni.edu/api/v3
  url <- get_baseurl(url)                # https://jane@github.uni.edu
  url <- normalize_host(url)
  x2 <- sub("^.*://([^/]*@)?", "", url)  # github.uni.edu
  x3 <- gsub("[.]+", "_", x2)            # github_uni_edu
  x4 <- gsub("[^-a-zA-Z0-9_]", "", x3)
  toupper(x4)                            # GITHUB_UNI_EDU
}

get_baseurl <- function(url) {               # https://github.uni.edu/api/v3/
  if (!any(grepl("^https?://", url))) {
    stop("Only works with HTTP(S) protocols")
  }
  prot <- sub("^(https?://).*$", "\\1", url) # https://
  rest <- sub("^https?://(.*)$", "\\1", url) #         github.uni.edu/api/v3/
  host <- sub("/.*$", "", rest)              #         github.uni.edu
  paste0(prot, host)                         # https://github.uni.edu
}

# https://api.github.com --> https://github.com
# api.github.com --> github.com
normalize_host <- function(x) {
  sub("api[.]github[.]com", "github.com", x)
}

get_hosturl <- function(url) {
  url <- get_baseurl(url)
  normalize_host(url)
}

# (almost) the inverse of get_hosturl()
# https://github.com     --> https://api.github.com
# https://github.uni.edu --> https://github.uni.edu/api/v3
get_apiurl <- function(url) {
  host_url <- get_hosturl(url)
  prot_host <- strsplit(host_url, "://", fixed = TRUE)[[1]]
  if (is_github_dot_com(host_url)) {
    paste0(prot_host[[1]], "://api.github.com")
  } else {
    paste0(host_url, "/api/v3")
  }
}

is_github_dot_com <- function(url) {
  url <- get_baseurl(url)
  url <- normalize_host(url)
  grepl("^https?://github.com", url)
}

make_envvar_names <- function(api_url) {
  stopifnot(is.character(api_url), length(api_url) == 1)
  c(
    paste0("GITHUB_PAT_", slugify_url(api_url)),
    if (is_github_dot_com(api_url)) c("GITHUB_PAT", "GITHUB_TOKEN")
  )
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
