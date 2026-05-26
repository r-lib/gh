test_that("whoami works in presence of PAT", {
  local_fake_github()
  res <- gh_whoami()
  expect_s3_class(res, "gh_response")
  expect_match(res[["scopes"]], "\\buser\\b")
})

test_that("whoami errors with bad/absent PAT", {
  local_fake_github()
  expect_snapshot(error = TRUE, {
    gh_whoami(.token = "")
    gh_whoami(.token = NA)
    gh_whoami(.token = "blah")
  })
})
