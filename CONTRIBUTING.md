# Contributing

## Testing

gh uses [httrmock](https://github.com/gaborcsardi/httrmock#readme) to record and replay HTTP requests for testing purposes.

Anyone who forks or clones gh should be able to run the existing tests, against the stored recordings. New tests that don't call the GitHub API can be added and run in the usual way.

What about tests that call the GitHub API? Put them in a file named like `test-mock-foo.R`. All such tests should explicity set the token. If no token is needed, explicitly set it to `""`, so that no token is sent:

``` r
test_that("some new thing that does not need PAT works", {
  res <- gh(..., .token = "")        
  expect_that(...)
  ...
})
```
If a token is needed, use the `tt()` helper function to use the testing token:
``` r
test_that("some other new thing that requires a PAT works", {
  res <- gh(..., .token = tt())        
  expect_that(...)
  ...
})
``` 

The testing token should be stored in the `GH_TESTING` environment variable. New functionality and associated tests can be tested locally by temporarily setting `GH_TESTING` to a personal PAT. When a pull request gets merged, the maintainer can run and record the tests using the private gh testing token and commit them to the repo.
