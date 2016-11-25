context("build_request")

test_that("all forms of specifying endpoint are equivalent", {
  r1 <- gh_build_request("GET /rate_limit")
  expect_equal(r1$method, "GET")
  expect_equal(r1$url, "https://api.github.com/rate_limit")

  expect_equal(gh_build_request("/rate_limit"), r1)
  expect_equal(gh_build_request("GET https://api.github.com/rate_limit"), r1)
  expect_equal(gh_build_request("https://api.github.com/rate_limit"), r1)
})

test_that("method arg sets default method", {
  r <- gh_build_request("/rate_limit", method = "POST")
  expect_equal(r$method, "POST")
})

test_that("parameter substitution is equivalent to direct specification", {
  subst <-
    gh_build_request("POST /repos/:org/:repo/issues/:number/labels",
                     params = list(org = "ORG", repo = "REPO", number = "1",
                                   "body"))
  spec <-
    gh_build_request("POST /repos/ORG/REPO/issues/1/labels",
                     params = list("body"))
  expect_identical(subst, spec)
})
