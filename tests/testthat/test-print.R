test_that("can print all types of object", {
  skip_on_cran()
  get_license <- function(...) {
    gh(
      "GET /repos/{owner}/{repo}/contents/{path}",
      owner = "r-lib",
      repo = "gh",
      path = "LICENSE",
      ref = "v1.2.0",
      ...
    )
  }

  json <- get_license()
  raw <- get_license(
    .send_headers = c(Accept = "application/vnd.github.v3.raw")
  )

  path <- withr::local_file(test_path("LICENSE"))
  file <- get_license(
    .destfile = path,
    .send_headers = c(Accept = "application/vnd.github.v3.raw")
  )

  expect_snapshot({
    json
    file
    raw
  })
})
