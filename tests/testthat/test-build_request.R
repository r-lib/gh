context("build_request")

test_that("all forms of specifying endpoint are equivalent", {
  r1 <- gh_build_request("GET /rate_limit")
  expect_equal(r1$method, "GET")
  expect_equal(r1$url, "https://api.github.com/rate_limit")

  expect_equal(gh_build_request("/rate_limit"), r1)
  expect_equal(gh_build_request("GET https://api.github.com/rate_limit"), r1)
  expect_equal(gh_build_request("https://api.github.com/rate_limit"), r1)
})
