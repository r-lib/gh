
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

test_that("can use per_page or .per_page but not both", {
  skip_on_cran()
  resp <- gh("/orgs/tidyverse/repos", per_page = 2)
  expect_equal(attr(resp, "request")$query$per_page, 2)

  resp <- gh("/orgs/tidyverse/repos", .per_page = 2)
  expect_equal(attr(resp, "request")$query$per_page, 2)

  expect_snapshot(
    error = TRUE,
    gh("/orgs/tidyverse/repos", per_page = 1, .per_page = 2)
  )
})

test_that("can paginate", {
  skip_on_cran()
  pages <- gh("/orgs/tidyverse/repos", per_page = 1, .limit = 5, .progress = FALSE)
  expect_length(pages, 5)
})

test_that("trim output when .limit isn't a multiple of .per_page", {
  skip_on_cran()
  pages <- gh("/orgs/tidyverse/repos", per_page = 2, .limit = 3, .progress = FALSE)
  expect_length(pages, 3)
})

test_that("can paginate repository search", {
  skip_on_cran()
  pages <- gh("/search/repositories", q = "tidyverse", per_page = 10, .limit = 35)
  expect_named(pages, c("total_count", "incomplete_results", "items"))
  # Eliminates aren't trimmed to .limit in this case
  expect_length(pages$items, 40)
})
