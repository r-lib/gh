
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
#' for the PAT in an URL specific environment variable first. It uses
#' [slugify_url()] to compute a suffix from the API URL, by extracting the
#' host name and removing the protocol and the path from it, and replacing
#' special characters with underscores. This suffix is added to
#' `GITHUB_PAT_` then. For example for the default API URL:
#' <https://api.github.com>, the `GITHUB_PAT_API_GITHUB_COM` environment
#' variable is consulted first.
#'
#' You can set the default API URL via the `GITHUB_API_URL` environment
#' variable.
#'
#' If the API URL specific environment variable is not set, then gh falls
#' back to `GITHUB_PAT` and then to `GITHUB_TOKEN`.
#'
#' @section Storing PATs in the system keyring:
#'
#' gh supports storing your PAT in the system keyring, on Windows, macOS
#' and Linux, using the keyring package. To turn on keyring support, you
#' need to set the `GH_KEYRING` environment variables to `true`, in your
#' `.Renviron` file or profile.
#'
#' If keyring support is turned on, then for each PAT environment variable,
#' gh first checks whether the key with that value is set in the system
#' keyring, and if yes, it will use its value as the PAT. I.e. without a
#' custom `GITHUB_API_URL` variable, it checks the
#' `GITHUB_PAT_API_GITHUB_COM` key first, then the env var with the same
#' name, then the `GITHUB_PAT` key, etc. Such a check looks like this:
#'
#' ```r
#' keyring::key_get("GITHUB_PAT_API_GITHUB_COM")
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
#' @return A string, with the token, or a zero length string scalar,
#' if no token is available.
#'
#' @seealso [slugify_url()] for computing the environment variables that
#' gh uses to search for API URL specific PATs.
#' @export

gh_token <- function(api_url = NULL) {
  api_url <- api_url %||% default_api_url()
  token_env_var <- paste0("GITHUB_PAT_", slugify_url(api_url))
  candidates <- c(
    token_env_var,
    if (is_github_dot_com(api_url)) c("GITHUB_PAT", "GITHUB_TOKEN")
  )
  val <- get_first_token_found(candidates)
  if (val != "" || !can_load("credentials")) {
    return(val)
  }

  set_github_pat2(api_url)
  if (is_github_dot_com(api_url)) {
    Sys.getenv("GITHUB_PAT", "")
  } else {
    Sys.getenv(token_env_var, "")
  }
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
    # TODO: Shouldn't this be <<- ?
    error = function(e) err <- TRUE
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
    # TODO: Shouldn't this be <<- ?
    tryCatch(keyring::keyring_unlock(), error = function(e) err <- TRUE)
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
#' construct the names of environment variables that hold the username or PAT
#' for a specific GitHub URL. This is mostly relevant to people using GitHub
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
  sub("api.github.com", "github.com", x)
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

# inlined from credentials and generalized to non-github.com URL
# is_interactive() is an unexported helper defined in utils.R
# morally, is rlang::is_interactive()
set_github_pat2 <- function(api_url = default_api_url(),
                            force_new = FALSE,
                            validate = is_interactive(),
                            verbose = validate) {
  if (!can_load("credentials")) {
    return(FALSE)
  }

  host_url <- get_hosturl(api_url)
  prot_host <- strsplit(host_url, "://", fixed = TRUE)[[1]]
  if (is_github_dot_com(api_url)) {
    # what's currently in credentials
    # pat_user <- Sys.getenv("GITHUB_PAT_USER", 'PersonalAccessToken')
    # TODO: I propose we change the user env var to GITHUB_USER
    user_env_var <- "GITHUB_PAT_USER"
    token_env_var <- "GITHUB_PAT"
  } else {
    user_env_var <- paste0("GITHUB_USER_", slugify_url(api_url))
    token_env_var <- paste0("GITHUB_PAT_", slugify_url(api_url))
  }
  api_url <- get_apiurl(api_url)

  # The username doesn't have to be real, Github seems to ignore username for PATs
  pat_user <- Sys.getenv(user_env_var, "PersonalAccessToken")
  # credentials does: pat_url <- sprintf("https://%s@github.com", pat_user)

  pat_url <- sprintf(
    "%s://%s@%s",
    prot_host[[1]], pat_user, prot_host[[2]]
  )

  if (isTRUE(force_new)) {
    credentials::git_credential_forget(pat_url)
  }

  # credentials does the "hack" unconditionally, but I think this is better
  if (is_interactive()) {
    if(isTRUE(verbose)) {
      message2("If prompted for GitHub credentials, enter your PAT in the password field")
    }
    askpass <- Sys.getenv('GIT_ASKPASS')
    if (nchar(askpass)) {
      # Hack to override prompt sentence to say "Token" instead of "Password"
      withr::local_envvar(c(
        GIT_ASKTOKEN = askpass,
        GIT_ASKPASS = system.file(
          "ask_token.sh", package = "gh", mustWork = TRUE
        ),
        GIT_ASKTOKEN_NAME = sprintf(
          "Personal Access Token (PAT) for %s", host_url
        )
      ))
    }
  } else {
    withr::local_envvar(c(
      GIT_ASKPASS = system.file(
        "empty_token.sh", package = "gh", mustWork = TRUE
      )
    ))
  }

  for(i in 1:3) {
    cred <- credentials::git_credential_ask(pat_url, verbose = verbose)
    if (length(cred$password) && !is.na(cred$password)) {
      if (nchar(cred$password) < 40) {
        message2("Please enter a token in the password field, not your master password! Let's try again :-)")
        message2(sprintf(
          "To generate a new token, visit: %s/settings/tokens",
          host_url
        ))
        credentials::credential_reject(cred)
        next
      }
      if (isTRUE(validate)) {
        hx <- curl::handle_setheaders(curl::new_handle(), Authorization = paste("token", cred$password))
        req <- curl::curl_fetch_memory(sprintf("%s/user", api_url), handle = hx)
        if (req$status_code >= 400) {
          message2("Authentication failed. Token invalid.")
          credentials::credential_reject(cred)
          next
        }
        if (isTRUE(verbose)) {
          data <- jsonlite::fromJSON(rawToChar(req$content))
          helper <- tryCatch(
            credentials::credential_helper_get()[1],
            error = function(e){"??"}
          )
          message2(sprintf(
            "Using token stored for %s for user '%s' (credential helper: %s)",
            host_url, data$login, helper
          ))
        }
      }
      return(
        do.call(Sys.setenv, stats::setNames(list(cred$password), token_env_var))
      )
    }
  }
  if (isTRUE(verbose)) {
    message2(sprintf(
      "Failed to obtain a valid token for %s after 3 attempts",
      host_url
    ))
  }
  return(FALSE)
}

# taken directly from credentials
message2 <- function(...){
  base::message(...)
  utils::flush.console()
}
