
trim_ws <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}

## from purrr, among other places
`%||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

## as seen in purrr, with the name `has_names()`
has_name <- function(x) {
  nms <- names(x)
  if (is.null(nms)) {
    rep_len(FALSE, length(x))
  } else {
    !(is.na(nms) | nms == "")
  }
}

has_no_names <- function(x) all(!has_name(x))

## to process HTTP headers, i.e. combine defaults w/ user-specified headers
## in the spirit of modifyList(), except
## x and y are vectors (not lists)
## name comparison is case insensitive
## http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
## x will be default headers, y will be user-specified
modify_vector <- function(x, y = NULL) {
  if (length(y) == 0L) return(x)
  lnames <- function(x) tolower(names(x))
  c(x[!(lnames(x) %in% lnames(y))], y)
}
