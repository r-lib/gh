# whoami errors with bad PAT

    Code
      gh_whoami(.token = NA)
    Condition
      Error in `gh_process_response()`:
      ! GitHub API error (401): Requires authentication
      i Read more at <https://docs.github.com/rest/reference/users#get-the-authenticated-user>
    Code
      gh_whoami(.token = "blah")
    Condition
      Error in `gh_process_response()`:
      ! GitHub API error (401): Bad credentials
      i Read more at <https://docs.github.com/rest>

