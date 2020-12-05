
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gh

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-lib/gh/workflows/R-CMD-check/badge.svg)](https://github.com/r-lib/gh/actions)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/gh/branch/master/graph/badge.svg)](https://codecov.io/gh/r-lib/gh?branch=master)
[![](https://www.r-pkg.org/badges/version/gh)](https://www.r-pkg.org/pkg/gh)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/gh)](https://www.r-pkg.org/pkg/gh)
<!-- badges: end -->

Minimalistic client to access GitHub’s
[REST](https://docs.github.com/rest) and
[GraphQL](https://docs.github.com/graphql) APIs.

## Installation

Install the package from CRAN as usual:

``` r
install.packages("gh")
```

## Usage

``` r
library(gh)
```

Use the `gh()` function to access all API endpoints. The endpoints are
listed in the [documentation](https://docs.github.com/rest).

The first argument of `gh()` is the endpoint. You can just copy and
paste the API endpoints from the documentation. Note that the leading
slash must be included as well.

From
<https://docs.github.com/rest/reference/repos#list-repositories-for-a-user>
you can copy and paste `GET /users/{username}/repos` into your `gh()`
call. E.g.

``` r
my_repos <- gh("GET /users/{username}/repos", username = "gaborcsardi")
vapply(my_repos, "[[", "", "name")
#>  [1] "alexr"        "altlist"      "argufy"       "disposables"  "dotenv"      
#>  [6] "falsy"        "franc"        "ISA"          "keypress"     "lpSolve"     
#> [11] "macBriain"    "maxygen"      "MISO"         "msgtools"     "notifier"    
#> [16] "oskeyring"    "parr"         "parsedate"    "prompt"       "r-font"      
#> [21] "r-source"     "rcorpora"     "roxygenlabs"  "sankey"       "secret"      
#> [26] "spark"        "standalones"  "svg-term"     "tamper"       "testthatlabs"
```

The JSON result sent by the API is converted to an R object.

Parameters can be passed as extra arguments. E.g.

``` r
my_repos <- gh(
  "/users/{username}/repos",
  username = "gaborcsardi",
  sort = "created")
vapply(my_repos, "[[", "", "name")
#>  [1] "oskeyring"    "testthatlabs" "lpSolve"      "roxygenlabs"  "standalones" 
#>  [6] "altlist"      "svg-term"     "franc"        "sankey"       "r-source"    
#> [11] "secret"       "msgtools"     "notifier"     "prompt"       "parr"        
#> [16] "tamper"       "alexr"        "argufy"       "maxygen"      "keypress"    
#> [21] "macBriain"    "MISO"         "rcorpora"     "disposables"  "spark"       
#> [26] "dotenv"       "parsedate"    "r-font"       "falsy"        "ISA"
```

### POST, PATCH, PUT and DELETE requests

POST, PATCH, PUT, and DELETE requests can be sent by including the HTTP
verb before the endpoint, in the first argument. E.g. to create a
repository:

``` r
new_repo <- gh("POST /user/repos", name = "my-new-repo-for-gh-testing")
```

and then delete it:

``` r
gh("DELETE /repos/{owner}/{repo}", owner = "gaborcsardi",
   repo = "my-new-repo-for-gh-testing")
```

### Tokens

By default the `GITHUB_PAT` environment variable is used. Alternatively,
one can set the `.token` argument of `gh()`.

### Pagination

Supply the `page` parameter to get subsequent pages:

``` r
my_repos2 <- gh("GET /orgs/{org}/repos", org = "r-lib", page = 2)
vapply(my_repos2, "[[", "", "name")
#>  [1] "rcmdcheck"   "vdiffr"      "callr"       "mockery"     "here"       
#>  [6] "revdepcheck" "processx"    "vctrs"       "debugme"     "usethis"    
#> [11] "rlang"       "pkgload"     "httrmock"    "pkgbuild"    "prettycode" 
#> [16] "roxygen2md"  "pkgapi"      "zeallot"     "liteq"       "keyring"    
#> [21] "sloop"       "styler"      "ansistrings" "later"       "crancache"  
#> [26] "zip"         "osname"      "sessioninfo" "available"   "cli"
```

## Environment Variables

  - The `GITHUB_API_URL` environment variable is used for the default
    github api url.
  - One of `GITHUB_PAT` or `GITHUB_TOKEN` environment variables is used,
    in this order, as default token.

## License

MIT © Gábor Csárdi, Jennifer Bryan, Hadley Wickham
