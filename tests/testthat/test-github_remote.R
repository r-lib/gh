context("github_remote")

test_that("picks origin if available", {
  remotes <- list(
    upstream = "https://github.com/x/1",
    origin = "https://github.com/x/2"
  )

  expect_warning(gr <- github_remote(remotes), "Using origin")
  expect_equal(gr$repo, "2")
})

test_that("otherwise picks first", {
  remotes <- list(
    a = "https://github.com/x/1",
    b = "https://github.com/x/2"
  )

  expect_warning(gr <- github_remote(remotes), "Using first")
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
