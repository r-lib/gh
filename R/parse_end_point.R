
github_verbs <- c("GET", "POST", "PATCH", "PUT", "DELETE")

parse_end_point <- function(end_point, params) {

  done <- logical(length(params))
  for (i in seq_along(params)) {
    n <- names(params)[i]
    p <- params[[i]]
    end_point2 <- gsub(paste0(":", n, "\\b"), p, end_point)
    if (end_point2 != end_point) {
      end_point <- end_point2
      done[i] <- TRUE
    }
  }

  if (substring(end_point, 1, 1) != "/") {
    method <- gsub("^([^/ ]+)\\s*/.*$", "\\1", end_point)
    end_point <- gsub("^[^/]+/", "/", end_point)
  } else {
    method <- "GET"
  }

  list(method = method, end_point = end_point, params = params[!done])
}
