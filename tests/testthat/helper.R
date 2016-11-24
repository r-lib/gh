
## If there is a GITHUB TOKEN file, then
## * we are replaying previously recorded responses
## * we are performing and recording unknown requests
##
## If there is no GITHUB TOKEN file, then
## * we are replaying previously recorded responses
## * we are performing unseen requests, but this should not happen.

if (file.exists("github-token.txt")) {
  Sys.setenv(GITHUB_TOKEN = readLines("github-token.txt", n = 1))
  Sys.setenv(DEBUGME = "httrmock")
  httrmock::start_recording()
  httrmock::start_replaying()

} else {
  httrmock::stop_recording()
  httrmock::start_replaying()
}
