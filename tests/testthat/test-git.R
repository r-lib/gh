test_that("gh_tree_remote returns username and repo for a github remote", {
  repo <- make_git_repo(list(origin = "https://github.com/x/y.git"))
  expect_equal(
    gh_tree_remote(repo),
    list(username = "x", repo = "y")
  )
})

test_that("gh_tree_remote errors when no github remotes are configured", {
  repo <- make_git_repo(list(origin = "https://gitlab.com/x/y.git"))
  expect_snapshot(
    error = TRUE,
    gh_tree_remote(repo),
    transform = transform_tempdir
  )
})

test_that("gh_tree_remote walks up from a subdirectory to find the repo root", {
  repo <- make_git_repo(list(origin = "https://github.com/x/y.git"))
  sub <- file.path(repo, "pkg", "R")
  dir.create(sub, recursive = TRUE)
  expect_equal(
    gh_tree_remote(sub),
    list(username = "x", repo = "y")
  )
})

test_that("git_remotes skips remotes without a url", {
  dir <- withr::local_tempdir()
  dir.create(file.path(dir, ".git"))
  writeLines(
    c(
      '[remote "origin"]',
      "  url = https://github.com/x/y.git",
      '[remote "broken"]',
      "  fetch = +refs/heads/*:refs/remotes/broken/*"
    ),
    file.path(dir, ".git", "config")
  )
  expect_equal(
    git_remotes(dir),
    c(origin = "https://github.com/x/y.git")
  )
})

test_that("git_config errors when .git/config does not exist", {
  dir <- withr::local_tempdir()
  dir.create(file.path(dir, ".git"))
  expect_snapshot(error = TRUE, git_config(dir), transform = transform_tempdir)
})

test_that("repo_root errors on a path that does not exist", {
  expect_snapshot(
    error = TRUE,
    repo_root(file.path(tempdir(), "does-not-exist-xyz")),
    transform = transform_tempdir
  )
})

test_that("repo_root errors when no git root is found", {
  dir <- withr::local_tempdir()
  expect_snapshot(error = TRUE, repo_root(dir), transform = transform_tempdir)
})

test_that("picks origin if available", {
  remotes <- list(
    upstream = "https://github.com/x/1",
    origin = "https://github.com/x/2"
  )

  expect_warning(gr <- github_remote(remotes, "."), "Using origin")
  expect_equal(gr$repo, "2")
})

test_that("otherwise picks first", {
  remotes <- list(
    a = "https://github.com/x/1",
    b = "https://github.com/x/2"
  )

  expect_warning(gr <- github_remote(remotes, "."), "Using first")
  expect_equal(gr$repo, "1")
})


# Parsing -----------------------------------------------------------------

test_that("parses common url forms", {
  expected <- list(username = "x", repo = "y")

  expect_equal(github_remote_parse("https://github.com/x/y.git"), expected)
  expect_equal(github_remote_parse("https://github.com/x/y"), expected)
  expect_equal(github_remote_parse("git@github.com:x/y.git"), expected)
})

test_that("returns NULL if can't parse", {
  expect_equal(github_remote_parse("blah"), NULL)
})

test_that("github_remote_parse returns NULL for zero-length input", {
  expect_null(github_remote_parse(character(0)))
})

test_that("github_remote_parse returns NULL when regex doesn't match", {
  expect_null(github_remote_parse("github"))
})

test_that("github_remote returns the single remote unchanged", {
  remotes <- list(origin = "https://github.com/x/y.git")
  expect_silent(gr <- github_remote(remotes, "."))
  expect_equal(gr, list(username = "x", repo = "y"))
})
