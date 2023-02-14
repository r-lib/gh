test_that("paginated request gets max_wait and max_rate", {
  gh <- gh("/orgs/tidyverse/repos", per_page = 5, .max_wait = 1, .max_rate = 10)

  req <- gh_link_request(gh, "next")
  expect_equal(req$max_wait, 1)
  expect_equal(req$max_rate, 10)

  url <- httr2::url_parse(req$url)
  expect_equal(url$query$page, "2")
})
