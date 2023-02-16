# generates a useful message

    Code
      gh("/missing")
    Condition
      Error in `gh()`:
      ! GitHub API error (404): Not Found
      x URL not found: <https://api.github.com/missing>
      i Read more at <https://docs.github.com/rest>

# can use per_page or .per_page but not both

    Code
      gh("/orgs/tidyverse/repos", per_page = 1, .per_page = 2)
    Condition
      Error in `gh()`:
      ! Exactly one of `per_page` or `.per_page` must be supplied.

