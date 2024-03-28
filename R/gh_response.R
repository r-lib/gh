gh_process_response <- function(resp, gh_req) {
  stopifnot(inherits(resp, "httr2_response"))

  content_type <- httr2::resp_content_type(resp)
  gh_media_type <- httr2::resp_header(resp, "x-github-media-type")

  is_raw <- identical(content_type, "application/octet-stream") ||
    isTRUE(grepl("param=raw$", gh_media_type, ignore.case = TRUE))
  is_ondisk <- inherits(resp$body, "httr2_path")
  is_empty <- length(resp$body) == 0

  if (is_ondisk) {
    res <- as.character(resp$body)
    file.rename(res, gh_req$dest)
    res <- gh_req$dest
  } else if (is_empty) {
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
  attr(res, "request") <- gh_req

  # for backward compatibility
  attr(res, "method") <- resp$method
  attr(res, ".send_headers") <- httr2::last_request()$headers

  if (is_ondisk) {
    class(res) <- c("gh_response", "path")
  } else if (is_raw) {
    class(res) <- c("gh_response", "raw")
  } else {
    class(res) <- c("gh_response", "list")
  }
  res
}
