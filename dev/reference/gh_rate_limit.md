# Return GitHub user's current rate limits

`gh_rate_limits()` reports on all rate limits for the authenticated
user. `gh_rate_limit()` reports on rate limits for previous successful
request.

Further details on GitHub's API rate limit policies are available at
<https://docs.github.com/v3/#rate-limiting>.

## Usage

``` r
gh_rate_limit(
  response = NULL,
  .token = NULL,
  .api_url = NULL,
  .send_headers = NULL
)

gh_rate_limits(.token = NULL, .api_url = NULL, .send_headers = NULL)
```

## Arguments

- response:

  `gh_response` object from a previous `gh` call, rate limit values are
  determined from values in the response header. Optional argument, if
  missing a call to "GET /rate_limit" will be made.

- .token:

  Authentication token. Defaults to
  [`gh_token()`](https://gh.r-lib.org/dev/reference/gh_token.md).

- .api_url:

  Github API url (default: <https://api.github.com>). Used if `endpoint`
  just contains a path. Defaults to `GITHUB_API_URL` environment
  variable if set.

- .send_headers:

  Named character vector of header field values (except `Authorization`,
  which is handled via `.token`). This can be used to override or
  augment the default `User-Agent` header:
  `"https://github.com/r-lib/gh"`.

## Value

A `list` object containing the overall `limit`, `remaining` limit, and
the limit `reset` time.
