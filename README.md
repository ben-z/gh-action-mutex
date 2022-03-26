# gh-action-mutex

A simple locking/unlocking mechanism to provide mutual exclusion in Github Actions

## Developing Locally

1. Populate `.github-token` with a personal access token with the `repo` permision.
1. `act --rebuild -v -s GITHUB_TOKEN=$(cat .github-token)`
