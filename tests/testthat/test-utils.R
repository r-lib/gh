context("utils")

test_that("can detect presence vs absence names", {
  expect_identical(has_name(list("foo", "bar")), c(FALSE, FALSE))
  expect_identical(has_name(list(a = "foo", "bar")), c(TRUE, FALSE))

  expect_identical(has_name({
    x <- list("foo", "bar"); names(x)[1] <- "a"; x
  }), c(TRUE, FALSE))
  expect_identical(has_name({
    x <- list("foo", "bar"); names(x)[1] <- "a"; names(x)[2] <- ""; x
  }), c(TRUE, FALSE))

  expect_identical(has_name({
    x <- list("foo", "bar"); names(x)[1] <- ""; x
  }), c(FALSE, FALSE))
  expect_identical(has_name({
    x <- list("foo", "bar"); names(x)[1] <- ""; names(x)[2] <- ""; x
    }), c(FALSE, FALSE))

})
