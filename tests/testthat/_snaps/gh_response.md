# warns if output is HTML

    Code
      res <- gh("POST /markdown", text = "foo")
    Condition
      Warning:
      Response came back as html :(

