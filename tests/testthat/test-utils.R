test_that("can detect presence vs absence names", {
  expect_identical(has_name(list("foo", "bar")), c(FALSE, FALSE))
  expect_identical(has_name(list(a = "foo", "bar")), c(TRUE, FALSE))

  expect_identical(
    has_name({
      x <- list("foo", "bar")
      names(x)[1] <- "a"
      x
    }),
    c(TRUE, FALSE)
  )
  expect_identical(
    has_name({
      x <- list("foo", "bar")
      names(x)[1] <- "a"
      names(x)[2] <- ""
      x
    }),
    c(TRUE, FALSE)
  )

  expect_identical(
    has_name({
      x <- list("foo", "bar")
      names(x)[1] <- ""
      x
    }),
    c(FALSE, FALSE)
  )
  expect_identical(
    has_name({
      x <- list("foo", "bar")
      names(x)[1] <- ""
      names(x)[2] <- ""
      x
    }),
    c(FALSE, FALSE)
  )
})

test_that("named NULL is dropped", {
  tcs <- list(
    list(list(), list()),
    list(list(a = 1), list(a = 1)),
    list(list(NULL), list(NULL)),
    list(list(a = NULL), list()),
    list(list(NULL, a = NULL, 1), list(NULL, 1)),
    list(list(a = NULL, b = 1, 5), list(b = 1, 5))
  )

  for (tc in tcs) {
    expect_identical(
      drop_named_nulls(tc[[1]]),
      tc[[2]],
      info = tc
    )
  }
})

test_that("named NA is error", {
  goodtcs <- list(
    list(),
    list(NA),
    list(NA, NA_integer_, a = 1)
  )

  badtcs <- list(
    list(b = NULL, a = NA),
    list(a = NA_integer_),
    list(NA, c = NA_real_)
  )

  for (tc in goodtcs) {
    expect_silent(check_named_nas(tc))
  }

  for (tc in badtcs) {
    expect_snapshot(error = TRUE, check_named_nas(tc))
  }
})


test_that(".parse_params combines list .params with ... params", {
  params <- list(
    .parse_params(org = "ORG", repo = "REPO", number = "1"),
    .parse_params(org = "ORG", repo = "REPO", .params = list(number = "1")),
    .parse_params(.params = list(org = "ORG", repo = "REPO", number = "1"))
  )

  expect_identical(params[[1]], params[[2]])
  expect_identical(params[[2]], params[[3]])
})
