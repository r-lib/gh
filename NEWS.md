# gh 1.4.1

* `gh_next()`, `gh_prev()`, `gh_first()` and `gh_last()`
  now work correctly again (#181).

* When the user sets `.destfile` to write the response to disk, gh now
  writes the output to a temporary file, which is then renamed to
  `.destfile` after performing the request, or deleted on error (#178).

# gh 1.4.0

* `gh()` gains a new `.max_rate` parameter that sets the maximum number of
  requests per second.

* gh is now powered by httr2. This should generally have little impact on normal
  operation but if a request fails, you can use `httr2::last_response()` and
  `httr2::last_request()` to debug.

* `gh()` gains a new `.max_wait` argument which gives the maximum number of
  minutes to wait if you are rate limited (#67).

* New `gh_rate_limits()` function reports on all rate limits for the active
  user.

* gh can now validate GitHub
  [fine-grained](https://github.blog/2022-10-18-introducing-fine-grained-personal-access-tokens-for-github/)
  personal access tokens (@jvstein, #171).

# gh 1.3.1

* gh now accepts lower-case methods i.e. both `gh::gh("get /users/hadley/repos")` and `gh::gh("GET /users/hadley/repos")` work (@maelle, #167).

* Response headers (`"response_headers"`) and response content
  (`"response_content")` are now returned in error conditions so that error
  handlers can use information, such as the rate limit reset header, when
  handling `github_error`s (@gadenbuie, #117).

# gh 1.3.0

* gh now shows the correct number of records in its progress bar when
  paginating (#147).

* New `.params` argument in `gh()` to make it easier to pass parameters to
  it programmatically (#140).

# gh 1.2.1

* Token validation accounts for the new format
  [announced 2021-03-04 ](https://github.blog/changelog/2021-03-04-authentication-token-format-updates/)
  and implemented on 2021-04-01 (#148, @fmichonneau).

# gh 1.2.0

* `gh_gql()` now passes all arguments to `gh()` (#124).

* gh now handles responses from pagination better, and tries to properly
  merge them (#136, @rundel).

* gh can retrieve a PAT from the Git credential store, where the lookup is
  based on the targeted API URL. This now uses the gitcreds package. The
  environment variables consulted for URL-specific GitHub PATs have changed.
  - For "https://api.github.com": `GITHUB_PAT_GITHUB_COM` now, instead of
    `GITHUB_PAT_API_GITHUB_COM`
  - For "https://github.acme.com/api/v3": `GITHUB_PAT_GITHUB_ACME_COM` now,
    instead of `GITHUB_PAT_GITHUB_ACME_COM_API_V3`

  See the documentation of the gitcreds package for details.

* The keyring package is no longer used, in favor of the Git credential
  store.

* The documentation for the GitHub REST API has moved to
  <https://docs.github.com/rest> and endpoints are now documented using
  the URI template style of [RFC 6570](https://www.rfc-editor.org/rfc/rfc6570):
  - Old: `GET /repos/:owner/:repo/issues`
  - New: `GET /repos/{owner}/{repo}/issues`

  gh accepts and prioritizes the new style. However, it still does parameter
  substitution for the old style.

* Fixed an error that occurred when calling `gh()` with `.progress = FALSE`
  (@gadenbuie, #115).

* `gh()` accepts named `NA` parameters that are destined for the request
  body (#139).

# gh 1.1.0

* Raw responses from GitHub are now returned as raw vector.

* Responses may be written to disk by providing a path in the `.destfile`
  argument.

* gh now sets `.Last.error` to the error object after an uncaught error,
  and `.Last.error.trace` to the stack trace of the error.

* `gh()` now silently drops named `NULL` parameters, and throws an
  error for named `NA` parameters (#21, #84).

* `gh()` now returns better values for empty responses, typically empty
  lists or dictionaries (#66).

* `gh()` now has an `.accept` argument to make it easier to set the
  `Accept` HTTP header (#91).

* New `gh_gql()` function to make it easier to work with the GitHub
  GraphQL API.

* gh now supports separate personal access tokens for GitHub Enterprise
  sites. See `?gh_token` for details.

* gh now supports storing your GitHub personal access tokens (PAT) in the
  system keyring, via the keyring package. See `?gh_token` for details.

* `gh()` can now POST raw data, which allows adding assets to releases (#56).

# gh 1.0.1

First public release.
