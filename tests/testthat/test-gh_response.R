test_that("gh_process_response errors on non-httr2_response input", {
  expect_snapshot(error = TRUE, gh_process_response(list(), list()))
})

test_that("works with empty bodies", {
  local_fake_github()
  out <- gh("GET /orgs/{org}/repos", org = "gh-org-testing-no-repos")
  expect_equal(out, list(), ignore_attr = TRUE)

  out <- gh("POST /markdown", text = "")
  expect_equal(out, list(), ignore_attr = TRUE)
})

test_that("handles 304 Not Modified (#219)", {
  local_fake_github()
  withr::local_options(gh_cache = FALSE)

  res <- gh("/users/{user}/repos", user = "hadley", .limit = 2)
  etag <- attr(res, "response")$etag
  expect_false(is.null(etag))

  res2 <- gh(
    "/users/{user}/repos",
    user = "hadley",
    .limit = 2,
    .send_headers = c("If-None-Match" = etag)
  )
  expect_equal(res2, list(), ignore_attr = TRUE)
  expect_s3_class(res2, "gh_response")
  expect_equal(attr(res2, "response")$etag, etag)
})

test_that("works with empty bodies from DELETE", {
  local_fake_github()
  out <- gh(
    "POST /gists",
    files = list(x = list(content = "y")),
    public = FALSE
  )
  out <- gh("DELETE /gists/{gist_id}", gist_id = out$id)
  expect_equal(out, list(), ignore_attr = TRUE)
})

test_that("can get raw response", {
  local_fake_github()
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
  local_fake_github()
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
  local_fake_github()
  expect_snapshot(res <- gh("POST /markdown", text = "foo"))

  expect_equal(res, list(message = "<p>foo</p>\n"), ignore_attr = TRUE)
  expect_equal(class(res), c("gh_response", "list"))
})

test_that("captures details to recreate request", {
  local_fake_github()
  res <- gh("/orgs/{org}/repos", org = "r-lib", .per_page = 1)

  req <- attr(res, "request")
  expect_type(req, "list")
  expect_match(req$url, "/orgs/r-lib/repos$")
  expect_equal(req$query, list(per_page = 1))
})

test_that("output file is not overwritten on error", {
  local_fake_github()
  tmp <- withr::local_tempfile()
  writeLines("foo", tmp)

  err <- tryCatch(
    gh("/missing", .destfile = tmp),
    error = function(e) e
  )

  expect_true(file.exists(tmp))
  expect_equal(readLines(tmp), "foo")
  expect_true(!is.null((err$response_content)))
})


test_that("gh_response objects can be combined via vctrs #161", {
  local_fake_github()
  skip_if_not_installed("vctrs")
  user_1 <- gh("/users", .limit = 1)
  user_2 <- gh("/users", .limit = 1, )
  user_vec <- vctrs::vec_c(user_1, user_2)
  user_df <- vctrs::vec_rbind(user_1[[1]], user_2[[1]])
  expect_equal(length(user_vec), 2)
  expect_equal(nrow(user_df), 2)
})
