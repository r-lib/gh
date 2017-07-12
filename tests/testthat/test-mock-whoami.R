context("whoami")

test_that("whoami works in presence of PAT", {

  skip_if_offline()
  skip_on_cran()
  skip_if_no_token()
  
  res <- gh_whoami(.token = tt())
  expect_s3_class(res, "gh_response")
  expect_identical(res[["login"]], "gh-testing")
  expect_match(res[["scopes"]], "\\brepo\\b")
  expect_match(res[["scopes"]], "\\buser\\b")
})

test_that("whoami works in absence of PAT", {

  skip_if_offline()
  skip_on_cran()
  
  expect_message(res <- gh_whoami(.token = ""),
                 "No personal access token \\(PAT\\) available.")
  expect_null(res)
})

test_that("whoami errors with bad PAT", {
  skip("re-activate when request matching sorted out (gaborcsardi/httrmock#3)")

  skip_if_offline()
  skip_on_cran()
    
  e <- tryCatch(gh_whoami(.token = NA), error = identity)
  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_401")

  e <- tryCatch(gh_whoami(.token = "blah"), error = identity)
  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_401")
})
