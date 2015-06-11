


# gh

> GitHub API

[![Linux Build Status](https://travis-ci.org/gaborcsardi/gh.svg?branch=master)](https://travis-ci.org/gaborcsardi/gh)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/gaborcsardi/gh?svg=true)](https://ci.appveyor.com/project/gaborcsardi/gh)
[![](http://www.r-pkg.org/badges/version/gh)](http://www.r-pkg.org/pkg/gh)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/gh)](http://www.r-pkg.org/pkg/gh)


Minimal wrapper to access
[GitHub's API v3](https://developer.github.com/v3/).

## Installation


```r
devtools::install_github("gaborcsardi/gh")
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
#>  [1] "ask"                   "background"           
#>  [3] "baseimports"           "bundler"              
#>  [5] "clisymbols"            "closure"              
#>  [7] "cranky"                "crayon"               
#>  [9] "datastore"             "decima"               
#> [11] "disposables"           "docstrings"           
#> [13] "dot-emacs"             "dotenv"               
#> [15] "elasticsearch-jetty"   "ensurethat"           
#> [17] "falsy"                 "feast"                
#> [19] "flock"                 "gaborcsardi.github.io"
#> [21] "gh"                    "ISA"                  
#> [23] "json2r6"               "keypress"             
#> [25] "locker"                "macBriain"            
#> [27] "mason"                 "mason.rpkg"           
#> [29] "massig"                "MISO"
```

The JSON result sent by the API is converted to an R object.

If the end point itself has parameters, these can also be passed
as extra arguments:


```r
j_repos <- gh("/users/:username/repos", username = "jeroenooms")
vapply(j_repos, "[[", "", "name")
```

```
#>  [1] "apps"                  "blog"                 
#>  [3] "cheerio"               "cmark"                
#>  [5] "commonmark"            "curl"                 
#>  [7] "daff"                  "data"                 
#>  [9] "devtools"              "DiagrammeR"           
#> [11] "docdbi"                "docplyr"              
#> [13] "dplyr"                 "encode"               
#> [15] "evaluate"              "fib"                  
#> [17] "git"                   "httr"                 
#> [19] "icu"                   "interactivity"        
#> [21] "ipyr"                  "IRkernel"             
#> [23] "jeroenooms.github.com" "JJcorr"               
#> [25] "js"                    "JSlibs"               
#> [27] "jsonlite"              "lausd-data"           
#> [29] "lawn"                  "leaflet-pip"
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

By default the `GITHUB_TOKEN` environment variable is used. Alternatively, 
one can set the `.token` argument of `gh()`.

### Pagination

Supply the `page` parameter to get subsequent pages:


```r
my_repos2 <- gh("GET /users/:username/repos", username = "gaborcsardi",
  type = "public", page = 2)
vapply(my_repos2, "[[", "", "name")
```

```
#>  [1] "my-old-MISO"            "parsedate"             
#>  [3] "pingr"                  "pkgconfig"             
#>  [5] "playground"             "pretty"                
#>  [7] "prettyunits"            "printr"                
#>  [9] "procrustes"             "progress"              
#> [11] "r-font"                 "r-wiki-engine"         
#> [13] "ratlab"                 "rcorpora"              
#> [15] "Rcpp"                   "redsvd"                
#> [17] "regexp"                 "resume"                
#> [19] "rfunctions"             "roxygen"               
#> [21] "rsmith"                 "rsync-mirror"          
#> [23] "scidb"                  "Semantic-plotting-in-R"
#> [25] "snap"                   "spark"                 
#> [27] "splicing"               "staticdocs"            
#> [29] "tab"                    "testthat"
```

## License

MIT © [Gabor Csardi](https://github.com/gaborcsardi).
