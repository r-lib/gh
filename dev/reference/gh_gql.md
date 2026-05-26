# A simple interface for the GitHub GraphQL API v4.

See more about the GraphQL API here: <https://docs.github.com/graphql>

## Usage

``` r
gh_gql(query, ...)
```

## Arguments

- query:

  The GraphQL query, as a string.

- ...:

  Name-value pairs giving API parameters. Will be matched into
  `endpoint` placeholders, sent as query parameters in GET requests, and
  as a JSON body of POST requests. If there is only one unnamed
  parameter, and it is a raw vector, then it will not be JSON encoded,
  but sent as raw data, as is. This can be used for example to add
  assets to releases. Named `NULL` values are silently dropped. For GET
  requests, named `NA` values trigger an error. For other methods, named
  `NA` values are included in the body of the request, as JSON `null`.

## Details

Note: pagination and the `.limit` argument does not work currently, as
pagination in the GraphQL API is different from the v3 API. If you need
pagination with GraphQL, you'll need to do that manually.

## See also

[`gh()`](https://gh.r-lib.org/dev/reference/gh.md) for the GitHub v3
API.

## Examples

``` r
if (FALSE) {
gh_gql("query { viewer { login }}")

# Get rate limit
ratelimit_query <- "query {
  viewer {
    login
  }
  rateLimit {
    limit
    cost
    remaining
    resetAt
  }
}"

gh_gql(ratelimit_query)
}
```
