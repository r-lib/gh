#' A fake GitHub web app
#'
#' A [webfakes::new_app()] application that implements the subset of the
#' GitHub REST API needed by the gh test suite. It is exported so that
#' downstream packages that depend on gh can use it to test their own
#' GitHub-backed code without hitting the real API.
#'
#' The app accepts any token whose shape is a valid GitHub PAT (40 hex
#' characters or a `ghp_` / `github_pat_` / `ghs_` / `ghr_` / `gho_` /
#' `ghu_` prefix). Any other non-empty token is rejected with a 401
#' "Bad credentials". A missing `Authorization` header yields a 401
#' "Requires authentication" for endpoints that need a user.
#'
#' @return A `webfakes_app` object.
#' @export
#' @examplesIf rlang::is_installed("webfakes")
#' app <- fake_github_app()
#' proc <- webfakes::new_app_process(app)
#' proc$url()
#' proc$stop()
fake_github_app <- function() {
  check_installed("webfakes")

  app <- webfakes::new_app()
  app$use(webfakes::mw_json())
  app$use(webfakes::mw_raw())

  # gh treats non-github.com hosts as GitHub Enterprise and prefixes
  # request paths with /api/v3. Strip that here so the fake can mount
  # routes at the GitHub.com API paths.
  app$use(function(req, res) {
    if (startsWith(req$path, "/api/v3/")) {
      req$path <- substring(req$path, nchar("/api/v3") + 1L)
    }
    "next"
  })

  app$use(function(req, res) {
    auth <- req$get_header("Authorization") %||% ""
    res$locals$auth_present <- nzchar(auth)
    token <- if (grepl("^token\\s+", auth, ignore.case = TRUE)) {
      sub("^token\\s+", "", auth, ignore.case = TRUE)
    } else if (grepl("^bearer\\s+", auth, ignore.case = TRUE)) {
      sub("^bearer\\s+", "", auth, ignore.case = TRUE)
    } else {
      ""
    }
    res$locals$token <- token
    res$locals$token_valid <- nzchar(token) && fake_gh_token_valid(token)
    "next"
  })

  app$get("/missing", function(req, res) {
    fake_gh_error(res, 404L, "Not Found")
  })

  # Mirrors the real 422 returned when a (sha, context) pair has reached the
  # max number of commit statuses. GitHub returns `errors` as a plain string
  # here rather than the usual array of objects (see #229).
  app$post(
    "/repos/:owner/:repo/statuses/:sha",
    function(req, res) {
      res$set_status(422L)$send_json(
        list(
          message = "Validation Failed",
          errors = "Validation failed: This SHA and context has reached the maximum number of statuses.",
          documentation_url = "https://docs.github.com/rest/commits/statuses#create-a-commit-status",
          status = "422"
        ),
        auto_unbox = TRUE
      )
    }
  )

  app$get("/user", function(req, res) {
    if (!isTRUE(res$locals$auth_present)) {
      return(fake_gh_error(res, 401L, "Requires authentication"))
    }
    if (!isTRUE(res$locals$token_valid)) {
      return(fake_gh_error(res, 401L, "Bad credentials"))
    }
    res$set_header("x-oauth-scopes", "gist, repo, user")$send_json(
      list(
        login = "fakeuser",
        name = "Fake User",
        html_url = "https://github.com/fakeuser"
      ),
      auto_unbox = TRUE
    )
  })

  app$get("/rate_limit", function(req, res) {
    if (isTRUE(res$locals$auth_present) && !isTRUE(res$locals$token_valid)) {
      return(fake_gh_error(res, 401L, "Bad credentials"))
    }
    reset <- as.integer(unclass(Sys.time())) + 3600L
    one <- list(limit = 5000L, used = 0L, remaining = 5000L, reset = reset)
    res$set_header("x-ratelimit-limit", "5000")$set_header(
      "x-ratelimit-remaining",
      "5000"
    )$set_header("x-ratelimit-reset", as.character(reset))$send_json(
      list(
        resources = list(
          core = one,
          search = one,
          graphql = one,
          integration_manifest = one,
          code_scanning_upload = one
        ),
        rate = one
      ),
      auto_unbox = TRUE
    )
  })

  app$get("/orgs/:org/repos", function(req, res) {
    org <- req$params$org
    if (identical(org, "gh-org-testing-no-repos")) {
      return(res$send_json(list(), auto_unbox = TRUE))
    }
    if (identical(org, "gh-org-testing-404")) {
      return(fake_gh_error(res, 404L, "Not Found"))
    }
    repos <- fake_repos_for(org)
    send_paginated(req, res, repos, base_path = req$path)
  })

  # Raw body echo: read the entire raw body and echo it back. Used to
  # exercise gh's raw-body POST path.
  app$post("/echo-raw", function(req, res) {
    body <- if (length(req$raw)) req$raw else raw()
    res$set_type("application/octet-stream")$send(body)
  })

  # Cursor-style pagination: emits only a `next` link (no `last`), so the
  # client cannot learn the total page count up front.
  app$get("/cursor-list", function(req, res) {
    per_page <- clamp_int(req$query$per_page, default = 10L, max = 100L)
    page <- clamp_int(req$query$page, default = 1L, max = .Machine$integer.max)
    total <- 25L
    last_page <- ceiling(total / per_page)
    start <- (page - 1L) * per_page + 1L
    stop <- min(page * per_page, total)
    slice <- lapply(start:stop, function(i) list(id = i))
    if (page < last_page) {
      host <- req$get_header("Host") %||% "127.0.0.1"
      url <- paste0(
        req$protocol,
        "://",
        host,
        req$path,
        "?per_page=",
        per_page,
        "&page=",
        page + 1L
      )
      res$set_header("Link", paste0("<", url, '>; rel="next"'))
    }
    res$send_json(slice, auto_unbox = TRUE)
  })

  # GitHub returns Link header URLs against /organizations/{id}/repos for
  # subsequent pages. The fake app mirrors that to exercise the
  # cross-path pagination logic.
  app$get(
    "/organizations/:id/repos",
    function(req, res) {
      repos <- fake_repos_for("tidyverse")
      send_paginated(req, res, repos, base_path = req$path)
    }
  )

  app$get("/users/:user/repos", function(req, res) {
    etag <- paste0("\"users-", req$params$user, "-v1\"")
    res$set_header("ETag", etag)
    if (identical(req$get_header("If-None-Match"), etag)) {
      return(res$send_status(304L))
    }
    repos <- fake_repos_for(req$params$user)
    send_paginated(req, res, repos, base_path = req$path)
  })

  app$get("/repositories", function(req, res) {
    repos <- fake_repos_for("public")
    send_paginated(req, res, repos, base_path = req$path)
  })

  app$get("/users", function(req, res) {
    users <- fake_user_list(60L)
    send_paginated(req, res, users, base_path = req$path)
  })

  app$get(
    "/repos/:owner/:repo/contents/:path",
    function(req, res) {
      raw_requested <- grepl(
        "application/vnd.github(\\.v3)?\\.raw",
        req$get_header("Accept") %||% "",
        ignore.case = TRUE
      )
      if (raw_requested) {
        body <- charToRaw(paste0(
          "Package: ",
          req$params$repo,
          "\n",
          "Title: Fake content of ",
          req$params$path,
          "\n"
        ))
        res$set_header("x-github-media-type", "github.v3; param=raw")$set_type(
          "application/octet-stream"
        )$send(body)
      } else {
        res$set_header(
          "x-github-media-type",
          "github.v3; param=json"
        )$send_json(
          list(
            name = req$params$path,
            path = req$params$path,
            type = "file",
            content = "ZmFrZQ==",
            encoding = "base64"
          ),
          auto_unbox = TRUE
        )
      }
    }
  )

  app$post("/graphql", function(req, res) {
    query <- req$json$query %||% ""
    res$send_json(
      list(
        data = list(
          viewer = list(login = "fakeuser"),
          echo = query
        )
      ),
      auto_unbox = TRUE
    )
  })

  app$post("/markdown", function(req, res) {
    text <- req$json$text %||% ""
    if (!nzchar(text)) {
      return(res$send_status(200L))
    }
    res$set_type("text/html")$send(paste0("<p>", text, "</p>\n"))
  })

  app$get("/search/repositories", function(req, res) {
    items <- fake_repos_for("search")
    send_search(req, res, items)
  })

  app$get("/search/issues", function(req, res) {
    items <- fake_issues(60L)
    # Filter by `label:"..."` so a mangled q (e.g. space re-encoded as
    # literal `+` on a later page) returns no matches. This is what
    # surfaces the bug from #210.
    q <- req$query$q %||% ""
    m <- regmatches(q, regexpr('label:"([^"]+)"', q))
    if (length(m) == 1L) {
      label <- sub('label:"([^"]+)"', "\\1", m)
      items <- Filter(
        function(x) {
          any(vapply(
            x$labels,
            function(l) identical(l$name, label),
            logical(1)
          ))
        },
        items
      )
    }
    send_search(req, res, items)
  })

  app$post("/gists", function(req, res) {
    id <- as.character(as.integer(Sys.time()) + sample.int(1e6, 1L))
    gist <- list(
      id = id,
      description = req$json$description %||% "",
      public = req$json$public %||% FALSE,
      files = req$json$files %||% list()
    )
    fake_state_init(req)
    req$app$locals$gists[[id]] <- gist
    res$set_status(201L)$send_json(gist, auto_unbox = TRUE)
  })

  app$patch("/gists/:id", function(req, res) {
    id <- req$params$id
    fake_state_init(req)
    gist <- req$app$locals$gists[[id]]
    if (is.null(gist)) {
      return(fake_gh_error(res, 404L, "Not Found"))
    }
    for (nm in names(req$json)) {
      gist[[nm]] <- req$json[[nm]]
    }
    req$app$locals$gists[[id]] <- gist
    res$send_json(gist, auto_unbox = TRUE)
  })

  app$delete("/gists/:id", function(req, res) {
    id <- req$params$id
    fake_state_init(req)
    if (is.null(req$app$locals$gists[[id]])) {
      return(fake_gh_error(res, 404L, "Not Found"))
    }
    req$app$locals$gists[[id]] <- NULL
    res$send_status(204L)
  })

  app
}

