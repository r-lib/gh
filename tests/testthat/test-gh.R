
test_that(".params works", {
  reqs <- list()
  mockery::stub(gh, "gh_build_request", function(...) {
    reqs <<- c(reqs, list(gh_build_request(...)))
    stop("just this")
  })

  expect_error(
    gh("POST /repos/:org/:repo/issues/:number/labels",
      org = "ORG", repo = "REPO", number = "1"
    )
  )

  expect_error(
    gh("POST /repos/:org/:repo/issues/:number/labels",
      org = "ORG", repo = "REPO", .params = list(number = "1")
    )
  )

  expect_error(
    gh("POST /repos/:org/:repo/issues/:number/labels",
      .params = list(org = "ORG", repo = "REPO", number = "1")
    )
  )

  expect_identical(reqs[[1]], reqs[[2]])
  expect_identical(reqs[[2]], reqs[[3]])
})

test_that("generates a useful message", {
  skip_if_no_github()

  expect_snapshot(gh("/missing"), error = TRUE)
})

test_that("errors return a github_error object", {
  skip_if_no_github()

  e <- tryCatch(gh("/missing"), error = identity)

  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_404")
})

test_that("can catch a given status directly", {
  skip_if_no_github()

  e <- tryCatch(gh("/missing"), "http_error_404" = identity)

  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_404")
})
