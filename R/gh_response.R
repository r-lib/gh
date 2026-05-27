gh_process_response <- function(resp, gh_req) {
  if (!inherits(resp, "httr2_response")) {
    stop_input_type(resp, "an <httr2_response> object")
  }

  status <- httr2::resp_status(resp)
  content_type <- httr2::resp_content_type(resp)
  gh_media_type <- httr2::resp_header(resp, "x-github-media-type")

  is_raw <- identical(content_type, "application/octet-stream") ||
    isTRUE(grepl("param=raw$", gh_media_type, ignore.case = TRUE))
  is_ondisk <- inherits(resp$body, "httr2_path") && !is.null(gh_req$dest)
  # 304 Not Modified: no body, and Content-Type is typically absent — short
  # circuit before the JSON / raw branches to avoid a body-parse error.
  is_not_modified <- status == 304
  is_empty <- length(resp$body) == 0

  if (is_ondisk) {
    res <- as.character(resp$body)
    file.rename(res, gh_req$dest)
    res <- gh_req$dest
  } else if (is_not_modified || is_empty) {
    res <- list()
  } else if (grepl("^application/json", content_type, ignore.case = TRUE)) {
    res <- httr2::resp_body_json(resp)
  } else if (is_raw) {
    res <- httr2::resp_body_raw(resp)
  } else {
    if (grepl("^text/html", content_type, ignore.case = TRUE)) {
      warning("Response came back as html :(", call. = FALSE)
    }
    res <- list(message = httr2::resp_body_string(resp))
  }

  attr(res, "response") <- httr2::resp_headers(resp)
  attr(res, "request") <- remove_headers(gh_req)

  if (is_ondisk) {
    class(res) <- c("gh_response", "path")
  } else if (is_raw) {
    class(res) <- c("gh_response", "raw")
  } else {
    class(res) <- c("gh_response", "list")
  }
  res
}

remove_headers <- function(x) {
  x[names(x) != "headers"]
}

# Add vctrs methods that strip attributes from gh_response when combining,
# enabling rectangling via unnesting etc
# See <https://github.com/r-lib/gh/issues/161> for more details
#' @exportS3Method vctrs::vec_ptype2
vec_ptype2.gh_response.gh_response <- function(x, y, ...) {
  list()
}

#' @exportS3Method vctrs::vec_cast
vec_cast.list.gh_response <- function(x, to, ...) {
  attributes(x) <- NULL
  x
}
