test_package_root <- function() {
  x <- tryCatch(
    rprojroot::find_package_root_file(),
    error = function(e) NULL
  )

  if (!is.null(x)) {
    return(x)
  }

  pkg <- testthat::testing_package()
  x <- tryCatch(
    rprojroot::find_package_root_file(
      path = file.path("..", "..", "00_pkg_src", pkg)
    ),
    error = function(e) NULL
  )

  if (!is.null(x)) {
    return(x)
  }

  stop("Cannot find package root")
}
