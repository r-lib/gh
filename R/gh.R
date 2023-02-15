#' Query the GitHub API
#'
#' This is an extremely minimal client. You need to know the API
#' to be able to use this client. All this function does is:
#' * Try to substitute each listed parameter into `endpoint`, using the
#'   `{parameter}` notation.
#' * If a GET request (the default), then add all other listed parameters
#'   as query parameters.
#' * If not a GET request, then send the other parameters in the request
#'   body, as JSON.
#' * Convert the response to an R list using [jsonlite::fromJSON()].
#'
#' @param endpoint GitHub API endpoint. Must be one of the following forms:
#'    * `METHOD path`, e.g. `GET /rate_limit`,
#'    * `path`, e.g. `/rate_limit`,
#'    * `METHOD url`, e.g. `GET https://api.github.com/rate_limit`,
#'    * `url`, e.g. `https://api.github.com/rate_limit`.
#'
#'    If the method is not supplied, will use `.method`, which defaults
#'    to `"GET"`.
#' @param ... Name-value pairs giving API parameters. Will be matched into
#'   `endpoint` placeholders, sent as query parameters in GET requests, and as a
#'   JSON body of POST requests. If there is only one unnamed parameter, and it
#'   is a raw vector, then it will not be JSON encoded, but sent as raw data, as
#'   is. This can be used for example to add assets to releases. Named `NULL`
#'   values are silently dropped. For GET requests, named `NA` values trigger an
#'   error. For other methods, named `NA` values are included in the body of the
#'   request, as JSON `null`.
#' @param per_page Number of items to return per page. If omitted,
#'   will be substituted by `max(.limit, 100)` if `.limit` is set,
#'   otherwise determined by the API (never greater than 100).
#' @param .destfile Path to write response to disk. If `NULL` (default),
#'   response will be processed and returned as an object. If path is given,
#'   response will be written to disk in the form sent.
#' @param .overwrite If `.destfile` is provided, whether to overwrite an
#'   existing file.  Defaults to `FALSE`.
#' @param .token Authentication token. Defaults to `GITHUB_PAT` or
#'   `GITHUB_TOKEN` environment variables, in this order if any is set.
#'   See [gh_token()] if you need more flexibility, e.g. different tokens
#'   for different GitHub Enterprise deployments.
#' @param .api_url Github API url (default: <https://api.github.com>). Used
#'   if `endpoint` just contains a path. Defaults to `GITHUB_API_URL`
#'   environment variable if set.
#' @param .method HTTP method to use if not explicitly supplied in the
#'    `endpoint`.
#' @param .limit Number of records to return. This can be used
#'   instead of manual pagination. By default it is `NULL`,
#'   which means that the defaults of the GitHub API are used.
#'   You can set it to a number to request more (or less)
#'   records, and also to `Inf` to request all records.
#'   Note, that if you request many records, then multiple GitHub
#'   API calls are used to get them, and this can take a potentially
#'   long time.
#' @param .accept The value of the `Accept` HTTP header. Defaults to
#'   `"application/vnd.github.v3+json"` . If `Accept` is given in
#'   `.send_headers`, then that will be used. This parameter can be used to
#'   provide a custom media type, in order to access a preview feature of
#'   the API.
#' @param .send_headers Named character vector of header field values
#'   (except `Authorization`, which is handled via `.token`). This can be
#'   used to override or augment the default `User-Agent` header:
#'   `"https://github.com/r-lib/gh"`.
#' @param .progress Whether to show a progress indicator for calls that
#'   need more than one HTTP request.
#' @param .params Additional list of parameters to append to `...`.
#'   It is easier to use this than `...` if you have your parameters in
#'   a list already.
#' @param .max_wait Maximum number of seconds to wait if rate limited.
#'   Defaults to 10 minutes.
#' @param .max_rate Maximum request rate in requests per second. Set
#'   this to automatically throttle requests.
#' @return Answer from the API as a `gh_response` object, which is also a
#'   `list`. Failed requests will generate an R error. Requests that
#'   generate a raw response will return a raw vector.
#'
#' @export
#' @seealso [gh_gql()] if you want to use the GitHub GraphQL API,
#' [gh_whoami()] for details on GitHub API token management.
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' ## Repositories of a user, these are equivalent
#' gh("/users/hadley/repos", .limit = 2)
#' gh("/users/{username}/repos", username = "hadley", .limit = 2)
#'
#' ## Starred repositories of a user
#' gh("/users/hadley/starred", .limit = 2)
#' gh("/users/{username}/starred", username = "hadley", .limit = 2)
#' @examplesIf FALSE
#' ## Create a repository, needs a token in GITHUB_PAT (or GITHUB_TOKEN)
#' ## environment variable
#' gh("POST /user/repos", name = "foobar")
#' @examplesIf identical(Sys.getenv("IN_PKGDOWN"), "true")
#' ## Issues of a repository
#' gh("/repos/hadley/dplyr/issues")
#' gh("/repos/{owner}/{repo}/issues", owner = "hadley", repo = "dplyr")
#'
#' ## Automatic pagination
#' users <- gh("/users", .limit = 50)
#' length(users)
#' @examplesIf FALSE
#' ## Access developer preview of Licenses API (in preview as of 2015-09-24)
#' gh("/licenses") # used to error code 415
#' gh("/licenses", .accept = "application/vnd.github.drax-preview+json")
#' @examplesIf FALSE
#' ## Access Github Enterprise API
#' ## Use GITHUB_API_URL environment variable to change the default.
#' gh("/user/repos", type = "public", .api_url = "https://github.foobar.edu/api/v3")
#' @examplesIf FALSE
#' ## Use I() to force body part to be sent as an array, even if length 1
#' ## This works whether assignees has length 1 or > 1
#' assignees <- "gh_user"
#' assignees <- c("gh_user1", "gh_user2")
#' gh("PATCH /repos/OWNER/REPO/issues/1", assignees = I(assignees))
#' @examplesIf FALSE
#' ## There are two ways to send JSON data. One is that you supply one or
#' ## more objects that will be converted to JSON automatically via
#' ## jsonlite::toJSON(). In this case sometimes you need to use
#' ## jsonlite::unbox() because fromJSON() creates lists from scalar vectors
#' ## by default. The Content-Type header is automatically added in this
#' ## case. For example this request turns on GitHub Pages, using this
#' ## API: https://docs.github.com/v3/repos/pages/#enable-a-pages-site
#'
#' gh::gh(
#'   "POST /repos/{owner}/{repo}/pages",
#'   owner = "r-lib",
#'   repo = "gh",
#'   source = list(
#'     branch = jsonlite::unbox("gh-pages"),
#'     path = jsonlite::unbox("/")
#'   ),
#'   .send_headers = c(Accept = "application/vnd.github.switcheroo-preview+json")
#' )
#'
#' ## The second way is to handle the JSON encoding manually, and supply it
#' ## as a raw vector in an unnamed argument, and also a Content-Type header:
#'
#' body <- '{ "source": { "branch": "gh-pages", "path": "/" } }'
#' gh::gh(
#'   "POST /repos/{owner}/{repo}/pages",
#'   owner = "r-lib",
#'   repo = "gh",
#'   charToRaw(body),
#'   .send_headers = c(
#'     Accept = "application/vnd.github.switcheroo-preview+json",
#'     "Content-Type" = "application/json"
#'   )
#' )
gh <- function(endpoint,
               ...,
               per_page = NULL,
               .token = NULL,
               .destfile = NULL,
               .overwrite = FALSE,
               .api_url = NULL,
               .method = "GET",
               .limit = NULL,
               .accept = "application/vnd.github.v3+json",
               .send_headers = NULL,
               .progress = TRUE,
               .params = list(),
               .max_wait = 600,
               .max_rate = NULL) {
  params <- c(list(...), .params)
  params <- drop_named_nulls(params)

  if (is.null(per_page)) {
    if (!is.null(.limit)) {
      per_page <- max(min(.limit, 100), 1)
    }
  }

  if (!is.null(per_page)) {
    params <- c(params, list(per_page = per_page))
  }

  req <- gh_build_request(
    endpoint = endpoint,
    params = params,
    token = .token,
    destfile = .destfile,
    overwrite = .overwrite,
    accept = .accept,
    send_headers = .send_headers,
    max_wait = .max_wait,
    max_rate = .max_rate,
    api_url = .api_url,
    method = .method
  )

  if (req$method == "GET") check_named_nas(params)

  if (.progress) prbr <- make_progress_bar(req)

  raw <- gh_make_request(req)
  res <- gh_process_response(raw, req)
  len <- gh_response_length(res)

  while (!is.null(.limit) && len < .limit && gh_has_next(res)) {
    if (.progress) update_progress_bar(prbr, res)
    res2 <- gh_next(res)

    if (!is.null(names(res2)) && identical(names(res), names(res2))) {
      res3 <- mapply( # Handle named array case
        function(x, y, n) { # e.g. GET /search/repositories
          z <- c(x, y)
          atm <- is.atomic(z)
          if (atm && n %in% c("total_count", "incomplete_results")) {
            y
          } else if (atm) {
            unique(z)
          } else {
            z
          }
        },
        res, res2, names(res),
        SIMPLIFY = FALSE
      )
    } else { # Handle unnamed array case
      res3 <- c(res, res2) # e.g. GET /orgs/:org/invitations
    }

    len <- len + gh_response_length(res2)

    attributes(res3) <- attributes(res2)
    res <- res3
  }

  # We only subset for a non-named response.
  if (!is.null(.limit) && len > .limit &&
    !"total_count" %in% names(res) && length(res) == len) {
    res_attr <- attributes(res)
    res <- res[seq_len(.limit)]
    attributes(res) <- res_attr
  }

  res
}

