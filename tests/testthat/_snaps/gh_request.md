# gh_set_endpoint() refuses to substitute an NA

    Code
      gh_set_endpoint(input)
    Condition
      Error in `gh_set_endpoint()`:
      ! Named NA parameters are not allowed: org

# gh_make_request() errors if unknown verb

    Unknown HTTP verb: "GEEET"

# gh_set_query errors when GET params are not all named

    Code
      gh_set_query(input)
    Condition
      Error in `gh_set_query()`:
      ! All elements of `params` must be named for `GET` requests.

