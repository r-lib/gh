
#' Return the local user's GitHub Personal Access Token (PAT)
#'
#' You can read more about PATs here:
#' <https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/>
#' and you can access your PATs here (if logged in to GitHub):
#' <https://github.com/settings/tokens>.
#'
#' Set the `GITHUB_PAT` environment variable to avoid having to include
#' your PAT in the code. If you work with multiple GitHub deployments,
#' e.g. via GitHub Enterprise, then read 'PATs for GitHub Enterprise' below.
#'
#' If you want a more secure solution than putting authentication tokens
#' into environment variables, read 'Storing PATs in the system keyring'
#' below.
#'
#' @section PATs for GitHub Enterprise:
#'
#' gh lets you use different PATs for different GitHub API URLs, by looking
#' for the PAT in an URL-specific environment variable first. The helper
#' [slugify_url()] computes a suffix from the API URL like so:
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
#' This implies that, for the default API URL <https://api.github.com>, these
#' env vars are consulted, in this order:
#' * `GITHUB_PAT_GITHUB_COM`
#' * `GTIHUB_PAT`
#' * `GITHUB_TOKEN`
#'
#' You can customize the default API URL via the `GITHUB_API_URL` environment
#' variable.
#'
#' @section Storing PATs in the system keyring:
#'
#' gh supports storing your PAT in the system keyring, on Windows, macOS
#' and Linux, using the keyring package. To turn on keyring support, you
#' need to set the `GH_KEYRING` environment variables to `true`, e.g. in your
#' `.Renviron` file.
#'
#' If keyring support is turned on, then for each PAT environment variable,
#' gh first checks for it via `Sys.getenv()` and, if unset, gh then checks
#' whether such a key exists in the system keyring and, if yes, it uses
#' the associated value as the PAT. I.e. without a custom `GITHUB_API_URL`
#' variable, gh checks the `GITHUB_PAT_GITHUB_COM` env var first, then
#' checks for that key in the keyring, then moves on to do same with
#' `GITHUB_PAT` and perhaps `GITHUB_TOKEN`. The keyring check looks like this:
#'
#' ```r
#' keyring::key_get("GITHUB_PAT_GITHUB_COM")
#' ```
#'
#' and it uses the default keyring backend and the default keyring within
#' that backend. See [keyring::default_backend()] for details and changing
#' these defaults.
#'
#' If the selected keyring is locked, and the session is interactive,
#' then gh will try to unlock it. If the keyring is locked, and the session
#' is not interactive, then gh will not use the keyring. Note that some
#' keyring backends cannot be locked (e.g. the one that uses environment
#' variables).
#'
#' On some OSes, e.g. typically on macOS, you need to allow R to access the
#' system keyring. You can allow this separately for each access, or for
#' all future accesses, until you update or re-install R. You typically
#' need to give access to each R GUI (e.g. RStudio) and the command line
#' R program separately.
#'
#' To store your PAT on the keyring run
#' ```r
#' keyring::key_set("GITHUB_PAT")
#' ```
#'
#' @param api_url Github API url. Defaults to `GITHUB_API_URL`
#' environment variable if set, otherwise <https://api.github.com>.
#'
#' @return A string of 40 hexadecimal digits, if token is available, or the
#'   empty string, otherwise. For convenience, the return value has an S3 class
#'   in order to ensure that simple printing strategies don't reveal the entire
#'   token.
#'
#' @seealso [slugify_url()] for computing the environment variables that
#' gh uses to search for API URL specific PATs.
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
  token_env_var <- paste0("GITHUB_PAT_", slugify_url(api_url))
  gh_pat(get_first_token_found(
    c(token_env_var, "GITHUB_PAT", "GITHUB_TOKEN")
  ))
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

get_first_token_found <- function(vars) {
  if (length(vars) == 0) return("")
  has_keyring <- should_use_keyring()
  val <- ""
  key_get <- function(v) {
    if (has_keyring) tryCatch(keyring::key_get(v), error = function(e) NULL)
  }
  for (var in vars) {
    if ((val <- Sys.getenv(var, "")) != "") break
    if ((val <- key_get(var) %||% "") != "") break
  }

  val
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
#' `slugify_url()` determines a suffix from a URL and this suffix is used to
#' construct the name of an environment variable that holds the PAT for a
#' specific GitHub URL. This is mostly relevant to people using GitHub
#' Enterprise.
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

normalize_host <- function(x) {
  sub("api[.]github[.]com", "github.com", x)
}

get_hosturl <- function(url) {
  url <- get_baseurl(url)
  normalize_host(url)
}

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
