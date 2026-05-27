# gh_process_response errors on non-httr2_response input

    Code
      gh_process_response(list(), list())
    Condition
      Error in `gh_process_response()`:
      ! `resp` must be an <httr2_response> object, not an empty list.

# warns if output is HTML

    Code
      res <- gh("POST /markdown", text = "foo")
    Condition
      Warning:
      Response came back as html :(

