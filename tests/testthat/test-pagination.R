test_that("can extract relative pages", {
  proc <- local_fake_github()
  page1 <- gh("/orgs/tidyverse/repos", per_page = 1)
  expect_true(gh_has(page1, "next"))
  expect_false(gh_has(page1, "prev"))

  page2 <- gh_next(page1)
  expect_equal(
    attr(page2, "request")$url,
    paste0(sub("/$", "", proc$url()), "/orgs/tidyverse/repos?per_page=1&page=2")
  )
  expect_true(gh_has(page2, "prev"))

  expect_snapshot(gh_prev(page1), error = TRUE)
})

test_that("can paginate even when space re-encoded to +", {
  local_fake_github()
  json <- gh::gh(
    "GET /search/issues",
    q = 'label:"tidy-dev-day :nerd_face:"',
    per_page = 10,
    .limit = 20
  )
  expect_length(json$items, 20)
})

test_that("gh_has_next, gh_first, gh_last work", {
  local_fake_github()
  page1 <- gh("/orgs/tidyverse/repos", per_page = 1)
  expect_true(gh_has_next(page1))

  page2 <- gh_next(page1)
  first <- gh_first(page2)
  expect_false(gh_has_next(gh_last(page1)))
  expect_equal(length(first), 1L)
})

test_that("gh_link_request errors on non-gh_response input", {
  expect_snapshot(
    error = TRUE,
    gh_link_request(list(), "next", .token = NULL, .send_headers = NULL)
  )
})

test_that("interrupt during pagination signals gh_interrupt with partial data", {
  local_fake_github()

  original_process <- gh_process_response
  call_count <- 0L
  fake_process <- function(resp, gh_req) {
    call_count <<- call_count + 1L
    if (call_count >= 2L) {
      rlang::interrupt()
    }
    original_process(resp, gh_req)
  }
  local_mocked_bindings(gh_process_response = fake_process)

  cond <- tryCatch(
    gh("/orgs/tidyverse/repos", per_page = 1, .limit = 5, .progress = FALSE),
    gh_interrupt = function(e) e
  )
  expect_s3_class(cond, "gh_interrupt")
  expect_s3_class(cond, "interrupt")
  expect_s3_class(cond$gh_result, "gh_response")
  expect_length(cond$gh_result, 1L)
})

test_that("generic interrupt handler also receives gh_result", {
  local_fake_github()

  original_process <- gh_process_response
  call_count <- 0L
  fake_process <- function(resp, gh_req) {
    call_count <<- call_count + 1L
    if (call_count >= 2L) {
      rlang::interrupt()
    }
    original_process(resp, gh_req)
  }
  local_mocked_bindings(gh_process_response = fake_process)

  cond <- tryCatch(
    gh("/orgs/tidyverse/repos", per_page = 1, .limit = 5, .progress = FALSE),
    interrupt = function(e) e
  )
  expect_s3_class(cond, "gh_interrupt")
  expect_s3_class(cond$gh_result, "gh_response")
})

test_that("interrupt before first page signals gh_interrupt with NULL gh_result", {
  local_fake_github()

  fake_process <- function(resp, gh_req) {
    rlang::interrupt()
  }
  local_mocked_bindings(gh_process_response = fake_process)

  cond <- tryCatch(
    gh("/orgs/tidyverse/repos", per_page = 1, .limit = 5, .progress = FALSE),
    gh_interrupt = function(e) e
  )
  expect_s3_class(cond, "gh_interrupt")
  expect_null(cond$gh_result)
})

test_that("paginated request gets max_wait and max_rate", {
  local_fake_github()
  gh <- gh(
    "/orgs/tidyverse/repos",
    per_page = 5,
    .max_wait = 1,
    .max_rate = 10
  )

  req <- gh_link_request(gh, "next", .token = NULL, .send_headers = NULL)
  expect_equal(req$max_wait, 1)
  expect_equal(req$max_rate, 10)

  url <- httr2::url_parse(req$url)
  expect_equal(url$query$page, "2")
})
