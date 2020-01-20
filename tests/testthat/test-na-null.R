
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
    expect_error(check_named_nas(tc))
  }
})
