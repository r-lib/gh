fake_token <- function() paste0("ghp_", strrep("A", 36))

# A single fake-server subprocess is started on demand and reused across
# test files. Its lifetime is bound to testthat::teardown_env(), which lives
# until the test run ends.
.fake_server <- new.env(parent = emptyenv())

fake_server <- function() {
  skip_if_not_installed("webfakes")
  if (is.null(.fake_server$proc)) {
    .fake_server$proc <- webfakes::local_app_process(
      gh::fake_github_app(),
      .local_envir = testthat::teardown_env()
    )
  }
  .fake_server$proc
}

local_fake_github <- function(
  .local_envir = parent.frame(),
  token = fake_token()
) {
  proc <- fake_server()
  url <- proc$url()
  envvar <- gitcreds::gitcreds_cache_envvar(url)

  envs <- c(
    GITHUB_API_URL = url,
    GITHUB_PAT = NA_character_,
    GITHUB_TOKEN = NA_character_,
    setNames(token, envvar)
  )
  withr::local_envvar(envs, .local_envir = .local_envir)

  proc
}

# Replace the dynamic fake-server host with a stable placeholder so snapshots
# stay deterministic across runs.
redact_fake_host <- function(lines) {
  lines <- gsub(
    "https?://127\\.0\\.0\\.1:[0-9]+/api/v3",
    "https://api.github.com",
    lines
  )
  gsub("https?://127\\.0\\.0\\.1:[0-9]+", "https://api.github.com", lines)
}
