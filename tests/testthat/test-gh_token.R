test_that("URL specific token is used", {
  good <- gh_pat(strrep("a", 40))
  good2 <- gh_pat(strrep("b", 40))
  bad <- gh_pat(strrep("0", 40))
  bad2 <- gh_pat(strrep("1", 40))

  env <- c(
    GITHUB_API_URL = "https://github.acme.com",
    GITHUB_PAT_GITHUB_ACME_COM = good,
    GITHUB_PAT_GITHUB_ACME2_COM = good2,
    GITHUB_PAT = bad,
    GITHUB_TOKEN = bad2
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), good)
    expect_equal(gh_token("https://github.acme2.com"), good2)
  })

  env <- c(
    GITHUB_API_URL = NA,
    GITHUB_PAT_GITHUB_COM = good,
    GITHUB_PAT = bad,
    GITHUB_TOKEN = bad2
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), good)
    expect_equal(gh_token("https://api.github.com"), good)
  })
})

test_that("fall back to GITHUB_PAT, then GITHUB_TOKEN", {
  pat <- gh_pat(strrep("a", 40))
  token <- gh_pat(strrep("0", 40))

  env <- c(
    GITHUB_API_URL = NA,
    GITHUB_PAT_GITHUB_COM = NA,
    GITHUB_PAT = pat,
    GITHUB_TOKEN = token
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), pat)
    expect_equal(gh_token("https://api.github.com"), pat)
  })

  env <- c(
    GITHUB_API_URL = NA,
    GITHUB_PAT_GITHUB_COM = NA,
    GITHUB_PAT = NA,
    GITHUB_TOKEN = token
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), token)
    expect_equal(gh_token("https://api.github.com"), token)
  })
})

# gh_pat class ----
test_that("validate_gh_pat() rejects bad characters, wrong # of characters", {
  # older PATs
  expect_error(gh_pat(strrep("a", 40)), NA)
  expect_error(gh_pat(strrep("g", 40)), "40 hexadecimal digits", class = "error")
  expect_error(gh_pat("aa"), "40 hexadecimal digits", class = "error")

  # newer PATs
  expect_error(gh_pat(paste0("ghp_", strrep("B", 36))), NA)
  expect_error(gh_pat(paste0("ghp_", strrep("3", 251))), NA)
  expect_error(gh_pat(paste0("github_pat_", strrep("A", 36))), NA)
  expect_error(gh_pat(paste0("github_pat_", strrep("3", 244))), NA)
  expect_error(gh_pat(paste0("ghJ_", strrep("a", 36))), "prefix", class = "error")
  expect_error(gh_pat(paste0("github_pa_", strrep("B", 244))), "github_pat_", class = "error")
})

test_that("format.gh_pat() and str.gh_pat() hide the middle stuff", {
  pat <- paste0(strrep("a", 10), strrep("4", 20), strrep("F", 10))
  expect_match(format(gh_pat(pat)), "[a-zA-Z]+")
  expect_output(str(gh_pat(pat)), "[a-zA-Z]+")
})

test_that("str.gh_pat() indicates it's a `gh_pat`", {
  pat <- paste0(strrep("a", 10), strrep("4", 20), strrep("F", 10))
  expect_output(str(gh_pat(pat)), "gh_pat")
})

test_that("format.gh_pat() handles empty string", {
  expect_match(format(gh_pat("")), "<no PAT>")
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
