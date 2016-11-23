
if (file.exists("github-token.txt")) {
  Sys.setenv(GITHUB_TOKEN = readLines("github-token.txt", n = 1))
}

## Sys.setenv(DEBUGME = "httrmock")
## httrmock::start_recording()
httrmock::start_replaying()
