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

is_false_check_env_var <- function(x, default = "") {
  # like utils:::str2logical
  val <- Sys.getenv(x, default)
  if (isFALSE(as.logical(val))) {
    return(TRUE)
  }
  tolower(val) %in% c("0", "no")
}

skip_if_not_installed <- function(pkg) {
  if (!is_false_check_env_var("_R_CHECK_FORCE_SUGGESTS_")) {
    return()
  }
  testthat::skip_if_not_installed(pkg)
}
