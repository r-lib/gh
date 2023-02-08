if (!exists("TMPL", environment(), inherits = FALSE)) {
  TMPL <- function(x) x
}

test_that("repos, some basics", {
  skip_if_no_github()

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
  skip_if_no_github(has_scope = "gist")

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
