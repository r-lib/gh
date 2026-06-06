# Get the next, previous, first or last page of results

Get the next, previous, first or last page of results

## Usage

``` r
gh_next(gh_response, .token = NULL, .send_headers = NULL)

gh_prev(gh_response, .token = NULL, .send_headers = NULL)

gh_first(gh_response, .token = NULL, .send_headers = NULL)

gh_last(gh_response, .token = NULL, .send_headers = NULL)
```

## Arguments

- gh_response:

  An object returned by a [`gh()`](https://gh.r-lib.org/reference/gh.md)
  call.

- .token:

  Authentication token. Defaults to
  [`gh_token()`](https://gh.r-lib.org/reference/gh_token.md).

- .send_headers:

  Named character vector of header field values (except `Authorization`,
  which is handled via `.token`). This can be used to override or
  augment the default `User-Agent` header:
  `"https://github.com/r-lib/gh"`.

## Value

Answer from the API.

## Details

Note that these are not always defined. E.g. if the first page was
queried (the default), then there are no first and previous pages
defined. If there is no next page, then there is no next page defined,
etc.

If the requested page does not exist, an error is thrown.

## See also

The `.limit` argument to [`gh()`](https://gh.r-lib.org/reference/gh.md)
supports fetching more than one page.

## Examples

``` r
x <- gh("/users")
vapply(x, "[[", character(1), "login")
#>  [1] "mojombo"      "defunkt"      "pjhyett"      "wycats"      
#>  [5] "ezmobius"     "ivey"         "evanphx"      "vanpelt"     
#>  [9] "wayneeseguin" "brynary"      "kevinclark"   "technoweenie"
#> [13] "macournoyer"  "takeo"        "caged"        "topfunky"    
#> [17] "anotherjesse" "roland"       "lukas"        "fanvsfan"    
#> [21] "tomtt"        "railsjitsu"   "nitay"        "kevwil"      
#> [25] "KirinDave"    "jamesgolick"  "atmos"        "errfree"     
#> [29] "sethfitz"     "bmizerany"   
x2 <- gh_next(x)
vapply(x2, "[[", character(1), "login")
#>  [1] "jnewland"    "joshknowles" "hornbeck"    "jwhitmire"  
#>  [5] "elbowdonkey" "reinh"       "knzai"       "bs"         
#>  [9] "rsanheim"    "schacon"     "uggedal"     "bruce"      
#> [13] "sam"         "mmower"      "abhay"       "rabble"     
#> [17] "benburkert"  "indirect"    "fearoffish"  "ry"         
#> [21] "engineyard"  "jsierles"    "tweibley"    "peimei"     
#> [25] "brixen"      "tmornini"    "outerim"     "daksis"     
#> [29] "sr"          "lifo"       
```
