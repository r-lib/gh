TMPL <- function(x) {
  gsub("[{]([^}]+)[}]", ":\\1", x)
}

source("test-mock-repos.R", local = TRUE)
