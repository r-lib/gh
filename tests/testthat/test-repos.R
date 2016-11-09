
context("repos")

test_that("repos, some basics", {

  res <- gh("/user/repos")
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh("/users/:username/repos", username = "gaborcsardi")
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

  res <- gh("/orgs/:org/repos", org = "r-pkgs", type = "sources")
  expect_true("desc" %in% vapply(res, "[[", "name", FUN.VALUE = ""))

  res <- gh("/repositories")
  expect_true(all(c("id", "name", "full_name") %in% names(res[[1]])))

})
