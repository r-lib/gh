# gh (development version)

* The environment variables consulted for URL-specific GitHub PATs have changed.
  - For "https://api.github.com": `GITHUB_PAT_GITHUB_COM` now, instead of
    `GITHUB_PAT_API_GITHUB_COM`
  - For "https://github.acme.com/api/v3": `GITHUB_PAT_GITHUB_ACME_COM` now,
    instead of `GITHUB_PAT_GITHUB_ACME_COM_API_V3`
This also affects the keys searched keyring support is turned on.

* gh only consults the `GITHUB_PAT` or `GITHUB_TOKEN` environment variables
  when the targeted host is "github.com". For other GitHub deployments, e.g.
  "github.acme.com", only the URL-specific environment variable is consulted,
  e.g. `GITHUB_PAT_GITHUB_ACME_COM`.

* The documentation for the GitHub REST API has moved to
  <https://docs.github.com/rest> and endpoints are now documented using
  the URI template style of [RFC 6570](https://tools.ietf.org/html/rfc6570):
  
  - Old: `GET /repos/:owner/:repo/issues`
  - New: `GET /repos/{owner}/{repo}/issues`

  gh accepts and prioritizes the new style. However, it still does parameter
  substitution for the old style.

* Fixed an error that occurred when calling `gh()` with `.progress = FALSE` 
  (@gadenbuie, #115).

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
