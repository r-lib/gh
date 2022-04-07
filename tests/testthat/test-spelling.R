test_that("spelling", {
  skip_on_cran()
  skip_on_covr()
  pkgroot <- test_package_root()
  err <- spelling::spell_check_package(pkgroot)
  num_spelling_errors <- nrow(err)
  expect_true(
    num_spelling_errors == 0,
    info = paste(
      c("\nSpelling errors:", capture.output(err)),
      collapse = "\n"
    )
  )
})
