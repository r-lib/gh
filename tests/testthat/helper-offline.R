
skip_if_offline <- function() {
  ping_res <- tryCatch(pingr::ping_port("github.com", count = 1, timeout = 0.2),
                       error = function(e) NA)
  if (is.na(ping_res)) {
    skip("Offline")
  }
}

skip_if_no_token <- function() {
  if (is.na(Sys.getenv("GH_TESING", NA_character_))) {
    skip("No GitHub token")
  }
}
