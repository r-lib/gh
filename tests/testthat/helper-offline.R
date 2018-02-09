
skip_if_offline <- (function() {
  offline <- NA
  function() {
    if (is.na(offline)) {
      offline <<- tryCatch(
        is.na(pingr::ping_port("github.com", count = 1, timeout = 1)),
        error = function(e) TRUE
      )
    }
    if (offline) skip("Offline")
  }
})()

skip_if_no_token <- function() {
  if (is.na(Sys.getenv("GH_TESTING", NA_character_))) {
    skip("No GitHub token")
  }
}
