if (!exists("TMPL", environment(), inherits = FALSE)) {
  TMPL <- function(x) x
}

test_that("repos, some basics", {
  skip_if_offline("github.com")
  skip_on_cran()
  skip_if_no_token()

  res <- gh("/user/repos")
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh(
    TMPL("/users/{username}/repos"),
    username = "gaborcsardi"
  )
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh(
    TMPL("/orgs/{org}/repos"),
    org = "r-lib",
    type = "sources"
  )
  expect_true("desc" %in% vapply(res, "[[", "name", FUN.VALUE = ""))

  res <- gh("/repositories")
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))
})

test_that("can POST, PATCH, and DELETE", {
  skip_if_offline("github.com")
  skip_on_cran()
  skip_if_no_token()

  res <- gh(
    "POST /gists",
    files = list(test.R = list(content = "test")),
    description = "A test gist for gh",
    public = FALSE
  )
  expect_equal(res$description, "A test gist for gh")
  expect_false(res$public)

  res <- gh(
    TMPL("PATCH /gists/{gist_id}"),
    gist_id = res$id,
    description = "Still a test repo"
  )
  expect_equal(res$description, "Still a test repo")

  res <- gh(
    TMPL("DELETE /gists/{gist_id}"),
    gist_id = res$id
  )
  expect_s3_class(res, c("gh_response", "list"))
})

test_that("repo files", {
  skip_if_offline("github.com")
  skip_on_cran()
  skip_if_no_token()

  res <- gh(
    TMPL("GET /repos/{owner}/{repo}/contents/{path}"),
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

  tmp <- tempfile()
  res <- gh(
    TMPL("/orgs/{org}/repos"),
    org = "r-lib",
    type = "sources"
  )
  res_file <- gh(
    TMPL("/orgs/{org}/repos"),
    org = "r-lib",
    type = "sources",
    .destfile = tmp
  )
  expect_equal(class(res_file), c("gh_response", "path"))
  expect_equal(res, jsonlite::fromJSON(res_file, simplifyVector = FALSE), ignore_attr = TRUE)
})
