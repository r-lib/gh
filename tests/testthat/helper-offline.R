skip_if_no_token <- function() {
  if (Sys.getenv("GH_TESTING") == "") {
    skip("No GitHub token")
  }
}
