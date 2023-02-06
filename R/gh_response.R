gh_process_response <- function(resp) {
  stopifnot(inherits(resp, "httr2_response"))

  content_type <- httr2::resp_content_type(resp)
  gh_media_type <- httr2::resp_header(resp, "x-github-media-type")
  is_raw <- content_type == "application/octet-stream" ||
    isTRUE(grepl("param=raw$", gh_media_type, ignore.case = TRUE))

  is_ondisk <- FALSE
  if (grepl("^application/json", content_type, ignore.case = TRUE)) {
    res <- httr2::resp_body_json(resp)
  } else if (is_raw) {
    res <- httr2::resp_body_raw(resp)
  } else if (content_type == "application/octet-stream" &&
    length(httr2::resp_body_raw(resp)) == 0) {
    res <- NULL
  } else {
    if (grepl("^text/html", content_type, ignore.case = TRUE)) {
      warning("Response came back as html :(", call. = FALSE)
    }
    res <- list(message = httr2::resp_body_string(resp))
  }

  # attr(res, "method") <-  response$request$method
  # attr(res, "response") <- headers(response)
  # attr(res, ".send_headers") <- response$request$headers
  if (is_ondisk) {
    class(res) <- c("gh_response", "path")
  } else if (is_raw) {
    class(res) <- c("gh_response", "raw")
  } else {
    class(res) <- c("gh_response", "list")
  }
  res
}

# https://docs.github.com/v3/#client-errors
gh_error <- function(response) {
  heads <- httr2::resp_headers(response)
  res <- httr2::resp_body_json(response)
  status <- httr2::resp_status(response)

  msg <- "GitHub API error ({status}): {heads$status %||% ''} {res$message}"

  if (status == 404) {
    msg <- c(msg, x = c("URL not found: {.url {response$request$url}}"))
  }

  doc_url <- res$documentation_url
  if (!is.null(doc_url)) {
    msg <- c(msg, c("i" = "Read more at {.url {doc_url}}"))
  }

  errors <- res$errors
  if (!is.null(errors)) {
    errors <- as.data.frame(do.call(rbind, errors))
    nms <- c("resource", "field", "code", "message")
    nms <- nms[nms %in% names(errors)]
    msg <- c(
      msg,
      capture.output(print(errors[nms], row.names = FALSE))
    )
  }

  msg
}
