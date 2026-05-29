# get_validate_tokens_mode() rejects a setting that isn't a single string

    Code
      gh_pat(bad)
    Condition
      Error in `get_validate_tokens_mode()`:
      ! Invalid token validation setting: must be a single string.
      i Got a character vector.

---

    Code
      gh_pat(bad)
    Condition
      Error in `get_validate_tokens_mode()`:
      ! Invalid token validation setting: must be a single string.
      i Got an integer.

---

    Code
      gh_pat(bad)
    Condition
      Error in `get_validate_tokens_mode()`:
      ! Invalid token validation setting: must be a single string.
      i Got a character `NA`.

# new_gh_pat rejects non-string input

    Code
      new_gh_pat(1L)
    Condition
      Error in `new_gh_pat()`:
      ! A GitHub PAT must be a string

---

    Code
      new_gh_pat(c("a", "b"))
    Condition
      Error in `new_gh_pat()`:
      ! A GitHub PAT must be a string

# validate_gh_pat rejects non-gh_pat input

    Code
      validate_gh_pat("not-a-pat-object")
    Condition
      Error in `validate_gh_pat()`:
      ! `x` must be a <gh_pat> object, not the string "not-a-pat-object".

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

