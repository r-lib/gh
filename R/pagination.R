
extract_link <- function(gh_response, link) {
  headers <- attr(gh_response, "response")
  links <- headers$link
  if (is.null(links)) {
    return(NA_character_)
  }
  links <- trim_ws(strsplit(links, ",")[[1]])
  link_list <- lapply(links, function(x) {
    x <- trim_ws(strsplit(x, ";")[[1]])
    name <- sub("^.*\"(.*)\".*$", "\\1", x[2])
    value <- sub("^<(.*)>$", "\\1", x[1])
    c(name, value)
  })
  link_list <- structure(
    vapply(link_list, "[", "", 2),
    names = vapply(link_list, "[", "", 1)
  )

  if (link %in% names(link_list)) {
    link_list[[link]]
  } else {
    NA_character_
  }
}

gh_has <- function(gh_response, link) {
  url <- extract_link(gh_response, link)
  !is.na(url)
}

gh_has_next <- function(gh_response) {
  gh_has(gh_response, "next")
}

gh_link_request <- function(gh_response, link) {
  stopifnot(inherits(gh_response, "gh_response"))

  url <- extract_link(gh_response, link)
  if (is.na(url)) cli::cli_abort("No {link} page")

  req <- attr(gh_response, "request")
  purl <- httr2::url_parse(url)
  req$query <- purl$query
  purl$query <- NULL
  req$url <- httr2::url_build(purl)
  req
}

gh_link <- function(gh_response, link) {
  req <- gh_link_request(gh_response, link)
  raw <- gh_make_request(req)
  gh_process_response(raw, req)
}

gh_extract_pages <- function(gh_response) {
  last <- extract_link(gh_response, "last")
  if (!is.na(last)) {
    as.integer(httr2::url_parse(last)$query$page)
  }
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
gh_next <- function(gh_response) gh_link(gh_response, "next")

#' @name gh_next
#' @export

gh_prev <- function(gh_response) gh_link(gh_response, "prev")

#' @name gh_next
#' @export

gh_first <- function(gh_response) gh_link(gh_response, "first")

#' @name gh_next
#' @export

gh_last <- function(gh_response) gh_link(gh_response, "last")
