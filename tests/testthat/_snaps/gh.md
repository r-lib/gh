# generates a useful message

    Code
      gh("/missing")
    Condition
      Error in `gh()`:
      ! GitHub API error (404): Not Found
      x URL not found: <https://api.github.com/missing>
      i Read more at <https://docs.github.com/rest>

# handles 422 responses with `errors` as a plain string

    Code
      gh("POST /repos/{owner}/{repo}/statuses/{sha}", owner = "r-lib", repo = "gh",
        sha = "deadbeef", state = "success")
    Condition
      Error in `gh()`:
      ! GitHub API error (422): Validation Failed
      i Read more at <https://docs.github.com/rest/commits/statuses#create-a-commit-status>
      message
      Validation failed: This SHA and context has reached the maximum number of statuses.

# can use per_page or .per_page but not both

    Code
      gh("/orgs/tidyverse/repos", per_page = 1, .per_page = 2)
    Condition
      Error in `gh()`:
      ! Exactly one of `per_page` or `.per_page` must be supplied.

# paginated request surfaces a 4xx error

    Code
      gh("/orgs/{org}/repos", org = "gh-org-testing-404", .limit = 100)
    Condition
      Error in `gh()`:
      ! GitHub API error (404): Not Found
      x URL not found: <https://api.github.com/orgs/gh-org-testing-404/repos?per_page=100>
      i Read more at <https://docs.github.com/rest>

