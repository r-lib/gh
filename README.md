


# gh

> GitHub API

[![Linux Build Status](https://travis-ci.org/r-lib/gh.svg?branch=master)](https://travis-ci.org/r-lib/gh)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/r-lib/gh?svg=true)](https://ci.appveyor.com/project/gaborcsardi/gh)
[![](http://www.r-pkg.org/badges/version/gh)](http://www.r-pkg.org/pkg/gh)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/gh)](http://www.r-pkg.org/pkg/gh)
[![Coverage Status](https://img.shields.io/codecov/c/github/r-lib/gh/master.svg)](https://codecov.io/github/r-lib/gh?branch=master)

Minimalistic client to access
[GitHub's API v3](https://developer.github.com/v3/).

## Installation

Install the package from CRAN as usual:


```r
install.packages("gh")
```

## Usage


```r
library(gh)
```

Use the `gh()` function to access all API endpoints. The endpoints are
listed in the [documentation](https://developer.github.com/v3/).

The first argument of `gh()` is the endpoint. You can just copy and paste the 
API endpoints from the documentation. Note that the leading slash
must be included as well. 

From [https://developer.github.com/v3/repos/#list-user-repositories](https://developer.github.com/v3/repos/#list-user-repositories) you can copy and paste `GET /users/:username/repos` into your `gh()` call. E.g.


```r
my_repos <- gh("GET /users/gaborcsardi/repos")
vapply(my_repos, "[[", "", "name")
```

```
#>  [1] "after"               "alexr"               "altlist"            
#>  [4] "argufy"              "ask"                 "base"               
#>  [7] "baseimports"         "citest"              "cmaker"             
#> [10] "covr"                "cranky"              "cranlike-server"    
#> [13] "curl"                "dbplyr"              "devtools"           
#> [16] "disposables"         "dot-emacs"           "dotenv"             
#> [19] "dynex"               "elasticsearch-jetty" "ethel"              
#> [22] "falsy"               "flowery"             "form-data"          
#> [25] "franc"               "fswatch"             "gitty"              
#> [28] "hierformR"           "httpq"               "httr"
```


Parameters can be passed as extra arguments. E.g.


```r
my_repos <- gh("/user/repos", type = "public")
vapply(my_repos, "[[", "", "name")
```

```
#>  [1] "after"               "argufy"              "ask"                
#>  [4] "baseimports"         "citest"              "clisymbols"         
#>  [7] "cmaker"              "cmark"               "conditions"         
#> [10] "crayon"              "debugme"             "devtools"           
#> [13] "diffobj"             "disposables"         "dotenv"             
#> [16] "elasticsearch-jetty" "falsy"               "fswatch"            
#> [19] "gitty"               "httr"                "httrmock"           
#> [22] "ISA"                 "keypress"            "lintr"              
#> [25] "macBriain"           "maxygen"             "MISO"               
#> [28] "parr"                "parsedate"           "pingr"
```

The JSON result sent by the API is converted to an R object.

If the end point itself has parameters, these can also be passed
as extra arguments:


```r
j_repos <- gh("/users/:username/repos", username = "jeroen")
vapply(j_repos, "[[", "", "name")
```

```
#>  [1] "2018.erum.io"    "acme"            "agent"           "algebre1"       
#>  [5] "animation"       "antiword"        "apcf"            "arrow-r-dev"    
#>  [9] "asantest"        "askpass"         "async"           "attobot"        
#> [13] "autobrew"        "autobrew-old"    "awk"             "base64"         
#> [17] "bcrypt"          "betty"           "bigartm"         "bigstatsr"      
#> [21] "BiocBBSpack"     "blastula"        "blma"            "bookdown_travis"
#> [25] "bottles"         "brew"            "brotli"          "cheerio"        
#> [29] "cld3"            "collage"
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
#>  [1] "installlite"    "ISA"            "isc"            "keynote"        "keypress"      
#>  [6] "load-asciicast" "lpSolve"        "macBriain"      "magick"         "maxygen"       
#> [11] "MISO"           "msgtools"       "multidplyr"     "node-jenkins"   "node-papi"     
#> [16] "notifier"       "nsfw"           "oldie"          "pak-talk"       "parr"          
#> [21] "parsedate"      "pkgbuild"       "playground"     "progress0"      "promises"      
#> [26] "prompt"         "R-debugging"    "R-dev-web"      "r-font"         "r-source"
```

## License

MIT © Gábor Csárdi, Jennifer Bryan, Hadley Wickham
