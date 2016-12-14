
context("repos")

test_that("repos, some basics", {

  res <- gh("/user/repos")
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh("/users/:username/repos", username = "gaborcsardi")
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh("/orgs/:org/repos", org = "r-pkgs", type = "sources")
  expect_true("desc" %in% vapply(res, "[[", "name", FUN.VALUE = ""))

  res <- gh("/repositories")
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh(
    "POST /user/repos",
    name = "gh-testing",
    description = "Test repo for gh",
    homepage = "https://github.com/r-pkgs/gh",
    private = FALSE,
    has_issues = FALSE,
    has_wiki = FALSE
  )
  expect_equal(res$name, "gh-testing")
  expect_equal(res$description, "Test repo for gh")
  expect_equal(res$homepage, "https://github.com/r-pkgs/gh")
  expect_false(res$private)
  expect_false(res$has_issues)
  expect_false(res$has_wiki)

  ## TODO: POST /orgs/:org/repos

  res <- gh(
    "/repos/:owner/:repo",
    owner = gh_test_owner,
    repo = "gh-testing"
  )
  expect_equal(res$name, "gh-testing")
  expect_equal(res$description, "Test repo for gh")
  expect_equal(res$homepage, "https://github.com/r-pkgs/gh")
  expect_false(res$private)
  expect_false(res$has_issues)
  expect_false(res$has_wiki)

  res <- gh(
    "PATCH /repos/:owner/:repo",
    owner = gh_test_owner,
    repo = "gh-testing",
    name = "gh-testing",
    description = "Still a test repo"
  )
  expect_equal(res$name, "gh-testing")
  expect_equal(res$description, "Still a test repo")

  res <- gh(
    "GET /repos/:owner/:repo/contributors",
    owner = gh_test_owner,
    repo = "myrepo"
  )
  expect_true("gh-testing" %in% vapply(res, "[[", "", "login"))

  res <- gh(
    "GET /repos/:owner/:repo/languages",
    owner = "r-pkgs",
    repo = "desc"
  )
  expect_true("R" %in% names(res))

  ## TODO: GET /repos/:owner/:repo/teams does not seem to work

  res <- gh(
    "GET /repos/:owner/:repo/teams",
    owner = "gh-testing-org",
    repo = "org-repo"
  )
  expect_true("myteam" %in% vapply(res, "[[", "", "name"))

  res <- gh(
    "GET /repos/:owner/:repo/tags",
    owner = "gh-testing",
    repo = "myrepo"
  )
  expect_true(res[[1]]$name == "v0.0.1")

  res <- gh(
    "DELETE /repos/:owner/:repo",
    owner = "gh-testing",
    repo = "gh-testing"
  )
  expect_equal(res[[1]], "")            # TODO: better return value here?
})
