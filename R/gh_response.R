gh_process_response <- function(response) {
  stopifnot(inherits(response, "response"))
  if (status_code(response) >= 300) {
    gh_error(response)
  }

  content_type <- http_type(response)
  gh_media_type <- headers(response)[["x-github-media-type"]]
  is_raw <- grepl("param=raw$", gh_media_type, ignore.case = TRUE)
  is_ondisk <- inherits(response$content, "path")
  if (length(content(response)) == 0) {
    res <- ""
  } else if (is_ondisk) {
    res <- response$content
  } else if (grepl("^application/json", content_type, ignore.case = TRUE)) {
    res <- fromJSON(content(response, as = "text"), simplifyVector = FALSE)
  } else if (is_raw) {
    res <- content(response, as = "raw")
  } else {
    if (grepl("^text/html", content_type, ignore.case = TRUE)) {
      warning("Response came back as html :(", call. = FALSE)
    }
    res <- list(message = content(response, as = "text"))
  }

  attr(res, "method") <- response$request$method
  attr(res, "response") <- headers(response)
  attr(res, ".send_headers") <- response$request$headers
  if (is_ondisk) {
    class(res) <- c("gh_response", "path")
  } else if (is_raw) {
    class(res) <- c("gh_response", "raw")
  } else {
    class(res) <- c("gh_response", "list")
  }
  res
}

## https://developer.github.com/v3/#client-errors
gh_error <- function(response, call = sys.call(-1)) {
  heads <- headers(response)
  res <- content(response)
  status <- status_code(response)

  msg <- c(
    "",
    paste0("GitHub API error (", status, "): ", heads$status),
    paste0("Message: ", res$message)
  )

  doc_url <- res$documentation_url
  if (!is.null(doc_url)) {
    msg <- append(msg, paste0("Read more at ", doc_url))
  }

  if (status == 404) {
    msg <- append(msg, c("", paste0("URL not found: ", response$request$url)))
  }

  errors <- res$errors
  if (!is.null(errors)) {
    errors <- as.data.frame(do.call(rbind, errors))
    nms <- c("resource", "field", "code", "message")
    nms <- nms[nms %in% names(errors)]
    msg <- append(
      msg,
      c("",
        "Errors:",
        capture.output(print(errors[nms], row.names = FALSE))
      )
    )
  }
  cond <- structure(list(
    call = call,
    message = paste0(msg, collapse = "\n")
  ),
  class = c(
    "github_error",
    paste0("http_error_", status),
    "error",
    "condition"
  ))
  throw(cond)
}