gh_response_length <- function(res) {
  if (!is.null(names(res)) && length(res) > 1 &&
    names(res)[1] == "total_count") {
    # Ignore total_count, incomplete_results, repository_selection
    # and take the first list element to get the length
    lst <- vapply(res, is.list, logical(1))
    nm <- setdiff(
      names(res),
      c("total_count", "incomplete_results", "repository_selection")
    )
    tgt <- which(lst[nm])[1]
    if (is.na(tgt)) length(res) else length(res[[nm[tgt]]])
  } else {
    length(res)
  }
}

gh_make_request <- function(x, error_call = caller_env()) {
  if (!x$method %in% c("GET", "POST", "PATCH", "PUT", "DELETE")) {
    cli::cli_abort("Unknown HTTP verb: {.val {x$method}}")
  }

  req <- httr2::request(x$url)
  req <- httr2::req_method(req, x$method)
  req <- httr2::req_url_query(req, !!!x$query)
  if (is.raw(x$body)) {
    req <- httr2::req_body_raw(req, x$body)
  } else {
    req <- httr2::req_body_json(req, x$body, null = "list", digits = 4)
  }
  req <- httr2::req_headers(req, !!!x$headers)

  if (!is_testing()) {
    req <- httr2::req_retry(
      req,
      max_tries = 3,
      is_transient = function(resp) github_is_transient(resp, x$max_wait),
      after = github_after
    )
  }

  if (!is.null(x$max_rate)) {
    req <- httr2::req_throttle(req, x$max_rate)
  }

  # allow custom handling with gh_error
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  resp <- httr2::req_perform(req, path = x$dest)
  if (httr2::resp_status(resp) >= 300) {
    gh_error(resp, error_call = error_call)
  }

  resp
}

