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

test_that("parameter substitution is equivalent to direct specification (:)", {
  subst <-
    gh_build_request("POST /repos/:org/:repo/issues/:number/labels",
                     params = list(org = "ORG", repo = "REPO", number = "1",
                                   "body"))
  spec <-
    gh_build_request("POST /repos/ORG/REPO/issues/1/labels",
                     params = list("body"))
  expect_identical(subst, spec)
})

test_that("parameter substitution is equivalent to direct specification", {
  subst <-
    gh_build_request("POST /repos/{org}/{repo}/issues/{number}/labels",
                     params = list(org = "ORG", repo = "REPO", number = "1",
                                   "body"))
  spec <-
    gh_build_request("POST /repos/ORG/REPO/issues/1/labels",
                     params = list("body"))
  expect_identical(subst, spec)
})

test_that("URI templates that need expansion are detected", {
  expect_true(is_uri_template("/orgs/{org}/repos"))
  expect_true(is_uri_template("/repos/{owner}/{repo}"))
  expect_false(is_uri_template("/user/repos"))
})

test_that("older 'colon templates' are detected", {
  expect_true(is_colon_template("/orgs/:org/repos"))
  expect_true(is_colon_template("/repos/:owner/:repo"))
  expect_false(is_colon_template("/user/repos"))
})

test_that("gh_set_endpoint() works", {
  # no expansion, no extra params
  input <- list(endpoint = "/user/repos")
  expect_equal(input, gh_set_endpoint(input))

  # no expansion, with extra params
  input <- list(endpoint = "/user/repos", params = list(page = 2))
  expect_equal(input, gh_set_endpoint(input))

  # expansion, no extra params
  input <- list(
    endpoint = "/repos/{owner}/{repo}",
    params = list(owner = "OWNER", repo = "REPO")
  )
  out <- gh_set_endpoint(input)
  expect_equal(
    out,
    list(endpoint = "/repos/OWNER/REPO", params = list())
  )

  # expansion, with extra params
  input <- list(
    endpoint = "/repos/{owner}/{repo}/issues",
    params = list(state = "open", owner = "OWNER", repo = "REPO", page = 2)
  )
  out <- gh_set_endpoint(input)
  expect_equal(out$endpoint, "/repos/OWNER/REPO/issues")
  expect_equal(out$params, list(state = "open", page = 2))
})

test_that("gh_set_endpoint() refuses to substitute an NA", {
  input <- list(
    endpoint = "POST /orgs/{org}/repos",
    params = list(org = NA)
  )
  expect_error(gh_set_endpoint(input), "Named NA")
})

test_that("gh_set_endpoint() allows a named NA in body for non-GET", {
  input <- list(
    endpoint = "PUT /repos/{owner}/{repo}/pages",
    params = list(owner = "OWNER", repo = "REPO", cname = NA)
  )
  out <- gh_set_endpoint(input)
  expect_equal(out$endpoint, "PUT /repos/OWNER/REPO/pages")
  expect_equal(out$params, list(cname = NA))
})

test_that("gh_set_url() ensures URL is in 'API form'", {
  input <- list(
    endpoint = "/user/repos",
    api_url = "https://github.com"
  )
  out <- gh_set_url(input)
  expect_equal(out$api_url, "https://api.github.com")

  input$api_url <- "https://github.acme.com"
  out <- gh_set_url(input)
  expect_equal(out$api_url, "https://github.acme.com/api/v3")
})
