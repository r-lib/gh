# whoami errors with bad/absent PAT

    Code
      gh_whoami(.token = "")
    Message
      No personal access token (PAT) available.
      Obtain a PAT from here:
      https://github.com/settings/tokens
      For more on what to do with the PAT, see ?gh_whoami.
    Code
      gh_whoami(.token = NA)
    Condition
      Error in `gh()`:
      ! GitHub API error (403): API rate limit exceeded for 76.31.204.113. (But here's the good news: Authenticated requests get a higher rate limit. Check out the documentation for more details.)
      i Read more at <https://docs.github.com/rest/overview/resources-in-the-rest-api#rate-limiting>
    Code
      gh_whoami(.token = "blah")
    Condition
      Error in `gh()`:
      ! GitHub API error (401): Bad credentials
      i Read more at <https://docs.github.com/rest>

