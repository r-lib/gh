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

test_that("gh_token_exists works as expected", {
  withr::local_options(gh_validate_tokens = "error")
  withr::local_envvar(GITHUB_API_URL = "https://test.com")

  withr::local_envvar(GITHUB_PAT_TEST_COM = NA)
  expect_false(gh_token_exists())

  withr::local_envvar(GITHUB_PAT_TEST_COM = gh_pat(strrep("0", 40)))
  expect_true(gh_token_exists())

  withr::local_envvar(GITHUB_PAT_TEST_COM = "invalid")
  expect_false(gh_token_exists())
})

# gh_pat class ----
test_that("validate_gh_pat() rejects bad characters, wrong # of characters", {
  withr::local_options(gh_validate_tokens = "error")

  # older PATs
  expect_error(gh_pat(strrep("a", 40)), NA)
  expect_error(
    gh_pat(strrep("g", 40)),
    "40 hexadecimal digits",
    class = "error"
  )
  expect_error(gh_pat("aa"), "40 hexadecimal digits", class = "error")

  # newer PATs
  expect_error(gh_pat(paste0("ghp_", strrep("B", 36))), NA)
  expect_error(gh_pat(paste0("ghp_", strrep("3", 251))), NA)
  expect_error(gh_pat(paste0("github_pat_", strrep("A", 36))), NA)
  expect_error(gh_pat(paste0("github_pat_", strrep("3", 244))), NA)
  expect_error(
    gh_pat(paste0("ghJ_", strrep("a", 36))),
    "prefix",
    class = "error"
  )
  expect_error(
    gh_pat(paste0("github_pa_", strrep("B", 244))),
    "github_pat_",
    class = "error"
  )
})

test_that("validate_gh_pat() honors gh_validate_tokens option and env var", {
  bad <- "definitely-not-a-pat"

  # Default is "warn": warns but still returns the value. Reset the
  # session-wide warning throttle so the expected warning isn't suppressed
  # by an earlier firing.
  withr::local_options(gh_validate_tokens = NULL)
  withr::local_envvar(GH_VALIDATE_TOKENS = NA)
  rlang::reset_warning_verbosity("gh_invalid_pat")
  expect_warning(out <- gh_pat(bad), "Invalid GitHub PAT format")
  expect_s3_class(out, "gh_pat")
  expect_equal(unclass(out), bad)

  # "off" skips validation, no message of any kind.
  withr::local_options(gh_validate_tokens = "off")
  expect_silent(out <- gh_pat(bad))
  expect_equal(unclass(out), bad)

  # "error" aborts (current pre-default behavior).
  withr::local_options(gh_validate_tokens = "error")
  expect_error(gh_pat(bad), "Invalid GitHub PAT format")

  # Env var is honored when option is unset.
  withr::local_options(gh_validate_tokens = NULL)
  withr::local_envvar(GH_VALIDATE_TOKENS = "error")
  expect_error(gh_pat(bad), "Invalid GitHub PAT format")

  # Option takes precedence over env var (env var still "error" from above).
  withr::local_options(gh_validate_tokens = "off")
  expect_silent(gh_pat(bad))

  # Unknown mode errors loudly.
  withr::local_options(gh_validate_tokens = "bogus")
  expect_error(gh_pat(bad), "Invalid token validation mode")
})

test_that("get_validate_tokens_mode() rejects a setting that isn't a single string", {
  bad <- "definitely-not-a-pat"

  withr::local_options(gh_validate_tokens = c("warn", "error"))
  expect_snapshot(error = TRUE, gh_pat(bad))

  withr::local_options(gh_validate_tokens = 42L)
  expect_snapshot(error = TRUE, gh_pat(bad))

  withr::local_options(gh_validate_tokens = NA_character_)
  expect_snapshot(error = TRUE, gh_pat(bad))
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

test_that("print.gh_pat prints the obfuscated format", {
  pat <- gh_pat(paste0("ghp_", strrep("A", 36)))
  expect_output(print(pat), "ghp_.*\\.\\.\\.")
})

test_that("new_gh_pat rejects non-string input", {
  expect_snapshot(error = TRUE, new_gh_pat(1L))
  expect_snapshot(error = TRUE, new_gh_pat(c("a", "b")))
})

test_that("validate_gh_pat rejects non-gh_pat input", {
  expect_snapshot(error = TRUE, validate_gh_pat("not-a-pat-object"))
})

test_that("gh_auth warns on token containing whitespace", {
  expect_warning(
    out <- gh_auth("token with space"),
    "whitespace"
  )
  expect_equal(unname(out), "token token with space")
})

# URL processing helpers ----
test_that("get_baseurl() insists on http(s)", {
  expect_snapshot(error = TRUE, {
    get_baseurl("github.com")
    get_baseurl("github.acme.com")
  })
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

test_that("tokens can be requested from a Connect server", {
  skip_if_not_installed("connectcreds")

  token <- strrep("a", 40)
  connectcreds::local_mocked_connect_responses(token = token)
  expect_equal(gh_token(), gh_pat(token))
})
