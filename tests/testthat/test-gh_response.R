test_that("can retrieve empty GET query", {
  out <- gh("GET /orgs/{org}/repos", org = "gh-org-testing-no-repos")
  expect_equal(out, list(), ignore_attr = TRUE)
})
