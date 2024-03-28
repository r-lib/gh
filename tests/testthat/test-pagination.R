test_that("can extract relative pages", {
  skip_on_cran()
  page1 <- gh("/orgs/tidyverse/repos", per_page = 1)
  expect_true(gh_has(page1, "next"))
  expect_false(gh_has(page1, "prev"))

  page2 <- gh_next(page1)
  expect_equal(
    attr(page2, "request")$url,
    "https://api.github.com/organizations/22032646/repos"
  )
  expect_equal(
    attr(page2, "request")$query,
    list(per_page = "1", page = "2")
  )
  expect_true(gh_has(page2, "prev"))

  expect_snapshot(gh_prev(page1), error = TRUE)
})

test_that("paginated request gets max_wait and max_rate", {
  skip_on_cran()
  gh <- gh("/orgs/tidyverse/repos", per_page = 5, .max_wait = 1, .max_rate = 10)

  req <- gh_link_request(gh, "next")
  expect_equal(req$max_wait, 1)
  expect_equal(req$max_rate, 10)

  expect_equal(req$query$page, "2")
})
