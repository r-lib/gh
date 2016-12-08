#' Info on current GitHub user and token
#'
#' Reports wallet name, GitHub login, and GitHub URL for the current
#' authenticated user, the first few and last characters of the token, and the
#' associated scopes. To get full information on the user, call
#' \code{gh("/user")}.
#'
#' @inheritParams gh
#'
#' @return A \code{gh_response} object, which is also a \code{list}.
#' @export
#'
#' @examples
#' gh_whoami()
gh_whoami <- function(.token = NULL, .api_url = NULL, .send_headers = NULL) {
  .token <- .token %||% gh_token()
  if (.token == "") {
    message("No authentication token available.\n",
            "HERE'S HOW TO GET ONE AND WHERE TO STICK IT.")
    return(invisible(NULL))
  }
  req <- gh_build_request(endpoint = "/user", token = .token,
                          api_url = .api_url, send_headers = .send_headers)
  raw <- gh_make_request(req)
  res <- gh_process_response(raw)
  res <- res[c("name", "login", "html_url")]
  res$scopes <- headers(raw)[["x-oauth-scopes"]]
  res$token <- hide_middle(.token)
  ## 'gh_response' class is has to be restored
  class(res) <- c("gh_response", "list")
  res
}

hide_middle <- function(x, n = 4) {
  paste0(substr(x, start = 1, stop = n),
         "...",
         substr(x, start = nchar(x) - n + 1, stop = nchar(x)))
}
