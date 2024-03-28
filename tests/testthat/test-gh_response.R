test_that("works with empty bodies", {
  skip_if_no_github()

  out <- gh("GET /orgs/{org}/repos", org = "gh-org-testing-no-repos")
  expect_equal(out, list(), ignore_attr = TRUE)

  out <- gh("POST /markdown", text = "")
  expect_equal(out, list(), ignore_attr = TRUE)
})

test_that("works with empty bodies from DELETE", {
  skip_if_no_github(has_scope = "gist")

  out <- gh("POST /gists", files = list(x = list(content = "y")), public = FALSE)
  out <- gh("DELETE /gists/{gist_id}", gist_id = out$id)
  expect_equal(out, list(), ignore_attr = TRUE)
})

test_that("can get raw response", {
  skip_if_no_github()

  res <- gh(
    "GET /repos/{owner}/{repo}/contents/{path}",
    owner = "r-lib",
    repo = "gh",
    path = "DESCRIPTION",
    .send_headers = c(Accept = "application/vnd.github.v3.raw")
  )

  expect_equal(
    attr(res, "response")[["x-github-media-type"]],
    "github.v3; param=raw"
  )
  expect_equal(class(res), c("gh_response", "raw"))
})

test_that("can download files", {
  skip_if_no_github()

  tmp <- withr::local_tempfile()
  res_file <- gh(
    "/orgs/{org}/repos",
    org = "r-lib",
    type = "sources",
    .destfile = tmp
  )
  expect_equal(class(res_file), c("gh_response", "path"))
  expect_equal(res_file, tmp, ignore_attr = TRUE)
})

test_that("warns if output is HTML", {
  skip_on_cran()
  expect_snapshot(res <- gh("POST /markdown", text = "foo"))

  expect_equal(res, list(message = "<p>foo</p>\n"), ignore_attr = TRUE)
  expect_equal(class(res), c("gh_response", "list"))
})

test_that("captures details to recreate request", {
  skip_on_cran()
  res <- gh("/orgs/{org}/repos", org = "r-lib", .per_page = 1)

  req <- attr(res, "request")
  expect_type(req, "list")
  expect_equal(req$url, "https://api.github.com/orgs/r-lib/repos")
  expect_equal(req$query, list(per_page = 1))

  # For backwards compatibility
  expect_equal(attr(res, "method"), "GET")
  expect_type(attr(res, ".send_headers"), "list")
})

test_that("output file is not overwritten on error", {
  tmp <- withr::local_tempfile()
  writeLines("foo", tmp)

  err <- tryCatch(
    gh("/repos", .destfile = tmp),
    error = function(e) e
  )

  expect_true(file.exists(tmp))
  expect_equal(readLines(tmp), "foo")
  expect_true(!is.null((err$response_content)))
})
