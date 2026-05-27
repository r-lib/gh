test_that("good input", {
  mock_res <- structure(
    list(),
    class = "gh_response",
    response = list(
      "x-ratelimit-limit" = "5000",
      "x-ratelimit-remaining" = "4999",
      "x-ratelimit-reset" = "1580507619"
    )
  )

  limit <- gh_rate_limit(mock_res)

  expect_equal(limit$limit, 5000L)
  expect_equal(limit$remaining, 4999L)
  expect_s3_class(limit$reset, "POSIXct") # Avoiding tz issues
})

test_that("errors", {
  local_fake_github()
  expect_snapshot(error = TRUE, {
    gh_rate_limit(list())
    gh_rate_limits(.token = "bad")
  })
})

test_that("gh_rate_limit fetches from /rate_limit when no response is passed", {
  local_fake_github()
  limit <- gh_rate_limit()
  expect_equal(limit$limit, 5000L)
  expect_equal(limit$remaining, 5000L)
  expect_s3_class(limit$reset, "POSIXct")
})

test_that("gh_rate_limits returns a data frame of all resource limits", {
  local_fake_github()
  limits <- gh_rate_limits()
  expect_s3_class(limits, "data.frame")
  expect_setequal(
    limits$type,
    c(
      "core",
      "search",
      "graphql",
      "integration_manifest",
      "code_scanning_upload"
    )
  )
  expect_true(all(limits$limit == 5000L))
  expect_true(all(limits$used == 0L))
  expect_true(all(limits$remaining == 5000L))
  expect_s3_class(limits$reset, "POSIXct")
  expect_type(limits$mins_left, "double")
})

test_that("missing rate limit", {
  mock_res <- structure(
    list(),
    class = "gh_response",
    response = list()
  )

  limit <- gh_rate_limit(mock_res)

  expect_equal(limit$limit, NA_integer_)
  expect_equal(limit$remaining, NA_integer_)
  expect_equal(as.double(limit$reset), NA_real_)
})
