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

test_that("can ignore trailing commas", {
  skip_on_cran()
  expect_no_error(gh("/orgs/tidyverse/repos", ))
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
  pages <- gh(
    "/orgs/tidyverse/repos",
    per_page = 1,
    .limit = 5,
    .progress = FALSE
  )
  expect_length(pages, 5)
})

test_that("trim output when .limit isn't a multiple of .per_page", {
  skip_on_cran()
  pages <- gh(
    "/orgs/tidyverse/repos",
    per_page = 2,
    .limit = 3,
    .progress = FALSE
  )
  expect_length(pages, 3)
})

test_that("can paginate repository search", {
  skip_on_cran()
  # we need to run this sparingly, otherwise we'll get rate
  # limited and the test fails
  skip_on_ci()
  pages <- gh(
    "/search/repositories",
    q = "tidyverse",
    per_page = 10,
    .limit = 35
  )
  expect_named(pages, c("total_count", "incomplete_results", "items"))
  # Eliminates aren't trimmed to .limit in this case
  expect_length(pages$items, 40)
})
