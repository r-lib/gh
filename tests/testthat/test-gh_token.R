
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
    GITHUB_PAT_GITHUB_COM = "good",
    GITHUB_PAT = "bad",
    GITHUB_TOKEN = "bad2"
  )
  withr::with_envvar(env2, {
    expect_equal(gh_token(), "good")
    expect_equal(gh_token("https://api.github.com"), "good")
  })
})

test_that("do not send GITHUB_PAT to non-github.com host", {
  env <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = "https://github.acme.com",
    GITHUB_PAT_GITHUB_ACME2_COM = "acme2",
    GITHUB_PAT = "pat",
    GITHUB_TOKEN = "token"
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), "")
  })
})

test_that("fall back to GITHUB_PAT", {
  env <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = NA,
    GITHUB_PAT_API_GITHUB_COM = NA,
    GITHUB_PAT = "pat",
    GITHUB_TOKEN = "token"
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), "pat")
    expect_equal(gh_token("https://api.github.com"), "pat")
  })
})

test_that("fall back to GITHUB_TOKEN", {
  env <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = NA,
    GITHUB_PAT_API_GITHUB_COM = NA,
    GITHUB_PAT = NA,
    GITHUB_TOKEN = "token"
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), "token")
    expect_equal(gh_token("https://api.github.com"), "token")
  })
})

# URL processing helpers ----
test_that("get_baseurl() insists on http(s)", {
  expect_error(get_baseurl("github.com"), "protocols")
  expect_error(get_baseurl("github.acme.com"), "protocols")
})

test_that("get_baseurl() works", {
  x <- "https://github.com"
  expect_equal(get_baseurl("https://github.com"), x)
  expect_equal(get_baseurl("https://github.com/"), x)
  expect_equal(get_baseurl("https://github.com/stuff"), x)
  expect_equal(get_baseurl("https://github.com/stuff/"), x)
  expect_equal(get_baseurl("https://github.com/more/stuff"), x)

  x <- "https://api.github.com"
  expect_equal(get_baseurl("https://api.github.com"), x)
  expect_equal(get_baseurl("https://api.github.com/rate_limit"), x)

  x <- "https://github.acme.com"
  expect_equal(get_baseurl("https://github.acme.com"), x)
  expect_equal(get_baseurl("https://github.acme.com/"), x)
  expect_equal(get_baseurl("https://github.acme.com/api/v3"), x)

  # so (what little) support we have for user@host doesn't regress
  expect_equal(
    get_baseurl("https://jane@github.acme.com/api/v3"),
    "https://jane@github.acme.com"
  )
})

test_that("slugify_url() works", {
  x <- "GITHUB_COM"
  expect_equal(slugify_url("https://github.com"), x)
  expect_equal(slugify_url("https://github.com/more/stuff"), x)
  expect_equal(slugify_url("https://api.github.com"), x)
  expect_equal(slugify_url("https://api.github.com/rate_limit"), x)

  x <- "GITHUB_ACME_COM"
  expect_equal(slugify_url("https://github.acme.com"), x)
  expect_equal(slugify_url("https://github.acme.com/"), x)
  expect_equal(slugify_url("https://github.acme.com/api/v3"), x)
})

test_that("is_github_dot_com() works", {
  expect_true(is_github_dot_com("https://github.com"))
  expect_true(is_github_dot_com("https://api.github.com"))
  expect_true(is_github_dot_com("https://api.github.com/rate_limit"))
  expect_true(is_github_dot_com("https://api.github.com/graphql"))

  expect_false(is_github_dot_com("https://github.acme.com"))
  expect_false(is_github_dot_com("https://github.acme.com/api/v3"))
  expect_false(is_github_dot_com("https://github.acme.com/api/v3/user"))
})

test_that("get_hosturl() works", {
  x <- "https://github.com"
  expect_equal(get_hosturl("https://github.com"), x)
  expect_equal(get_hosturl("https://api.github.com"), x)

  x <- "https://github.acme.com"
  expect_equal(get_hosturl("https://github.acme.com"), x)
  expect_equal(get_hosturl("https://github.acme.com/api/v3"), x)
})

test_that("get_apiurl() works", {
  x <- "https://api.github.com"
  expect_equal(get_apiurl("https://github.com"), x)
  expect_equal(get_apiurl("https://github.com/"), x)
  expect_equal(get_apiurl("https://github.com/r-lib/gh/issues"), x)
  expect_equal(get_apiurl("https://api.github.com"), x)
  expect_equal(get_apiurl("https://api.github.com/rate_limit"), x)

  x <- "https://github.acme.com/api/v3"
  expect_equal(get_apiurl("https://github.acme.com"), x)
  expect_equal(get_apiurl("https://github.acme.com/OWNER/REPO"), x)
  expect_equal(get_apiurl("https://github.acme.com/api/v3"), x)
})
