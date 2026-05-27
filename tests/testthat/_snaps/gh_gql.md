# gh_gql rejects .limit

    Code
      gh_gql("query { viewer { login } }", .limit = 5)
    Condition
      Error in `gh_gql()`:
      ! `.limit` does not work with the GraphQL API

