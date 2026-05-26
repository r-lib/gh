withr::local_options(
  gh_cache = FALSE,
  .local_envir = testthat::teardown_env()
)

# Make the test suite hermetic: prevent any real PAT being picked up from
# the user's environment or git credential store. Individual tests can
# still override these via withr.
withr::local_envvar(
  c(
    GITHUB_API_URL = NA,
    GITHUB_PAT_GITHUB_COM = "",
    GITHUB_PAT = "",
    GITHUB_TOKEN = ""
  ),
  .local_envir = testthat::teardown_env()
)
