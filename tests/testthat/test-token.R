
test_that("api specific token is used", {
  env <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = "https://github.acme.com",
    GITHUB_PAT_GITHUB_ACME_COM = "good",
    GITHUB_PAT_GITHUB_ACME2_COM = "good2",
    GITHUB_PAT = "bad",
    GITHUB_TOKEN = "bad2"
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), "good")
    expect_equal(gh_token("https://github.acme2.com"), "good2")
  })

  env2 <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = NA,
    GITHUB_PAT_API_GITHUB_COM = "good",
    GITHUB_PAT = "bad",
    GITHUB_TOKEN = "bad2"
  )
  withr::with_envvar(env2, {
    expect_equal(gh_token(), "good")
    expect_equal(gh_token("https://api.github.com"), "good")
  })
})

test_that("fall back to GITHUB_PAT", {
  env <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = "https://github.acme.com",
    GITHUB_PAT_GITHUB_ACME2_COM = "acme2",
    GITHUB_PAT = "pat",
    GITHUB_TOKEN = "token"
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), "pat")
    expect_equal(gh_token("https://github.acme4.com"), "pat")
  })

  env2 <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = "https://github.acme.com",
    GITHUB_PAT = "pat",
    GITHUB_TOKEN = "token"
  )
  withr::with_envvar(env2, {
    expect_equal(gh_token(), "pat")
    expect_equal(gh_token("https://github.acme4.com"), "pat")
  })

  env3 <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = NA,
    GITHUB_PAT_API_GITHUB_COM = NA,
    GITHUB_PAT = "pat",
    GITHUB_TOKEN = "token"
  )
  withr::with_envvar(env3, {
    expect_equal(gh_token(), "pat")
    expect_equal(gh_token("https://api.github.com"), "pat")
  })
})

test_that("fall back to GITHUB_TOKEN", {
  env <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = "https://github.acme.com",
    GITHUB_PAT_GITHUB_ACME2_COM = "acme2",
    GITHUB_PAT = NA,
    GITHUB_TOKEN = "token"
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), "token")
    expect_equal(gh_token("https://github.acme4.com"), "token")
  })

  env2 <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = "https://github.acme.com",
    GITHUB_PAT = NA,
    GITHUB_TOKEN = "token"
  )
  withr::with_envvar(env2, {
    expect_equal(gh_token(), "token")
    expect_equal(gh_token("https://github.acme4.com"), "token")
  })

  env3 <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = NA,
    GITHUB_PAT_API_GITHUB_COM = NA,
    GITHUB_PAT = NA,
    GITHUB_TOKEN = "token"
  )
  withr::with_envvar(env3, {
    expect_equal(gh_token(), "token")
    expect_equal(gh_token("https://api.github.com"), "token")
  })
})
