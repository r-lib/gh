
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gh

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-lib/gh/workflows/R-CMD-check/badge.svg)](https://github.com/r-lib/gh/actions)
[![](https://www.r-pkg.org/badges/version/gh)](https://www.r-pkg.org/pkg/gh)
[![CRAN Posit mirror
downloads](https://cranlogs.r-pkg.org/badges/gh)](https://www.r-pkg.org/pkg/gh)
[![R-CMD-check](https://github.com/r-lib/gh/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/gh/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/gh/graph/badge.svg)](https://app.codecov.io/gh/r-lib/gh)
<!-- badges: end -->

Minimalistic client to access GitHub’s
[REST](https://docs.github.com/rest) and
[GraphQL](https://docs.github.com/graphql) APIs.

## Installation and setup

Install the package from CRAN as usual:

``` r
install.packages("gh")
```

Install the development version from GitHub:

``` r
pak::pak("r-lib/gh")
```

### Authentication

The value returned by `gh::gh_token()` is used as Personal Access Token
(PAT). A token is needed for some requests, and to help with rate
limiting. gh can use your regular git credentials in the git credential
store, via the gitcreds package. Use `gitcreds::gitcreds_set()` to put a
PAT into the git credential store. If you cannot use the credential
store, set the `GITHUB_PAT` environment variable to your PAT. See the
details in the `?gh::gh_token` manual page and the manual of the
gitcreds package.

### API URL

- The `GITHUB_API_URL` environment variable, if set, is used for the
  default github api url.

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
#>  [1] "after"                "air"                  "alda"                
#>  [4] "alexr"                "all.primer.tutorials" "altlist"             
#>  [7] "anticlust"            "argufy"               "ask"                 
#> [10] "async"                "autobrew-bundler"     "available-work"      
#> [13] "baguette"             "BCEA"                 "BH"                  
#> [16] "bigrquerystorage"     "brew-big-sur"         "brokenPackage"       
#> [19] "brulee"               "build-r-app"          "butcher"             
#> [22] "censored"             "cf-tunnel"            "checkinstall"        
#> [25] "cli"                  "clock"                "comments"            
#> [28] "covr"                 "covrlabs"             "cran-metadata"
```

The JSON result sent by the API is converted to an R object.

Parameters can be passed as extra arguments. E.g.

``` r
my_repos <- gh(
  "/users/{username}/repos",
  username = "gaborcsardi",
  sort = "created")
vapply(my_repos, "[[", "", "name")
#>  [1] "data-dict.yaml"     "vroom"              "rds2rust"          
#>  [4] "tree-sitter-toml"   "tstoml"             "tree-sitter-json"  
#>  [7] "uncovr"             "tsjsonc"            "opentelemetry-cpp" 
#> [10] "ellmer"             "air"                "s2"                
#> [13] "parzer"             "shinycoreci"        "secret-service-cli"
#> [16] "phantomjs"          "FSA"                "greta"             
#> [19] "webdriver"          "clock"              "testthat"          
#> [22] "jsonlite"           "duckdb"             "duckdb-r"          
#> [25] "httpuv"             "unwind"             "httr2"             
#> [28] "pins-r"             "install-figlet"     "weird-package"
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
#>  [1] "gh"          "desc"        "profvis"     "sodium"      "gargle"     
#>  [6] "remotes"     "jose"        "backports"   "rcmdcheck"   "vdiffr"     
#> [11] "callr"       "mockery"     "here"        "revdepcheck" "processx"   
#> [16] "vctrs"       "debugme"     "usethis"     "rlang"       "pkgload"    
#> [21] "httrmock"    "pkgbuild"    "prettycode"  "roxygen2md"  "pkgapi"     
#> [26] "zeallot"     "liteq"       "keyring"     "sloop"       "styler"
```

## Environment Variables and Options

- The `GITHUB_API_URL` environment variable is used for the default
  github api url.
- The `GITHUB_PAT` and `GITHUB_TOKEN` environment variables are used, if
  set, in this order, as default token. Consider using the git
  credential store instead, see `?gh::gh_token`.
- The `GH_VALIDATE_TOKENS` environment variable controls what happens
  when gh retrieves a PAT in an unrecognized format. Set it to `"off"`
  to skip validation, `"warn"` (the default) to issue a warning and use
  the PAT anyway, or `"error"` to abort. The `gh_validate_tokens` R
  option takes precedence over the environment variable.

## Code of Conduct

Please note that the gh project is released with a [Contributor Code of
Conduct](https://gh.r-lib.org/CODE_OF_CONDUCT.html). By contributing to
this project, you agree to abide by its terms.

## License

MIT © Gábor Csárdi, Jennifer Bryan, Hadley Wickham
