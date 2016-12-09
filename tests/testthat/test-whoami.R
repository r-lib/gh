context("whoami")

test_that("whoami works in presence of PAT", {
  skip_on_travis()
  skip_on_appveyor()
  res <- gh_whoami()
  res$token <- NULL
  expect_equivalent(
    res,
    list(name = "Jennifer (Jenny) Bryan",
         login = "jennybc",
         html_url = "https://github.com/jennybc",
         scopes = "admin:org, admin:public_key, admin:repo_hook, delete_repo, gist, notifications, repo, user"))
})

test_that("whoami works in absence of PAT", {
  expect_message(res <- gh_whoami(.token = ""),
                 "No personal access token \\(PAT\\) available.")
  expect_null(res)
})

test_that("whoami errors with bad PAT", {
  expect_error(res <- gh_whoami(.token = NA), "Requires authentication")
  expect_error(res <- gh_whoami(.token = "blah"), "Bad credentials")
})
