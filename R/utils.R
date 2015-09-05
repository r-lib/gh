
trim_ws <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}
