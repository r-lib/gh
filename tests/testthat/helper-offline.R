skip_if_no_token <- function() {
  if (gh_token() == "") {
    skip("No GitHub token")
  }
}
