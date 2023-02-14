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
      ! GitHub API error (401): Requires authentication
      i Read more at <https://docs.github.com/rest/reference/users#get-the-authenticated-user>
    Code
      gh_whoami(.token = "blah")
    Condition
      Error in `gh()`:
      ! GitHub API error (401): Bad credentials
      i Read more at <https://docs.github.com/rest>

