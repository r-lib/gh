test_that("gh_gql posts to /graphql and returns parsed response", {
  local_fake_github()
  res <- gh_gql("query { viewer { login } }")
  expect_equal(res$data$viewer$login, "fakeuser")
  expect_equal(res$data$echo, "query { viewer { login } }")
})

test_that("gh_gql rejects .limit", {
  expect_snapshot(
    error = TRUE,
    gh_gql("query { viewer { login } }", .limit = 5)
  )
})
