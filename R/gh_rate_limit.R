#' Return GitHub user's current rate limits
#'
#' @description
#' `gh_rate_limits()` reports on all rate limits for the authenticated user.
#' `gh_rate_limit()` reports on rate limits for previous successful request.
#'
#' Further details on GitHub's API rate limit policies are available at
#' <https://docs.github.com/v3/#rate-limiting>.
#'
#' @param response `gh_response` object from a previous `gh` call, rate
#' limit values are determined from values in the response header.
#' Optional argument, if missing a call to "GET /rate_limit" will be made.
#'
#' @inheritParams gh
#'
#' @return A `list` object containing the overall `limit`, `remaining` limit, and the
#' limit `reset` time.
#'
#' @export

gh_rate_limit <- function(response = NULL, .token = NULL, .api_url = NULL, .send_headers = NULL) {
  if (is.null(response)) {
    # This end point does not count against limit
    .token <- .token %||% gh_token(.api_url)
    response <- gh("GET /rate_limit",
      .token = .token,
      .api_url = .api_url, .send_headers = .send_headers
    )
  }

  stopifnot(inherits(response, "gh_response"))

  http_res <- attr(response, "response")

  reset <- as.integer(c(http_res[["x-ratelimit-reset"]], NA)[1])
  reset <- as.POSIXct(reset, origin = "1970-01-01")

  list(
    limit     = as.integer(c(http_res[["x-ratelimit-limit"]], NA)[1]),
    remaining = as.integer(c(http_res[["x-ratelimit-remaining"]], NA)[1]),
    reset     = reset
  )
}

#' @export
#' @rdname gh_rate_limit
gh_rate_limits <- function(.token = NULL, .api_url = NULL, .send_headers = NULL) {
  .token <- .token %||% gh_token(.api_url)
  response <- gh(
    "GET /rate_limit",
    .token = .token,
    .api_url = .api_url,
    .send_headers = .send_headers
  )

  resources <- response$resources

  reset <- .POSIXct(sapply(resources, "[[", "reset"))

  data.frame(
    type = names(resources),
    limit = sapply(resources, "[[", "limit"),
    used = sapply(resources, "[[", "used"),
    remaining = sapply(resources, "[[", "remaining"),
    reset = reset,
    mins_left = round((unclass(reset) - unclass(Sys.time())) / 60, 1),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
}
