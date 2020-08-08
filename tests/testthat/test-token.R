test_that("URL specific token is used", {
  good  <- gh_pat(strrep("a", 40))
  good2 <- gh_pat(strrep("b", 40))
  bad   <- gh_pat(strrep("0", 40))
  bad2  <- gh_pat(strrep("1", 40))

  env <- c(
    GH_KEYRING = "false",
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
    GH_KEYRING = "false",
    GITHUB_API_URL = NA,
    GITHUB_PAT_API_GITHUB_COM = good,
    GITHUB_PAT = bad,
    GITHUB_TOKEN = bad2
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), good)
    expect_equal(gh_token("https://api.github.com"), good)
  })
})

test_that("fall back to GITHUB_PAT, then GITHUB_TOKEN", {
  pat   <- gh_pat(strrep("a", 40))
  token <- gh_pat(strrep("0", 40))

  env <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = NA,
    GITHUB_PAT_API_GITHUB_COM = NA,
    GITHUB_PAT = pat,
    GITHUB_TOKEN = token
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), pat)
    expect_equal(gh_token("https://api.github.com"), pat)
  })

  env <- c(
    GH_KEYRING = "false",
    GITHUB_API_URL = NA,
    GITHUB_PAT_API_GITHUB_COM = NA,
    GITHUB_PAT = NA,
    GITHUB_TOKEN = token
  )
  withr::with_envvar(env, {
    expect_equal(gh_token(), token)
    expect_equal(gh_token("https://api.github.com"), token)
  })
})

# gh_pat class
test_that("validate_gh_pat() rejects bad characters, wrong # of characters", {
  expect_error(gh_pat(strrep("a", 40)), NA)
  expect_error(gh_pat(strrep("g", 40)), "40 hexadecimal digits")
  expect_error(gh_pat("aa"), "40 hexadecimal digits")
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
