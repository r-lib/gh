if (!exists("TMPL", environment(), inherits = FALSE)) {
  TMPL <- function(x) x
}

test_that("repos, some basics", {

  skip_if_offline("github.com")
  skip_on_cran()
  skip_if_no_token()

  res <- gh("/user/repos", .token = tt())
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh(
    TMPL("/users/{username}/repos"),
    username = "gaborcsardi",
    .token = tt()
  )
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh(
    TMPL("/orgs/{org}/repos"),
    org = "r-lib",
    type = "sources",
    .token = tt()
  )
  expect_true("desc" %in% vapply(res, "[[", "name", FUN.VALUE = ""))

  res <- gh("/repositories", .token = tt())
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  test_repo <- basename(tempfile("gh-testing-"))

  res <- gh(
    "POST /user/repos",
    name = test_repo,
    description = "Test repo for gh",
    homepage = "https://github.com/r-lib/gh",
    private = FALSE,
    has_issues = FALSE,
    has_wiki = FALSE,
    .token = tt()
  )
  expect_equal(res$name, test_repo)
  expect_equal(res$description, "Test repo for gh")
  expect_equal(res$homepage, "https://github.com/r-lib/gh")
  expect_false(res$private)
  expect_false(res$has_issues)
  expect_false(res$has_wiki)

  ## TODO: POST /orgs/{org}/repos

  Sys.sleep(2)
  res <- gh(
    TMPL("/repos/{owner}/{repo}"),
    owner = "gh-testing",
    repo = test_repo,
    .token = tt()
  )
  expect_equal(res$name, test_repo)
  expect_equal(res$description, "Test repo for gh")
  expect_equal(res$homepage, "https://github.com/r-lib/gh")
  expect_false(res$private)
  expect_false(res$has_issues)
  expect_false(res$has_wiki)

  res <- gh(
    TMPL("PATCH /repos/{owner}/{repo}"),
    owner = "gh-testing",
    repo = test_repo,
    name = test_repo,
    description = "Still a test repo",
    .token = tt()
  )
  expect_equal(res$name, test_repo)
  expect_equal(res$description, "Still a test repo")

  res <- gh(
    TMPL("GET /repos/{owner}/{repo}/contributors"),
    owner = "gh-testing",
    repo = "myrepo",
    .token = tt()
  )
  expect_true("gh-testing" %in% vapply(res, "[[", "", "login"))

  res <- gh(
    TMPL("GET /repos/{owner}/{repo}/languages"),
    owner = "r-lib",
    repo = "desc",
    .token = tt()
  )
  expect_true("R" %in% names(res))

  ## TODO: GET /repos/{owner}/{repo}/teams does not seem to work

  res <- gh(
    TMPL("GET /repos/{owner}/{repo}/teams"),
    owner = "gh-testing-org",
    repo = "org-repo",
    .token = tt()
  )
  expect_true("myteam" %in% vapply(res, "[[", "", "name"))

  res <- gh(
    TMPL("GET /repos/{owner}/{repo}/tags"),
    owner = "gh-testing",
    repo = "myrepo",
    .token = tt()
  )
  expect_true(res[[1]]$name == "v0.0.1")

  res <- gh(
    TMPL("DELETE /repos/{owner}/{repo}"),
    owner = "gh-testing",
    repo = test_repo,
    .token = tt()
  )
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
    .send_headers = c(Accept = "application/vnd.github.v3.raw"),
    .token = tt()
  )

  expect_equal(attr(res, "response")[["x-github-media-type"]],
               "github.v3; param=raw")
  expect_equal(class(res), c("gh_response", "raw"))

  tmp <- tempfile()
  res <- gh(
    TMPL("/orgs/{org}/repos"),
    org = "r-lib",
    type = "sources",
    .token = tt()
  )
  res_file <- gh(
    TMPL("/orgs/{org}/repos"),
    org = "r-lib",
    type = "sources",
    .destfile = tmp,
    .token = tt()
  )
  expect_equal(class(res_file), c("gh_response", "path"))
  expect_equivalent(res, jsonlite::fromJSON(res_file,  simplifyVector = FALSE))

  })
