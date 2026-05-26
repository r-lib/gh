test_that("generates a useful message", {
  local_fake_github()
  expect_snapshot(
    gh("/missing"),
    error = TRUE,
    transform = redact_fake_host
  )
})

test_that("errors return a github_error object", {
  local_fake_github()
  e <- tryCatch(gh("/missing"), error = identity)

  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_404")
})

test_that("can catch a given status directly", {
  local_fake_github()
  e <- tryCatch(gh("/missing"), "http_error_404" = identity)

  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_404")
})

test_that("can ignore trailing commas", {
  local_fake_github()
  expect_no_error(gh("/orgs/tidyverse/repos", ))
})

test_that("can use per_page or .per_page but not both", {
  local_fake_github()
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
  local_fake_github()
  pages <- gh(
    "/orgs/tidyverse/repos",
    per_page = 1,
    .limit = 5,
    .progress = FALSE
  )
  expect_length(pages, 5)
})

test_that("trim output when .limit isn't a multiple of .per_page", {
  local_fake_github()
  pages <- gh(
    "/orgs/tidyverse/repos",
    per_page = 2,
    .limit = 3,
    .progress = FALSE
  )
  expect_length(pages, 3)
})

test_that("can paginate repository search", {
  local_fake_github()
  pages <- gh(
    "/search/repositories",
    q = "tidyverse",
    per_page = 10,
    .limit = 35
  )
  expect_named(pages, c("total_count", "incomplete_results", "items"))
  # Items aren't trimmed to .limit in this case
  expect_length(pages$items, 40)
})
