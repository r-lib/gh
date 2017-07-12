
skip_if_offline <- function() {
  if (is.na(pingr::ping("github.com", count = 1, timeout = 0.2))) {
    skip("Offline")
  }
}