# https://docs.github.com/v3/#client-errors
gh_error <- function(response, error_call = caller_env()) {
  heads <- httr2::resp_headers(response)
  res <- httr2::resp_body_json(response)
  status <- httr2::resp_status(response)

  msg <- "GitHub API error ({status}): {heads$status %||% ''} {res$message}"

  if (status == 404) {
    msg <- c(msg, x = c("URL not found: {.url {response$url}}"))
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

  cli::cli_abort(
    msg,
    class = c("github_error", paste0("http_error_", status)),
    call = error_call,
    response_headers = heads,
    response_content = res
  )
}


# use retry-after info when possible
# https://docs.github.com/en/rest/overview/resources-in-the-rest-api#exceeding-the-rate-limit
github_is_transient <- function(resp, max_wait) {
  if (httr2::resp_status(resp) != 403) {
    return(FALSE)
  }
  if (!identical(httr2::resp_header(resp, "x-ratelimit-remaining"), "0")) {
    return(FALSE)
  }

  time <- httr2::resp_header(resp, "x-ratelimit-reset")
  if (is.null(time)) {
    return(FALSE)
  }

  time <- as.numeric(time)
  minutes_to_wait <- (time - unclass(Sys.time()))
  minutes_to_wait <= max_wait
}
github_after <- function(resp) {
  time <- as.numeric(httr2::resp_header(resp, "x-ratelimit-reset"))
  time - unclass(Sys.time())
}
