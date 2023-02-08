skip_if_no_github <- function(has_scope = NULL) {
  skip_if_offline("github.com")
  skip_on_cran()

  if (gh_token() == "") {
    skip("No GitHub token")
  }

  if (!is.null(has_scope) && !has_scope %in% test_scopes()) {
    skip(glue::glue("Current token lacks '{has_scope}' scope"))
  }
}

test_scopes <- function() {
  whoami <- env_cache(cache, "whoami", gh_whoami())
  strsplit(whoami$scopes, ", ")[[1]]
}

cache <- new_environment()
