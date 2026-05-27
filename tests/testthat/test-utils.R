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

test_that("trim_ws strips leading and trailing whitespace", {
  expect_identical(trim_ws("foo"), "foo")
  expect_identical(trim_ws("  foo"), "foo")
  expect_identical(trim_ws("foo  "), "foo")
  expect_identical(trim_ws("  foo  "), "foo")
  expect_identical(trim_ws("\t foo \n"), "foo")
  expect_identical(trim_ws("foo bar"), "foo bar")
  expect_identical(trim_ws(""), "")
  expect_identical(trim_ws(c("  a", "b  ")), c("a", "b"))
})

test_that("has_no_names detects fully-unnamed input", {
  expect_true(has_no_names(list("a", "b")))
  expect_true(has_no_names(list()))
  expect_false(has_no_names(list(a = 1, "b")))
  expect_false(has_no_names(list(a = 1, b = 2)))

  x <- list("a", "b")
  names(x) <- c("", "")
  expect_true(has_no_names(x))
})

test_that("cleanse_names drops all-empty names but keeps real ones", {
  x <- list("a", "b")
  names(x) <- c("", "")
  expect_null(names(cleanse_names(x)))

  y <- list(a = 1, b = 2)
  expect_identical(cleanse_names(y), y)

  z <- list(a = 1, "b")
  expect_identical(cleanse_names(z), z)

  expect_identical(cleanse_names(list()), list())
})

test_that("modify_vector overrides x with y case-insensitively", {
  expect_identical(modify_vector(c(a = "1", b = "2")), c(a = "1", b = "2"))
  expect_identical(
    modify_vector(c(a = "1", b = "2"), NULL),
    c(a = "1", b = "2")
  )

  expect_identical(
    modify_vector(c(a = "1", b = "2"), c(b = "9")),
    c(a = "1", b = "9")
  )

  expect_identical(
    modify_vector(c(Accept = "json"), c(accept = "xml")),
    c(accept = "xml")
  )

  expect_identical(
    modify_vector(c(a = "1"), c(b = "2")),
    c(a = "1", b = "2")
  )
})

test_that("discard drops elements matching predicate", {
  expect_identical(
    discard(list(1, NULL, 2, NULL), is.null),
    list(1, 2)
  )
  expect_identical(
    discard(list(a = 1, b = NULL, c = 2), is.null),
    list(a = 1, c = 2)
  )
  expect_identical(discard(list(), is.null), list())
})

test_that("discard accepts a logical selector", {
  expect_identical(
    discard(list("a", "b", "c"), c(TRUE, FALSE, TRUE)),
    list("b")
  )
  expect_identical(
    discard(list("a", "b", "c"), c(TRUE, NA, FALSE)),
    list("b", "c")
  )
})

test_that("discard errors on logical selector of wrong length", {
  expect_snapshot(
    error = TRUE,
    discard(list("a", "b"), c(TRUE, FALSE, TRUE))
  )
})
