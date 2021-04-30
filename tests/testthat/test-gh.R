
test_that(".params works", {
  reqs <- list()
  mockery::stub(gh, "gh_build_request", function(...) {
    reqs <<- c(reqs, list(gh_build_request(...)))
    stop("just this")
  })

  expect_error(
    gh("POST /repos/:org/:repo/issues/:number/labels",
       org = "ORG", repo = "REPO", number = "1")
  )

  expect_error(
    gh("POST /repos/:org/:repo/issues/:number/labels",
       org = "ORG", repo = "REPO", .params = list(number = "1"))
  )

  expect_error(
    gh("POST /repos/:org/:repo/issues/:number/labels",
       .params = list(org = "ORG", repo = "REPO", number = "1"))
  )

  expect_identical(reqs[[1]], reqs[[2]])
  expect_identical(reqs[[2]], reqs[[3]])
})
