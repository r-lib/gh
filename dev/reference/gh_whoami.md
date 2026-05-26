# Info on current GitHub user and token

Reports wallet name, GitHub login, and GitHub URL for the current
authenticated user, the first bit of the token, and the associated
scopes.

## Usage

``` r
gh_whoami(.token = NULL, .api_url = NULL, .send_headers = NULL)
```

## Arguments

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

A `gh_response` object, which is also a `list`.

## Details

Get a personal access token for the GitHub API from
<https://github.com/settings/tokens> and select the scopes necessary for
your planned tasks. The `repo` scope, for example, is one many are
likely to need.

On macOS and Windows it is best to store the token in the git credential
store, where most GitHub clients, including gh, can access it. You can
use the gitcreds package to add your token to the credential store:

    gitcreds::gitcreds_set()

See <https://gh.r-lib.org/articles/managing-personal-access-tokens.html>
and <https://usethis.r-lib.org/articles/articles/git-credentials.html>
for more about managing GitHub (and generic git) credentials.

On other systems, including Linux, the git credential store is typically
not as convenient, and you might want to store your token in the
`GITHUB_PAT` environment variable, which you can set in your `.Renviron`
file.

## Examples

``` r
gh_whoami()
#> Error in gh(endpoint = "/user", .token = .token, .api_url = .api_url,     .send_headers = .send_headers): GitHub API error (403): Resource not accessible by integration
#> ℹ Read more at
#>   <https://docs.github.com/rest/users/users#get-the-authenticated-user>
if (FALSE) {
## explicit token + use with GitHub Enterprise
gh_whoami(
  .token = "8c70fd8419398999c9ac5bacf3192882193cadf2",
  .api_url = "https://github.foobar.edu/api/v3"
)
}
```
