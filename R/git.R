#' Find the GitHub remote associated with a path
#'
#' This is handy helper if you want to make gh requests related to the
#' current project.
#'
#' @param path Path that is contained within a git repo.
#' @return If the repo has a github remote, a list containing `username`
#'    and `repo`. Otherwise, an error.
#' @export
#' @examplesIf interactive()
#' gh_tree_remote()
gh_tree_remote <- function(path = ".") {
  github_remote(git_remotes(path), path)
}

github_remote <- function(x, path) {
  remotes <- lapply(x, github_remote_parse)
  remotes <- remotes[!vapply(remotes, is.null, logical(1))]

  if (length(remotes) == 0) {
    cli::cli_abort("No GitHub remotes found at {.path {path}}")
  }

  if (length(remotes) > 1) {
    if (any(names(remotes) == "origin")) {
      warning("Multiple github remotes found. Using origin.", call. = FALSE)
      remotes <- remotes[["origin"]]
    } else {
      warning("Multiple github remotes found. Using first.", call. = FALSE)
      remotes <- remotes[[1]]
    }
  } else {
    remotes[[1]]
  }
}

github_remote_parse <- function(x) {
  if (length(x) == 0) {
    return(NULL)
  }
  if (!grepl("github", x)) {
    return(NULL)
  }

  # https://github.com/hadley/devtools.git
  # https://github.com/hadley/devtools
  # git@github.com:hadley/devtools.git
  re <- "github[^/:]*[/:]([^/]+)/(.*?)(?:\\.git)?$"
  m <- regexec(re, x)
  match <- regmatches(x, m)[[1]]

  if (length(match) == 0) {
    return(NULL)
  }

  list(
    username = match[2],
    repo = match[3]
  )
}

git_remotes <- function(path = ".") {
  conf <- git_config(path)
  remotes <- conf[grepl("^remote", names(conf))]

  remotes <- discard(remotes, function(x) is.null(x$url))
  urls <- vapply(remotes, "[[", "url", FUN.VALUE = character(1))

  names(urls) <- gsub('^remote "(.*?)"$', "\\1", names(remotes))
  urls
}



git_config <- function(path = ".") {
  config_path <- file.path(repo_root(path), ".git", "config")
  if (!file.exists(config_path)) {
    cli::cli_abort("git config does not exist at {.path {path}}")
  }
  ini::read.ini(config_path, "UTF-8")
}

repo_root <- function(path = ".") {
  if (!file.exists(path)) {
    cli::cli_abort("Can't find repo at {.path {path}}")
  }

  # Walk up to root directory
  while (!has_git(path)) {
    if (is_root(path)) {
      cli::cli_abort("Could not find git root from {.path {path}}.")
    }

    path <- dirname(path)
  }

  path
}

has_git <- function(path) {
  file.exists(file.path(path, ".git"))
}

is_root <- function(path) {
  identical(path, dirname(path))
}
