
## If there is no GH_TESTING env var, then
## * we are replaying previously recorded responses
## * we are performing unseen requests, but this should not happen.
##
## If there is a GH_TESTING env var, then we are in dev mode.
## * It's still being sorted out exactly what this means re:
##   replaying and recording. For now, same default as above.
##   https://github.com/gaborcsardi/httrmock/issues/5
## * Reveal debugging info from httrmock.

tt <- function() Sys.getenv("GH_TESTING", NA)
