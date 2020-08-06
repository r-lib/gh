

trim_ws <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}

## from devtools, among other places
compact <- function(x) {
  is_empty <- vapply(x, function(x) length(x) == 0, logical(1))
  x[!is_empty]
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

## if all names are "", strip completely
cleanse_names <- function(x) {
  if (has_no_names(x)) {
    names(x) <- NULL
  }
  x
}

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


discard <- function(.x, .p, ...) {
  sel <- probe(.x, .p, ...)
  .x[is.na(sel) | !sel]
}
probe <- function(.x, .p, ...) {
  if (is.logical(.p)) {
    stopifnot(length(.p) == length(.x))
    .p
  } else {
    vapply(.x, .p, logical(1), ...)
  }
}

drop_named_nulls <- function(x) {
  if (has_no_names(x)) return(x)
  named <- has_name(x)
  null <- vapply(x, is.null, logical(1))
  cleanse_names(x[! named | ! null])
}

check_named_nas <- function(x) {
  if (has_no_names(x)) return(x)
  named <- has_name(x)
  na <- vapply(x, FUN.VALUE = logical(1), function(v) {
    is.atomic(v) && anyNA(v)
  })
  bad <- which(named & na)
  if (length(bad)) {
    str <- paste0("`", names(x)[bad], "`", collapse = ", ")
    stop("Named NA parameters are not allowed: ", str)
  }
}

can_load <- function(pkg) {
  isTRUE(requireNamespace(pkg, quietly = TRUE))
}

is_interactive <- function() {
  opt <- getOption("rlib_interactive")
  if (isTRUE(opt)) {
    TRUE
  } else if (identical(opt, FALSE)) {
    FALSE
  } else if (tolower(getOption("knitr.in.progress", "false")) == "true") {
    FALSE
  } else if (identical(Sys.getenv("TESTTHAT"), "true")) {
    FALSE
  } else {
    interactive()
  }
}