fake_state_init <- function(req) {
  if (is.null(req$app$locals$gists)) {
    req$app$locals$gists <- list()
  }
}

fake_gh_token_valid <- function(token) {
  grepl(
    "^(gh[pousr]_[A-Za-z0-9_]{36,251}|github_pat_[A-Za-z0-9_]{36,244}|ghs_.+)$",
    token
  ) ||
    grepl("^[[:xdigit:]]{40}$", token)
}

fake_gh_error <- function(res, status, message) {
  res$set_status(status)$send_json(
    list(
      message = message,
      documentation_url = "https://docs.github.com/rest"
    ),
    auto_unbox = TRUE
  )
}

fake_repos_for <- function(slug) {
  names <- switch(
    slug,
    "r-lib" = c(
      "actions",
      "cli",
      "covr",
      "devtools",
      "fs",
      "gh",
      "httr2",
      "pkgbuild",
      "pkgload",
      "rcmdcheck",
      "remotes",
      "rlang",
      "roxygen2",
      "testthat",
      "usethis",
      "withr"
    ),
    "tidyverse" = sprintf("repo-%02d", 1:60),
    "search" = sprintf("tidy-%02d", 1:60),
    sprintf("%s-repo-%02d", slug, 1:30)
  )
  owner <- if (slug %in% c("search", "public")) "someone" else slug
  lapply(seq_along(names), function(i) {
    list(
      id = 1000L + i,
      name = names[[i]],
      full_name = paste0(owner, "/", names[[i]]),
      owner = list(login = owner)
    )
  })
}

