context("github_error")

test_that("errors return a github_error object", {

  skip_if_offline()
  skip_on_cran()
  
  e <- tryCatch(gh("/missing", .token = tt()), error = identity)

  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_404")
})

test_that("can catch a given status directly", {

  skip_if_offline()
  skip_on_cran()
  
  e <- tryCatch(
    gh("/missing", .token = tt()),
    "http_error_404" = identity
  )

  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_404")
})
