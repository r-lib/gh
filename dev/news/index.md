# Changelog

## gh (development version)

## gh 1.5.0

CRAN release: 2025-05-26

### BREAKING CHANGES

#### Posit Security Advisory(PSA) - PSA-1649

- Posit acknowledges that the response header may contain sensitive
  information. ([\#222](https://github.com/r-lib/gh/issues/222)) Thank
  you to [@foysal1197](https://github.com/foysal1197) for your thorough
  research and responsible disclosure.

[`gh()`](https://gh.r-lib.org/dev/reference/gh.md), and other functions
that use it, now do not save the request headers in the returned object.
Consequently, if you use the
[`gh_next()`](https://gh.r-lib.org/dev/reference/gh_next.md),
[`gh_prev()`](https://gh.r-lib.org/dev/reference/gh_next.md),
[`gh_first()`](https://gh.r-lib.org/dev/reference/gh_next.md) or
[`gh_last()`](https://gh.r-lib.org/dev/reference/gh_next.md) functions
and passed `.token` and/or `.send_headers` explicitly to the original
[`gh()`](https://gh.r-lib.org/dev/reference/gh.md) (or similar) call,
then you’ll also need to pass the same `.token` and/or `.send_headers`
to [`gh_next()`](https://gh.r-lib.org/dev/reference/gh_next.md),
[`gh_prev()`](https://gh.r-lib.org/dev/reference/gh_next.md),
[`gh_first()`](https://gh.r-lib.org/dev/reference/gh_next.md) or
[`gh_last()`](https://gh.r-lib.org/dev/reference/gh_next.md).

### OTHER CHANGES

- New
  [`gh_token_exists()`](https://gh.r-lib.org/dev/reference/gh_token.md)
  tells you if a valid GH token has been set.

- [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) now uses a cache
  provided by httr2. This cache lives in
  `tools::R_user_dir("gh", "cache")`, maxes out at 100 MB, and can be
  disabled by setting `options(gh_cache = FALSE)`
  ([\#203](https://github.com/r-lib/gh/issues/203)).

- [`gh_token()`](https://gh.r-lib.org/dev/reference/gh_token.md) can now
  pick up on the viewer’s GitHub credentials (if any) when running on
  Posit Connect ([@atheriel](https://github.com/atheriel),
  [\#217](https://github.com/r-lib/gh/issues/217)).

## gh 1.4.1

CRAN release: 2024-03-28

- [`gh_next()`](https://gh.r-lib.org/dev/reference/gh_next.md),
  [`gh_prev()`](https://gh.r-lib.org/dev/reference/gh_next.md),
  [`gh_first()`](https://gh.r-lib.org/dev/reference/gh_next.md) and
  [`gh_last()`](https://gh.r-lib.org/dev/reference/gh_next.md) now work
  correctly again ([\#181](https://github.com/r-lib/gh/issues/181)).

- When the user sets `.destfile` to write the response to disk, gh now
  writes the output to a temporary file, which is then renamed to
  `.destfile` after performing the request, or deleted on error
  ([\#178](https://github.com/r-lib/gh/issues/178)).

## gh 1.4.0

CRAN release: 2023-02-22

- [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) gains a new
  `.max_rate` parameter that sets the maximum number of requests per
  second.

- gh is now powered by httr2. This should generally have little impact
  on normal operation but if a request fails, you can use
  [`httr2::last_response()`](https://httr2.r-lib.org/reference/last_response.html)
  and
  [`httr2::last_request()`](https://httr2.r-lib.org/reference/last_response.html)
  to debug.

- [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) gains a new
  `.max_wait` argument which gives the maximum number of minutes to wait
  if you are rate limited
  ([\#67](https://github.com/r-lib/gh/issues/67)).

- New
  [`gh_rate_limits()`](https://gh.r-lib.org/dev/reference/gh_rate_limit.md)
  function reports on all rate limits for the active user.

- gh can now validate GitHub
  [fine-grained](https://github.blog/security/application-security/introducing-fine-grained-personal-access-tokens-for-github/)
  personal access tokens ([@jvstein](https://github.com/jvstein),
  [\#171](https://github.com/r-lib/gh/issues/171)).

## gh 1.3.1

CRAN release: 2022-09-08

- gh now accepts lower-case methods i.e. both
  `gh::gh("get /users/hadley/repos")` and
  `gh::gh("GET /users/hadley/repos")` work
  ([@maelle](https://github.com/maelle),
  [\#167](https://github.com/r-lib/gh/issues/167)).

- Response headers (`"response_headers"`) and response content
  (`"response_content")` are now returned in error conditions so that
  error handlers can use information, such as the rate limit reset
  header, when handling `github_error`s
  ([@gadenbuie](https://github.com/gadenbuie),
  [\#117](https://github.com/r-lib/gh/issues/117)).

## gh 1.3.0

CRAN release: 2021-04-30

- gh now shows the correct number of records in its progress bar when
  paginating ([\#147](https://github.com/r-lib/gh/issues/147)).

- New `.params` argument in
  [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) to make it easier
  to pass parameters to it programmatically
  ([\#140](https://github.com/r-lib/gh/issues/140)).

## gh 1.2.1

CRAN release: 2021-04-01

- Token validation accounts for the new format [announced
  2021-03-04](https://github.blog/changelog/2021-03-04-authentication-token-format-updates/)
  and implemented on 2021-04-01
  ([\#148](https://github.com/r-lib/gh/issues/148),
  [@fmichonneau](https://github.com/fmichonneau)).

## gh 1.2.0

CRAN release: 2020-11-27

- [`gh_gql()`](https://gh.r-lib.org/dev/reference/gh_gql.md) now passes
  all arguments to [`gh()`](https://gh.r-lib.org/dev/reference/gh.md)
  ([\#124](https://github.com/r-lib/gh/issues/124)).

- gh now handles responses from pagination better, and tries to properly
  merge them ([\#136](https://github.com/r-lib/gh/issues/136),
  [@rundel](https://github.com/rundel)).

- gh can retrieve a PAT from the Git credential store, where the lookup
  is based on the targeted API URL. This now uses the gitcreds package.
  The environment variables consulted for URL-specific GitHub PATs have
  changed.

  - For “<https://api.github.com>”: `GITHUB_PAT_GITHUB_COM` now, instead
    of `GITHUB_PAT_API_GITHUB_COM`
  - For “<https://github.acme.com/api/v3>”: `GITHUB_PAT_GITHUB_ACME_COM`
    now, instead of `GITHUB_PAT_GITHUB_ACME_COM_API_V3`

  See the documentation of the gitcreds package for details.

- The keyring package is no longer used, in favor of the Git credential
  store.

- The documentation for the GitHub REST API has moved to
  <https://docs.github.com/rest> and endpoints are now documented using
  the URI template style of [RFC
  6570](https://www.rfc-editor.org/rfc/rfc6570):

  - Old: `GET /repos/:owner/:repo/issues`
  - New: `GET /repos/{owner}/{repo}/issues`

  gh accepts and prioritizes the new style. However, it still does
  parameter substitution for the old style.

- Fixed an error that occurred when calling
  [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) with
  `.progress = FALSE` ([@gadenbuie](https://github.com/gadenbuie),
  [\#115](https://github.com/r-lib/gh/issues/115)).

- [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) accepts named `NA`
  parameters that are destined for the request body
  ([\#139](https://github.com/r-lib/gh/issues/139)).

## gh 1.1.0

CRAN release: 2020-01-24

- Raw responses from GitHub are now returned as raw vector.

- Responses may be written to disk by providing a path in the
  `.destfile` argument.

- gh now sets `.Last.error` to the error object after an uncaught error,
  and `.Last.error.trace` to the stack trace of the error.

- [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) now silently drops
  named `NULL` parameters, and throws an error for named `NA` parameters
  ([\#21](https://github.com/r-lib/gh/issues/21),
  [\#84](https://github.com/r-lib/gh/issues/84)).

- [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) now returns better
  values for empty responses, typically empty lists or dictionaries
  ([\#66](https://github.com/r-lib/gh/issues/66)).

- [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) now has an
  `.accept` argument to make it easier to set the `Accept` HTTP header
  ([\#91](https://github.com/r-lib/gh/issues/91)).

- New [`gh_gql()`](https://gh.r-lib.org/dev/reference/gh_gql.md)
  function to make it easier to work with the GitHub GraphQL API.

- gh now supports separate personal access tokens for GitHub Enterprise
  sites. See
  [`?gh_token`](https://gh.r-lib.org/dev/reference/gh_token.md) for
  details.

- gh now supports storing your GitHub personal access tokens (PAT) in
  the system keyring, via the keyring package. See
  [`?gh_token`](https://gh.r-lib.org/dev/reference/gh_token.md) for
  details.

- [`gh()`](https://gh.r-lib.org/dev/reference/gh.md) can now POST raw
  data, which allows adding assets to releases
  ([\#56](https://github.com/r-lib/gh/issues/56)).

## gh 1.0.1

CRAN release: 2017-07-16

First public release.
