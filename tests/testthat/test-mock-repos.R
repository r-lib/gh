
context("repos")

test_that("repos, some basics", {

  skip_if_offline()
  skip_on_cran()
  skip("needs mocking")
  
  res <- gh("/user/repos", .token = tt())
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh("/users/:username/repos", username = "gaborcsardi", .token = tt())
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh("/orgs/:org/repos", org = "r-lib", type = "sources", .token = tt())
  expect_true("desc" %in% vapply(res, "[[", "name", FUN.VALUE = ""))

  res <- gh("/repositories", .token = tt())
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh(
    "POST /user/repos",
    name = "gh-testing",
    description = "Test repo for gh",
    homepage = "https://github.com/r-lib/gh",
    private = FALSE,
    has_issues = FALSE,
    has_wiki = FALSE,
    .token = tt()
  )
  expect_equal(res$name, "gh-testing")
  expect_equal(res$description, "Test repo for gh")
  expect_equal(res$homepage, "https://github.com/r-lib/gh")
  expect_false(res$private)
  expect_false(res$has_issues)
  expect_false(res$has_wiki)

  ## TODO: POST /orgs/:org/repos

  res <- gh(
    "/repos/:owner/:repo",
    owner = gh_test_owner,
    repo = "gh-testing",
    .token = tt()
  )
  expect_equal(res$name, "gh-testing")
  expect_equal(res$description, "Test repo for gh")
  expect_equal(res$homepage, "https://github.com/r-lib/gh")
  expect_false(res$private)
  expect_false(res$has_issues)
  expect_false(res$has_wiki)

  res <- gh(
    "PATCH /repos/:owner/:repo",
    owner = gh_test_owner,
    repo = "gh-testing",
    name = "gh-testing",
    description = "Still a test repo",
    .token = tt()
  )
  expect_equal(res$name, "gh-testing")
  expect_equal(res$description, "Still a test repo")

  res <- gh(
    "GET /repos/:owner/:repo/contributors",
    owner = gh_test_owner,
    repo = "myrepo",
    .token = tt()
  )
  expect_true("gh-testing" %in% vapply(res, "[[", "", "login"))

  res <- gh(
    "GET /repos/:owner/:repo/languages",
    owner = "r-lib",
    repo = "desc",
    .token = tt()
  )
  expect_true("R" %in% names(res))

  ## TODO: GET /repos/:owner/:repo/teams does not seem to work

  res <- gh(
    "GET /repos/:owner/:repo/teams",
    owner = "gh-testing-org",
    repo = "org-repo",
    .token = tt()
  )
  expect_true("myteam" %in% vapply(res, "[[", "", "name"))

  res <- gh(
    "GET /repos/:owner/:repo/tags",
    owner = "gh-testing",
    repo = "myrepo",
    .token = tt()
  )
  expect_true(res[[1]]$name == "v0.0.1")

  res <- gh(
    "DELETE /repos/:owner/:repo",
    owner = "gh-testing",
    repo = "gh-testing",
    .token = tt()
  )
  expect_equal(res[[1]], "")            # TODO: better return value here?
})
