# gh_tree_remote errors when no github remotes are configured

    Code
      gh_tree_remote(repo)
    Condition
      Error in `github_remote()`:
      ! No GitHub remotes found at '<tempdir>/<tempfile>'

# git_config errors when .git/config does not exist

    Code
      git_config(dir)
    Condition
      Error in `git_config()`:
      ! git config does not exist at '<tempdir>/<tempfile>'

# repo_root errors on a path that does not exist

    Code
      repo_root(file.path(tempdir(), "does-not-exist-xyz"))
    Condition
      Error in `repo_root()`:
      ! Can't find repo at '<tempdir>/does-not-exist-xyz'

# repo_root errors when no git root is found

    Code
      repo_root(dir)
    Condition
      Error in `repo_root()`:
      ! Could not find git root from '/'.

