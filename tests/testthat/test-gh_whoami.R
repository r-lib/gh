test_that("whoami works in presence of PAT", {
  skip_if_no_github(has_scope = "user")

  res <- gh_whoami()
  expect_s3_class(res, "gh_response")
  expect_match(res[["scopes"]], "\\buser\\b")
})

test_that("whoami errors with bad/absent PAT", {
  skip_if_no_github()
  skip_on_ci() # since no token sometimes fails due to rate-limiting

  expect_snapshot(error = TRUE, {
    gh_whoami(.token = "")
    gh_whoami(.token = NA)
    gh_whoami(.token = "blah")
  })
})
