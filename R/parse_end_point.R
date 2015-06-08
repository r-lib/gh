
#' @importFrom lazyeval lazy

parse_end_point <- function(end_point, env) {

  ep <- lazy(end_point)$expr

  res <- character()
  repeat {

    if (length(ep) == 3 && is.name(ep[[1]]) &&
        as.character(ep[[1]]) == "/") {
      res <- c(parse_clause(ep[[3]], env), res)
      ep <- ep[[2]]

    } else if (length(ep) == 2 && is.name(ep[[1]]) &&
               as.character(ep[[1]]) == "(") {
      res <- c(parse_clause(ep, env), res)
      break;

    } else if (is.symbol(ep)) {
      res <- c(parse_clause(ep, env), res)
      break;

    } else {
      stop("Syntax error: invalid GitHub API end point")
    }

  }

  method <- "GET"
  if (length(res) >= 1 &&
      res[1] %in% c("GET", "POST", "PATCH", "PUT", "DELETE")) {
    method <- res[1]
    res <- res[-1]
  }

  list(method = method, end_point = res)
}

parse_clause <- function(ep, env) {
  if (length(ep) == 2 && is.name(ep[[1]]) && as.character(ep[[1]]) == "(") {
    eval(ep, envir = env)

  } else if (is.symbol(ep)) {
    as.character(ep)

  } else {
    stop("Syntax error: invalid GitHub API end point")
  }
}
