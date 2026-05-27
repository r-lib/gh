test_that("generates a useful message", {
  local_fake_github()
  expect_snapshot(
    gh("/missing"),
    error = TRUE,
    transform = redact_fake_host
  )
})

test_that("errors return a github_error object", {
  local_fake_github()
  e <- tryCatch(gh("/missing"), error = identity)

  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_404")
})

# https://github.com/r-lib/gh/issues/229
test_that("handles 422 responses with `errors` as a plain string", {
  local_fake_github()
  expect_snapshot(
    gh(
      "POST /repos/{owner}/{repo}/statuses/{sha}",
      owner = "r-lib",
      repo = "gh",
      sha = "deadbeef",
      state = "success"
    ),
    error = TRUE,
    transform = redact_fake_host
  )
})

test_that("can catch a given status directly", {
  local_fake_github()
  e <- tryCatch(gh("/missing"), "http_error_404" = identity)

  expect_s3_class(e, "github_error")
  expect_s3_class(e, "http_error_404")
})

test_that("can ignore trailing commas", {
  local_fake_github()
  expect_no_error(gh("/orgs/tidyverse/repos", ))
})

test_that("can use per_page or .per_page but not both", {
  local_fake_github()
  resp <- gh("/orgs/tidyverse/repos", per_page = 2)
  expect_equal(attr(resp, "request")$query$per_page, 2)

  resp <- gh("/orgs/tidyverse/repos", .per_page = 2)
  expect_equal(attr(resp, "request")$query$per_page, 2)

  expect_snapshot(
    error = TRUE,
    gh("/orgs/tidyverse/repos", per_page = 1, .per_page = 2)
  )
})

test_that("can paginate", {
  local_fake_github()
  pages <- gh(
    "/orgs/tidyverse/repos",
    per_page = 1,
    .limit = 5,
    .progress = FALSE
  )
  expect_length(pages, 5)
})

test_that("trim output when .limit isn't a multiple of .per_page", {
  local_fake_github()
  pages <- gh(
    "/orgs/tidyverse/repos",
    per_page = 2,
    .limit = 3,
    .progress = FALSE
  )
  expect_length(pages, 3)
})

test_that("can paginate repository search", {
  local_fake_github()
  pages <- gh(
    "/search/repositories",
    q = "tidyverse",
    per_page = 10,
    .limit = 35
  )
  expect_named(pages, c("total_count", "incomplete_results", "items"))
  # Items aren't trimmed to .limit in this case
  expect_length(pages$items, 40)
})

test_that("paginated request surfaces a 4xx error", {
  local_fake_github()
  expect_snapshot(
    error = TRUE,
    gh("/orgs/{org}/repos", org = "gh-org-testing-404", .limit = 100),
    transform = redact_fake_host
  )
})

test_that("paginate exhausts when .limit is Inf and learns total from last link", {
  local_fake_github()
  pages <- gh(
    "/orgs/r-lib/repos",
    per_page = 5,
    .limit = Inf,
    .progress = FALSE
  )
  expect_length(pages, 16)
})

test_that("POST accepts a raw body", {
  local_fake_github()
  payload <- charToRaw("hello, raw world")
  res <- gh("POST /echo-raw", payload)
  expect_equal(as.character(class(res))[1], "gh_response")
})

test_that("GH_FORCE_HTTP_1_1 envvar is honored", {
  local_fake_github()
  withr::with_envvar(c(GH_FORCE_HTTP_1_1 = "true"), {
    res <- gh("/orgs/{org}/repos", org = "r-lib", per_page = 1)
  })
  expect_s3_class(res, "gh_response")
})

test_that("requests use the on-disk cache when gh_cache is not FALSE", {
  local_fake_github()
  withr::local_options(gh_cache = NULL)
  res <- gh("/orgs/{org}/repos", org = "r-lib", per_page = 1)
  expect_s3_class(res, "gh_response")
})

test_that("cursor-style pagination uses the indeterminate progress format", {
  local_fake_github()
  res <- gh("/cursor-list", per_page = 10, .limit = Inf, .progress = TRUE)
  expect_length(res, 25)
})

test_that("github_is_transient identifies rate-limit 403s", {
  fake_resp <- function(status, headers = list()) {
    structure(
      list(status_code = status, headers = headers, url = "x", method = "GET"),
      class = "httr2_response"
    )
  }
  reset <- as.character(as.integer(unclass(Sys.time())) + 5L)
  far_reset <- as.character(as.integer(unclass(Sys.time())) + 86400L)

  # Not a 403
  expect_false(github_is_transient(fake_resp(200), max_wait = 60))
  # 403 but plenty of remaining quota
  expect_false(github_is_transient(
    fake_resp(403, list("x-ratelimit-remaining" = "100")),
    max_wait = 60
  ))
  # 403, no remaining quota, missing reset header
  expect_false(github_is_transient(
    fake_resp(403, list("x-ratelimit-remaining" = "0")),
    max_wait = 60
  ))
  # 403, no remaining, reset is too far away
  expect_false(github_is_transient(
    fake_resp(
      403,
      list("x-ratelimit-remaining" = "0", "x-ratelimit-reset" = far_reset)
    ),
    max_wait = 60
  ))
  # 403, no remaining, reset within max_wait
  expect_true(github_is_transient(
    fake_resp(
      403,
      list("x-ratelimit-remaining" = "0", "x-ratelimit-reset" = reset)
    ),
    max_wait = 60
  ))
})

test_that("github_after returns the time until the rate limit resets", {
  reset <- as.integer(unclass(Sys.time())) + 30L
  fake_resp <- structure(
    list(
      status_code = 403,
      headers = list("x-ratelimit-reset" = as.character(reset)),
      url = "x",
      method = "GET"
    ),
    class = "httr2_response"
  )
  expect_lte(github_after(fake_resp), 30)
  expect_gte(github_after(fake_resp), 25)
})

test_that("gh_merge_pages dedupes named atomic fields that are not search metadata", {
  res1 <- list(repository_selection = "all", items = list("a"))
  res2 <- list(repository_selection = "all", items = list("b"))
  merged <- gh_merge_pages(res1, res2)
  expect_equal(merged$repository_selection, "all")
  expect_equal(merged$items, list("a", "b"))
})
