# Return the local user's GitHub Personal Access Token (PAT)

If gh can find a personal access token (PAT) via `gh_token()`, it
includes the PAT in its requests. Some requests succeed without a PAT,
but many require a PAT to prove the request is authorized by a specific
GitHub user. A PAT also helps with rate limiting. If your gh use is more
than casual, you want a PAT.

gh calls
[`gitcreds::gitcreds_get()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html)
with the `api_url`, which checks session environment variables
(`GITHUB_PAT`, `GITHUB_TOKEN`) and then the local Git credential store
for a PAT appropriate to the `api_url`. Therefore, if you have
previously used a PAT with, e.g., command line Git, gh may retrieve and
re-use it. You can call
[`gitcreds::gitcreds_get()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html)
directly, yourself, if you want to see what is found for a specific URL.
If no matching PAT is found,
[`gitcreds::gitcreds_get()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html)
errors, whereas `gh_token()` does not and, instead, returns `""`.

See GitHub's documentation on [Creating a personal access
token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token),
or use `usethis::create_github_token()` for a guided experience,
including pre-selection of recommended scopes. Once you have a PAT, you
can use
[`gitcreds::gitcreds_set()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html)
to add it to the Git credential store. From that point on, gh (via
[`gitcreds::gitcreds_get()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html))
should be able to find it without further effort on your part.

## Usage

``` r
gh_token(api_url = NULL)

gh_token_exists(api_url = NULL)
```

## Arguments

- api_url:

  GitHub API URL. Defaults to the `GITHUB_API_URL` environment variable,
  if set, and otherwise to <https://api.github.com>.

## Value

A string of characters, if a PAT is found, or the empty string,
otherwise. For convenience, the return value has an S3 class in order to
ensure that simple printing strategies don't reveal the entire PAT.

## Token format validation

gh warns if the PAT it retrieves does not match a known format. Set
`options(gh_validate_tokens = "off")` or the `GH_VALIDATE_TOKENS=off`
environment variable to avoid this warning. The option takes precedence
over the environment variable.

Set `options(gh_validate_tokens = "error")` or the
`GH_VALIDATE_TOKENS=error` environment variable to make gh throw an
error for an unrecognized PAT format.

## Examples

``` r
if (FALSE) { # \dontrun{
gh_token()

format(gh_token())

str(gh_token())
} # }
```
