
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gh

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-lib/gh/workflows/R-CMD-check/badge.svg)](https://github.com/r-lib/gh/actions)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/gh/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/gh?branch=main)
[![](https://www.r-pkg.org/badges/version/gh)](https://www.r-pkg.org/pkg/gh)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/gh)](https://www.r-pkg.org/pkg/gh)
[![R-CMD-check](https://github.com/r-lib/gh/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/gh/actions/workflows/R-CMD-check.yaml)
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
#>  [1] "after"         "alexr"         "altlist"       "argufy"       
#>  [5] "ask"           "async"         "brokenPackage" "butcher"      
#>  [9] "css"           "curl"          "disposables"   "dotenv"       
#> [13] "empty"         "falsy"         "finmix"        "franc"        
#> [17] "fswatch"       "homebrew-rim"  "ISA"           "keynote"      
#> [21] "keypress"      "lpSolve"       "macBriain"     "maxygen"      
#> [25] "MISO"          "msgtools"      "multicolor"    "notifier"     
#> [29] "odbc"          "parr"
```

The JSON result sent by the API is converted to an R object.

Parameters can be passed as extra arguments. E.g.

``` r
my_repos <- gh(
  "/users/{username}/repos",
  username = "gaborcsardi",
  sort = "created")
vapply(my_repos, "[[", "", "name")
#>  [1] "r-builds"              "homebrew-rim"          "rgdal"                
#>  [4] "readxl"                "sdcHierarchies"        "skopeo"               
#>  [7] "playground"            "r-system-requirements" "butcher"              
#> [10] "tidyr"                 "empty"                 "rim"                  
#> [13] "tidyverse.org"         "finmix"                "tune"                 
#> [16] "multicolor"            "pkgdepends"            "css"                  
#> [19] "curl"                  "usethis2"              "r-debug"              
#> [22] "purrr"                 "redfish"               "win32-console-docs"   
#> [25] "vt100-emulator"        "RSQLite"               "pkgload"              
#> [28] "rencfaq"               "renv"                  "stockfish"
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
#>  [1] "gargle"      "remotes"     "jose"        "backports"   "rcmdcheck"  
#>  [6] "vdiffr"      "callr"       "mockery"     "here"        "revdepcheck"
#> [11] "processx"    "vctrs"       "debugme"     "usethis"     "rlang"      
#> [16] "pkgload"     "httrmock"    "pkgbuild"    "prettycode"  "roxygen2md" 
#> [21] "pkgapi"      "zeallot"     "liteq"       "keyring"     "sloop"      
#> [26] "styler"      "ansistrings" "archive"     "later"       "crancache"
```

## Environment Variables

-   The `GITHUB_API_URL` environment variable is used for the default
    github api url.
-   One of `GITHUB_PAT` or `GITHUB_TOKEN` environment variables is used,
    in this order, as default token.

## Code of Conduct

Please note that the gh project is released with a [Contributor Code of
Conduct](https://gh.r-lib.org/CODE_OF_CONDUCT.html). By contributing to
this project, you agree to abide by its terms.

## License

MIT © Gábor Csárdi, Jennifer Bryan, Hadley Wickham
