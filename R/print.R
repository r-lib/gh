
#' Print the result of a GitHub API call
#'
#' @param x The result object.
#' @param ... Ignored.
#' @return The JSON result.
#'
#' @importFrom jsonlite prettify toJSON
#' @export
#' @method print gh_response

print.gh_response <- function(x, ...) {
  if (inherits(x, c("raw", "path"))) {
    attributes(x) <- list(class = class(x))
    print.default(x)
  } else {
    print(toJSON(unclass(x), pretty = TRUE, auto_unbox = TRUE, force = TRUE))
  }
}
