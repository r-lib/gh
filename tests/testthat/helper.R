
if (file.exists("github-token.txt")) {
  Sys.setenv(GITHUB_TOKEN = readLines("github-token.txt", n = 1))
}

httrmock::start_replaying()
