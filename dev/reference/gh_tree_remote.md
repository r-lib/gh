# Find the GitHub remote associated with a path

This is handy helper if you want to make gh requests related to the
current project.

## Usage

``` r
gh_tree_remote(path = ".")
```

## Arguments

- path:

  Path that is contained within a git repo.

## Value

If the repo has a github remote, a list containing `username` and
`repo`. Otherwise, an error.

## Examples

``` r
if (FALSE) { # interactive()
gh_tree_remote()
}
```
