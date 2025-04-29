# get_baseurl() insists on http(s)

    Code
      get_baseurl("github.com")
    Condition
      Error in `get_baseurl()`:
      ! Only works with HTTP(S) protocols
    Code
      get_baseurl("github.acme.com")
    Condition
      Error in `get_baseurl()`:
      ! Only works with HTTP(S) protocols

