test_that("good input", {
  mock_res <- structure(
    list(),
    class = "gh_response",
    response = list(
      "x-ratelimit-limit"     =  "5000",
      "x-ratelimit-remaining" =  "4999",
      "x-ratelimit-reset"     =  "1580507619"
    )
  )

  limit <- gh_rate_limit(mock_res)

  expect_equal(limit$limit, 5000L)
  expect_equal(limit$remaining, 4999L)
  expect_s3_class(limit$reset, "POSIXct") # Avoiding tz issues
})

test_that("errors", {
  expect_error(gh_rate_limit(list()))
  expect_error(gh_rate_limit(.token = "bad"))
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
