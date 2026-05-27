gh_has <- function(gh_response, link) {
  resp <- attr(gh_response, "httr2_response")
  !is.null(httr2::resp_link_url(resp, link))
}

gh_has_next <- function(gh_response) {
  gh_has(gh_response, "next")
}

gh_link_request <- function(gh_response, link, .token, .send_headers) {
  if (!inherits(gh_response, "gh_response")) {
    stop_input_type(gh_response, "a <gh_response> object")
  }

  resp <- attr(gh_response, "httr2_response")
  url <- httr2::resp_link_url(resp, link)
  if (is.null(url)) {
    cli::cli_abort("No {link} page")
  }

  req <- attr(gh_response, "request")
  req$url <- url
  req$token <- .token
  req$send_headers <- .send_headers
  req <- gh_set_headers(req)
  req
}

gh_link <- function(gh_response, link, .token, .send_headers) {
  req <- gh_link_request(gh_response, link, .token, .send_headers)
  raw <- gh_make_request(req)
  gh_process_response(raw, req)
}

#' Get the next, previous, first or last page of results
#'
#' @details
#' Note that these are not always defined. E.g. if the first
#' page was queried (the default), then there are no first and previous
#' pages defined. If there is no next page, then there is no
#' next page defined, etc.
#'
#' If the requested page does not exist, an error is thrown.
#'
#' @param gh_response An object returned by a [gh()] call.
#' @inheritParams gh
#' @return Answer from the API.
#'
#' @seealso The `.limit` argument to [gh()] supports fetching more than
#'   one page.
#'
#' @name gh_next
#' @export
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' x <- gh("/users")
#' vapply(x, "[[", character(1), "login")
#' x2 <- gh_next(x)
#' vapply(x2, "[[", character(1), "login")
gh_next <- function(gh_response, .token = NULL, .send_headers = NULL) {
  gh_link(gh_response, "next", .token = .token, .send_headers = .send_headers)
}

#' @name gh_next
#' @export

gh_prev <- function(gh_response, .token = NULL, .send_headers = NULL) {
  gh_link(gh_response, "prev", .token = .token, .send_headers = .send_headers)
}

#' @name gh_next
#' @export

gh_first <- function(gh_response, .token = NULL, .send_headers = NULL) {
  gh_link(gh_response, "first", .token = .token, .send_headers = .send_headers)
}

#' @name gh_next
#' @export

gh_last <- function(gh_response, .token = NULL, .send_headers = NULL) {
  gh_link(gh_response, "last", .token = .token, .send_headers = .send_headers)
}
