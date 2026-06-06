# A fake GitHub web app

A
[`webfakes::new_app()`](https://webfakes.r-lib.org/reference/new_app.html)
application that implements the subset of the GitHub REST API needed by
the gh test suite. It is exported so that downstream packages that
depend on gh can use it to test their own GitHub-backed code without
hitting the real API.

## Usage

``` r
fake_github_app()
```

## Value

A `webfakes_app` object.

## Details

The app accepts any token whose shape is a valid GitHub PAT (40 hex
characters or a `ghp_` / `github_pat_` / `ghs_` / `ghr_` / `gho_` /
`ghu_` prefix). Any other non-empty token is rejected with a 401 "Bad
credentials". A missing `Authorization` header yields a 401 "Requires
authentication" for endpoints that need a user.

## Examples

``` r
app <- fake_github_app()
proc <- webfakes::new_app_process(app)
proc$url()
#> [1] "http://127.0.0.1:33613/"
proc$stop()
```
