test_that("whoami works in presence of PAT", {
  skip_if_offline("github.com")
  skip_on_cran()
  skip_if_no_token()

  res <- gh_whoami()
  expect_s3_class(res, "gh_response")
  expect_match(res[["scopes"]], "\\brepo\\b")
  expect_match(res[["scopes"]], "\\buser\\b")
})

test_that("whoami works in absence of PAT", {
  skip_if_offline("github.com")
  skip_on_cran()

  expect_message(
    res <- gh_whoami(.token = ""),
    "No personal access token \\(PAT\\) available."
  )
  expect_null(res)
})

test_that("whoami errors with bad PAT", {
  skip_if_offline("github.com")
  skip_on_cran()

  expect_snapshot(error = TRUE, {
    gh_whoami(.token = NA)
    gh_whoami(.token = "blah")
  })
})
