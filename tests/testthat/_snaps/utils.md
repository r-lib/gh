# named NA is error

    Code
      check_named_nas(tc)
    Condition
      Error in `check_named_nas()`:
      ! Named NA parameters are not allowed: `a`

---

    Code
      check_named_nas(tc)
    Condition
      Error in `check_named_nas()`:
      ! Named NA parameters are not allowed: `a`

---

    Code
      check_named_nas(tc)
    Condition
      Error in `check_named_nas()`:
      ! Named NA parameters are not allowed: `c`

# discard errors on logical selector of wrong length

    Code
      discard(list("a", "b"), c(TRUE, FALSE, TRUE))
    Condition
      Error in `probe()`:
      ! `.p` must have the same length as `.x`.
      i This is an internal error that was detected in the gh package.
        Please report it at <https://github.com/r-lib/gh/issues> with a reprex (<https://tidyverse.org/help/>) and the full backtrace.

