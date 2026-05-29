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
#' environment variables (`GITHUB_PAT`, `GITHUB_TOKEN`)
#' and then the local Git credential store for a PAT
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
#' # Token format validation
#'
#' gh warns if the PAT it retrieves does not match a known format.
#' Set `options(gh_validate_tokens = "off")` or the
#' `GH_VALIDATE_TOKENS=off` environment variable to avoid this warning.
#' The option takes precedence over the environment variable.
#'
#' Set `options(gh_validate_tokens = "error")` or the
#' `GH_VALIDATE_TOKENS=error` environment variable to make gh throw an
#' error for an unrecognized PAT format.
#'
#' @param api_url GitHub API URL. Defaults to the `GITHUB_API_URL` environment
#'   variable, if set, and otherwise to <https://api.github.com>.
#'
#' @return A string of characters, if a PAT is found, or the empty
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
  check_string(api_url)
  host_url <- get_hosturl(api_url)
  # Check for credentials supplied by Posit Connect.
  if (is_installed("connectcreds")) {
    if (connectcreds::has_viewer_token(host_url)) {
      token <- connectcreds::connect_viewer_token(host_url)
      return(gh_pat(token$access_token))
    }
  }
  token <- tryCatch(
    gitcreds::gitcreds_get(host_url),
    error = function(e) NULL
  )
  gh_pat(token$password %||% "")
}

#' @export
#' @rdname gh_token
gh_token_exists <- function(api_url = NULL) {
  tryCatch(nzchar(gh_token(api_url)), error = function(e) FALSE)
}

gh_auth <- function(token) {
  if (isTRUE(token != "")) {
    if (any(grepl("\\s", token))) {
      warning("Token contains whitespace characters")
    }
    c("Authorization" = paste("token", trim_ws(token)))
  } else {
    character()
  }
}

# gh_pat class: exists in order have a print method that hides info ----
new_gh_pat <- function(x) {
  if (is.character(x) && length(x) == 1) {
    structure(x, class = "gh_pat")
  } else {
    cli::cli_abort("A GitHub PAT must be a string")
  }
}

# validates PAT only in a very narrow, technical, and local sense
validate_gh_pat <- function(x) {
  if (!inherits(x, "gh_pat")) {
    stop_input_type(x, "a <gh_pat> object")
  }
  mode <- get_validate_tokens_mode()
  if (mode == "off") {
    return(x)
  }
  if (
    x == "" ||
      # https://github.blog/changelog/2021-03-04-authentication-token-format-updates/
      # Fine grained tokens start with "github_pat_".
      # https://github.blog/changelog/2022-10-18-introducing-fine-grained-personal-access-tokens/
      # GitHub App installation tokens start with "ghs_".
      # https://github.blog/changelog/2026-04-24-notice-about-upcoming-new-format-for-github-app-installation-tokens/
      grepl(
        "^(gh[pousr]_[A-Za-z0-9_]{36,251}|github_pat_[A-Za-z0-9_]{36,244}|ghs_.+)$",
        x
      ) ||
      grepl("^[[:xdigit:]]{40}$", x)
  ) {
    return(x)
  }
  url <- "https://gh.r-lib.org/articles/managing-personal-access-tokens.html"
  msg <- c(
    "Invalid GitHub PAT format",
    "i" = "A GitHub PAT must have one of four forms:",
    "*" = "40 hexadecimal digits (older PATs)",
    "*" = "A 'ghp_' prefix followed by 36 to 251 more characters (newer
           PATs)",
    "*" = "A `ghs_` prefix followed by about 500 characters (GitHub App
           installation tokens)",
    "*" = "A 'github_pat_' prefix followed by 36 to 244 more characters
           (fine-grained PATs)",
    "i" = "Read more at {.url {url}}."
  )
  sil <- c(
    "i" = "Set {.code options(gh_validate_tokens = \"off\")} or env var
           {.envvar GH_VALIDATE_TOKENS=off} to silence this."
  )
  if (mode == "warn") {
    cli::cli_warn(
      c(msg, sil),
      .frequency = "regularly",
      .frequency_id = "gh_invalid_pat"
    )
    return(x)
  }
  cli::cli_abort(msg)
}

# Resolve token-validation mode: option > env var > "warn".
get_validate_tokens_mode <- function() {
  opt <- getOption("gh_validate_tokens")
  if (is.null(opt)) {
    env <- Sys.getenv("GH_VALIDATE_TOKENS", unset = "")
    mode <- if (nzchar(env)) env else "warn"
  } else {
    mode <- opt
  }
  if (!is.character(mode) || length(mode) != 1L || is.na(mode)) {
    cli::cli_abort(c(
      "Invalid token validation setting: must be a single string.",
      "i" = "Got {.obj_type_friendly {mode}}."
    ))
  }
  mode <- tolower(mode)
  if (!mode %in% c("off", "warn", "error")) {
    cli::cli_abort(c(
      "Invalid token validation mode: {.val {mode}}.",
      "i" = "Must be one of {.val off}, {.val warn}, or {.val error}.",
      "i" = "Configure via {.code options(gh_validate_tokens = ...)} or
             env var {.envvar GH_VALIDATE_TOKENS}."
    ))
  }
  mode
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

obfuscate <- function(x, first = 4, last = 4) {
  paste0(
    substr(x, start = 1, stop = first),
    "...",
    substr(x, start = nchar(x) - last + 1, stop = nchar(x))
  )
}
