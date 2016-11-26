library(jsonlite)
library(listviewer)
library(tidyverse)
library(forcats)
library(stringr)

routes <- fromJSON("routes.json")
#jsonedit(routes)
#names(routes)

## 'defines' is different that all other components
## it provides info for the API as a whole, not actual endpoints
defines <- routes[["defines"]]
routes$defines <- NULL

#jsonedit(routes)

## remove one level of hierarchy to yield
## one row per endpoint
rdf <- tibble(
  section = rep(names(routes), lengths(routes)),
  endpoints = flatten(routes)
)
#jsonedit(rdf$endpoints)

## is there a typical structure for an endpoint?
fct_count(as.character(lengths(rdf$endpoints)))
# # A tibble: 4 × 2
#       f     n
#   <fctr> <int>
# 1      4   395
# 2      5     1
# 3      6     1
# 4      7     1

## are the names consistent across the endpoints?
map_chr(rdf$endpoints, ~ paste(names(.x), collapse = ",")) %>%
  fct_count()
# # A tibble: 4 × 2
#                                                         f     n
#                                                    <fctr> <int>
# 1  url,method,host,hasFileBody,timeout,params,description     1
# 2                           url,method,params,description   395
# 3 url,method,params,vcs_username,vcs_password,description     1
# 4             url,method,requestFormat,params,description     1

## overwhelming majority of endpoints have:
## * url
## * method
## * params
## * description
## 3 out of 398 have more information

## start simplifying into a data frame
res <- tibble(
  url = map_chr(rdf$endpoints, "url"),
  method = map_chr(rdf$endpoints, "method"),
  description = map_chr(rdf$endpoints, "description"),
  params = map(rdf$endpoints, ~ names(.x$params))
)

pdf <- bind_cols(rdf, res) %>%
  select(section, method, url, description, params)
#pdf
#View(pdf)

## isolate params in the url
pdf <- pdf %>%
  mutate(url_params = url %>%
           str_split("/") %>%
           map(tail, n = -1) %>%
           map(str_subset, "^:") %>%
           map(str_replace, "^:", ""))
#View(pdf)

## prepare to isolate 'other' params, i.e. thos destined for query (GET)
## or body (all other verbs)
pdf <- pdf %>%
  mutate(other_params = params %>%
           map(str_replace, "^\\$", ""))
pdf <- pdf %>%
  mutate(other_params = map2(other_params, url_params, setdiff))
#View(pdf)

saveRDS(pdf, "endpoints.rds")
