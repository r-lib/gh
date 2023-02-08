test_that("works with empty bodies", {
  skip_if_offline("github.com")
  skip_on_cran()
  skip_if_no_token()

  out <- gh("GET /orgs/{org}/repos", org = "gh-org-testing-no-repos")
  expect_equal(out, list(), ignore_attr = TRUE)

  out <- gh("POST /markdown", text = "")
  expect_equal(out, list(), ignore_attr = TRUE)

  out <- gh("POST /gists", files = list(x = list(content = "y")), public = FALSE)
  out <- gh("DELETE /gists/{gist_id}", gist_id = out$id)
  expect_equal(out, list(), ignore_attr = TRUE)
})

test_that("can get raw response", {
  skip_if_offline("github.com")
  skip_on_cran()
  skip_if_no_token()

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
  skip_if_offline("github.com")
  skip_on_cran()
  skip_if_no_token()

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
  expect_snapshot(res <- gh("POST /markdown", text = "foo"))

  expect_equal(res, list(message = "<p>foo</p>\n"), ignore_attr = TRUE)
  expect_equal(class(res), c("gh_response", "list"))
})
