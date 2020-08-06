skip_if_no_token <- function() {
  if (is.na(Sys.getenv("GH_TESTING", NA_character_))) {
    skip("No GitHub token")
  }
}
