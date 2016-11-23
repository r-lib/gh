


# gh

> GitHub API

[![Linux Build Status](https://travis-ci.org/r-pkgs/gh.svg?branch=master)](https://travis-ci.org/r-pkgs/gh)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/r-pkgs/gh?svg=true)](https://ci.appveyor.com/project/gaborcsardi/gh)
[![](http://www.r-pkg.org/badges/version/gh)](http://www.r-pkg.org/pkg/gh)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/gh)](http://www.r-pkg.org/pkg/gh)


Minimalistic client to access
[GitHub's API v3](https://developer.github.com/v3/).

## Installation


```r
devtools::install_github("r-pkgs/gh")
```

## Usage


```r
library(gh)
```

Use the `gh()` function to access all API endpoints. The endpoints are
listed in the [documentation](https://developer.github.com/v3/).

The first argument of `gh()` is the endpoint. Note that the leading slash
must be included as well. Parameters can be passed as extra arguments. E.g.


```r
my_repos <- gh("/user/repos", type = "public")
vapply(my_repos, "[[", "", "name")
```

```
#>  [1] "after"               "argufy"              "ask"                
#>  [4] "baseimports"         "citest"              "clisymbols"         
#>  [7] "cmaker"              "cmark"               "conditions"         
#> [10] "crayon"              "debugme"             "diffobj"            
#> [13] "disposables"         "dotenv"              "elasticsearch-jetty"
#> [16] "falsy"               "fswatch"             "gitty"              
#> [19] "httrmock"            "ISA"                 "keypress"           
#> [22] "lintr"               "macBriain"           "maxygen"            
#> [25] "MISO"                "parr"                "parsedate"          
#> [28] "pingr"               "pkgconfig"           "playground"
```

The JSON result sent by the API is converted to an R object.

If the end point itself has parameters, these can also be passed
as extra arguments:


```r
j_repos <- gh("/users/:username/repos", username = "jeroenooms")
vapply(j_repos, "[[", "", "name")
```

```
#>  [1] "apps"               "asantest"           "awk"               
#>  [4] "base64"             "bcrypt"             "blog"              
#>  [7] "brotli"             "cheerio"            "cmark"             
#> [10] "commonmark"         "covr"               "cranlogs"          
#> [13] "curl"               "cyphr"              "daff"              
#> [16] "data"               "data.table.extras"  "devtools"          
#> [19] "DiagrammeR"         "docdbi"             "docplyr"           
#> [22] "docs-travis-ci-com" "dplyr"              "encode"            
#> [25] "evaluate"           "feather"            "fib"               
#> [28] "figures"            "gdtools"            "geojson"
```

### POST, PATCH, PUT and DELETE requests

POST, PATCH, PUT, and DELETE requests can be sent by including the
HTTP verb before the endpoint, in the first argument. E.g. to
create a repository:


```r
new_repo <- gh("POST /user/repos", name = "my-new-repo-for-gh-testing")
```

and then delete it:


```r
gh("DELETE /repos/:owner/:repo", owner = "gaborcsardi",
   repo = "my-new-repo-for-gh-testing")
```

### Tokens

By default the `GITHUB_PAT` environment variable is used. Alternatively, 
one can set the `.token` argument of `gh()`.

### Pagination

Supply the `page` parameter to get subsequent pages:


```r
my_repos2 <- gh("GET /users/:username/repos", username = "gaborcsardi",
  type = "public", page = 2)
vapply(my_repos2, "[[", "", "name")
```

```
#>  [1] "praise"                      "prettyunits"                
#>  [3] "progress"                    "prompt"                     
#>  [5] "r-font"                      "R6"                         
#>  [7] "rcloud.rcap.style.att"       "rcloud.rcap.style.att.ecomp"
#>  [9] "rcorpora"                    "readline"                   
#> [11] "remoji"                      "resume"                     
#> [13] "rhub-presentations"          "rintrojs"                   
#> [15] "roxygen"                     "scidb"                      
#> [17] "spark"                       "sparklyr"                   
#> [19] "splicing"                    "tamper"                     
#> [21] "testthat"                    "user2016-tutorial-shiny"    
#> [23] "webdriver"                   "whoami"
```

## License

MIT © [Gábor Csárdi](https://github.com/gaborcsardi).