fake_user_list <- function(n) {
  lapply(seq_len(n), function(i) {
    list(
      id = i,
      login = sprintf("user%02d", i),
      type = "User"
    )
  })
}

fake_issues <- function(n) {
  lapply(seq_len(n), function(i) {
    list(
      id = i,
      number = i,
      title = sprintf("Issue %d", i),
      labels = list(list(name = "tidy-dev-day :nerd_face:"))
    )
  })
}

send_paginated <- function(req, res, items, base_path) {
  per_page <- clamp_int(req$query$per_page, default = 30L, max = 100L)
  page <- clamp_int(req$query$page, default = 1L, max = .Machine$integer.max)
  total <- length(items)
  last_page <- max(1L, ceiling(total / per_page))
  page <- min(page, last_page)
  start <- (page - 1L) * per_page + 1L
  stop <- min(page * per_page, total)
  slice <- if (total == 0L) list() else items[start:stop]

  set_link_header(req, res, base_path, page, last_page, per_page)
  res$send_json(slice, auto_unbox = TRUE)
}

send_search <- function(req, res, items) {
  per_page <- clamp_int(req$query$per_page, default = 30L, max = 100L)
  page <- clamp_int(req$query$page, default = 1L, max = .Machine$integer.max)
  total <- length(items)
  last_page <- max(1L, ceiling(total / per_page))
  page <- min(page, last_page)
  start <- (page - 1L) * per_page + 1L
  stop <- min(page * per_page, total)
  slice <- if (total == 0L) list() else items[start:stop]

  set_link_header(req, res, req$path, page, last_page, per_page)
  res$send_json(
    list(
      total_count = total,
      incomplete_results = FALSE,
      items = slice
    ),
    auto_unbox = TRUE
  )
}

set_link_header <- function(req, res, base_path, page, last_page, per_page) {
  if (last_page <= 1L) {
    return(invisible())
  }
  host <- req$get_header("Host") %||% "127.0.0.1"
  base <- paste0(req$protocol, "://", host)
  query <- req$query
  query$per_page <- per_page
  build <- function(p) {
    q <- query
    q$page <- p
    parts <- mapply(
      function(k, v) {
        # Match real GitHub: percent-encode reserved chars, but spaces
        # in query values come back as `+` rather than `%20`.
        enc <- utils::URLencode(as.character(v), reserved = TRUE)
        enc <- gsub("%20", "+", enc, fixed = TRUE)
        paste0(k, "=", enc)
      },
      names(q),
      q,
      USE.NAMES = FALSE
    )
    paste0(base, base_path, "?", paste(parts, collapse = "&"))
  }
  parts <- character()
  if (page < last_page) {
    parts <- c(parts, paste0("<", build(page + 1L), '>; rel="next"'))
    parts <- c(parts, paste0("<", build(last_page), '>; rel="last"'))
  }
  if (page > 1L) {
    parts <- c(parts, paste0("<", build(1L), '>; rel="first"'))
    parts <- c(parts, paste0("<", build(page - 1L), '>; rel="prev"'))
  }
  res$set_header("Link", paste(parts, collapse = ", "))
}

clamp_int <- function(x, default, max) {
  if (is.null(x) || !nzchar(x)) {
    return(default)
  }
  x <- suppressWarnings(as.integer(x))
  if (is.na(x) || x < 1L) {
    return(default)
  }
  min(x, max)
}
