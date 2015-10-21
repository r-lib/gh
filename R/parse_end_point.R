
github_verbs <- c("GET", "POST", "PATCH", "PUT", "DELETE")

parse_endpoint <- function(endpoint, params) {

  done <- logical(length(params))
  for (i in seq_along(params)) {
    n <- names(params)[i]
    p <- params[[i]][1]
    endpoint2 <- gsub(paste0(":", n, "\\b"), p, endpoint)
    if (endpoint2 != endpoint) {
      endpoint <- endpoint2
      done[i] <- TRUE
    }
  }

  if (substring(endpoint, 1, 1) != "/") {
    method <- gsub("^([^/ ]+)\\s*/.*$", "\\1", endpoint)
    endpoint <- gsub("^[^/]+/", "/", endpoint)
  } else {
    method <- "GET"
  }

  list(method = method, endpoint = endpoint, params = params[!done])
}
