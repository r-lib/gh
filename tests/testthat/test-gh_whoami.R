test_that("whoami works in presence of PAT", {
  skip_if_offline("github.com")
  skip_on_cran()
  skip_on_ci() # no active user in GHA
  skip_if_no_token()

  res <- gh_whoami()
  expect_s3_class(res, "gh_response")
  expect_match(res[["scopes"]], "\\brepo\\b")
  expect_match(res[["scopes"]], "\\buser\\b")
})

test_that("whoami errors with bad/absent PAT", {
  skip_if_offline("github.com")
  skip_on_cran()

  expect_snapshot(error = TRUE, {
    gh_whoami(.token = "")
    gh_whoami(.token = NA)
    gh_whoami(.token = "blah")
  })
})
