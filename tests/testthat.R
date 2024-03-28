library(testthat)
library(gh)

if (Sys.getenv("NOT_CRAN") == "true") {
  test_check("gh")
}
