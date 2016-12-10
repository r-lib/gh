context("whoami")

test_that("whoami works in presence of PAT", {
  ## being explicit re token because GITHUB_PAT > GITHUB_TOKEN in gh_token()
  ## don't want developer's GITHUB_PAT to override gh-testing's GITHUB_TOKEN
  res <- gh_whoami(Sys.getenv("GITHUB_TOKEN"))
  expect_s3_class(res, "gh_response")
  expect_identical(res[["login"]], "gh-testing")
  expect_match(res[["scopes"]], "\\brepo\\b")
  expect_match(res[["scopes"]], "\\buser\\b")
})

test_that("whoami works in absence of PAT", {
  expect_message(res <- gh_whoami(.token = ""),
                 "No personal access token \\(PAT\\) available.")
  expect_null(res)
})

test_that("whoami errors with bad PAT", {
  skip("re-activate when request matching sorted out (gaborcsardi/httrmock#3)")

  e <- tryCatch(gh_whoami(.token = NA), error = identity)
  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_401")

  e <- tryCatch(gh_whoami(.token = "blah"), error = identity)
  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_401")
})
