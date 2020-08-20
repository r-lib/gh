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
#' looks in one or more of these places (details below):
#' * `"env"`: environment variable(s)
#' * `"git"`: Git credential store (requires the credentials package)
#' * `"key"`: OS-level keychain (requires the keyring package)
#'
#' Read more about PATs at
#' <https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token>.
#' Manage your PATs at <https://github.com/settings/tokens>, when logged in to
#' GitHub. The `usethis::create_github_token()` function guides you through the
#' process of getting a new PAT.
#'
#' @section PAT in an environment variable:
#'
#' The "env" search strategy looks for a PAT in specific environment variables.
#' If `api_url` targets "github.com", these variables are consulted, in order:
#' 1. `GITHUB_PAT_GITHUB_COM`
#' 2. `GTIHUB_PAT`
#' 3. `GITHUB_TOKEN`
#'
#' If `api_url` targets another GitHub deployment, such as "github.acme.com",
#' this variable is consulted:
#' * `GITHUB_PAT_GITHUB_ACME_COM`
#'
#' In both cases, the suffix in `GITHUB_PAT_<SUFFIX>` is derived from `api_url`
#' using the helper [slugify_url()].
#'
#' Looking up the PAT in an environment variable is definitely more secure than
#' including it explicitly in your code, i.e. providing via `gh(token = "xyz")`.
#' The simplest way to set this up is to define, e.g., `GITHUB_PAT` in your
#' `.Renviron` startup file. This is the entry-level solution.
#'
#' However, ideally you would not store your PAT in plain text like this. It is
#' also undesirable to make your PAT available to all your R sessions,
#' regardless of actual need. Both make it more likely you will expose your PAT
#' publicly, by accident.
#'
#' Therefore, it is strongly recommended to store your PAT in the Git credential
#' store or system keychain and allow gh to retrieve it on-demand. See the next
#' two sections for more.
#'
#' @section PAT in the Git credential store:
#'
#' The "git" search `strategy` uses the Suggested credentials package to look up
#' the PAT corresponding to `api_url` in the Git credential store. This
#' `strategy` has the advantage of using official Git tooling, specific to your
#' operating system, for managing secrets.
#'
#' The first time the "git" `strategy` is invoked, you may be prompted for your
#' PAT and, if it validates, it is stored for future re-use with this `api_url`.
#' For the remainder of the current R session, the PAT is also available via one
#' of the usual environment variables:
#' * `GITHUB_PAT` for "github.com"
#' * `GITHUB_PAT_GITHUB_ACME_COM` for "github.acme.com"
#'
#' This pattern of retrieving the PAT from the store upon first need and caching
#' it in an environment variable is why "env,git" is the default `strategy`:
#' 1. The initial "env" search fails.
#' 2. The "git" search succeeds and sets an environment variable in the session.
#' 3. Subsequent "env" searches succeed.
#'
#' Learn more in [credentials::set_github_pat()].
#'
#' @section PAT in the system keyring:
#'
#' The "key" search `strategy` uses the Suggested keyring package to retrieve
#' your PAT from the system keyring, on Windows, macOS and Linux, using the
#' keyring package. To activate keyring, specify a `strategy` that includes
#' "key" or set the `GH_KEYRING` environment variable to `true`, e.g. in your
#' `.Renviron` file.
#'
#' The keys queried for a PAT are exactly the same as the environment variable
#' names consulted for the "env" `strategy`. For "github.com", the first keyring
#' check looks like this:
#'
#' ```r
#' keyring::key_get("GITHUB_PAT_GITHUB_COM")
#' ```
#'
#' gh uses the default keyring backend and the default keyring within that
#' backend. See [keyring::default_backend()] for details and changing these
#' defaults.
#'
#' If the selected keyring is locked, and the session is interactive,
#' then gh will try to unlock it. If the keyring is locked, and the session
#' is not interactive, then gh will not use the keyring. Note that some
#' keyring backends cannot be locked, e.g. the one that uses environment
#' variables.
#'
#' On some OSes, e.g. typically on macOS, you need to allow R to access the
#' system keyring. You can allow this separately for each access, or for
#' all future accesses, until you update or re-install R. You typically
#' need to give access to each R GUI (e.g. RStudio) and the command line
#' R program separately.
#'
#' To store your PAT on the keyring run
#'
#' ```r
#' keyring::key_set("GITHUB_PAT")
#' ```
#'
#' @param api_url Github API url. Defaults to the `GITHUB_API_URL` environment
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
#'   gh uses to search for URL-specific PATs.
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
  if (is_github_dot_com(api_url)) {
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
