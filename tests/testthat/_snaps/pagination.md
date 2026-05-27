# can extract relative pages

    Code
      gh_prev(page1)
    Condition
      Error in `gh_link_request()`:
      ! No prev page

# gh_link_request errors on non-gh_response input

    Code
      gh_link_request(list(), "next", .token = NULL, .send_headers = NULL)
    Condition
      Error in `gh_link_request()`:
      ! `gh_response` must be a <gh_response> object, not an empty list.

