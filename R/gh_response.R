gh_process_response <- function(response) {
  stopifnot(inherits(response, "response"))
  heads <- headers(response)

  content_type <- http_type(response)
  if (length(content(response)) == 0) {
    res <- ""
  } else if (grepl("^application/json", content_type, ignore.case = TRUE)) {
    res <- fromJSON(content(response, as = "text"), simplifyVector = FALSE)
  } else {
    if (grepl("^text/html", content_type, ignore.case = TRUE)) {
      warning("Response came back as html :(", call. = FALSE)
    }
    res <- list(message = content(response, as = "text"))
  }

  if (status_code(response) >= 300) {
    cond <- structure(list(
      call = sys.call(-1),
      content = res,
      headers = heads,
      message = paste0("GitHub API error (", status_code(response), "): ",
                       heads$`status`, "\n  ", res$message, "\n")
    ), class = c("github_error", paste0("http_error_", status_code(response)), "error", "condition"))
    stop(cond)
  }

  attr(res, "method") <- response$request$method
  attr(res, "response") <- heads
  attr(res, ".send_headers") <- response$request$headers
  class(res) <- c("gh_response", "list")
  res
}
