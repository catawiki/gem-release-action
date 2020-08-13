# Increment Version and Publish Gem to GitHub Packages

This action bumps the version number of a gem and publishes the new version to GitHub Packages.
Does all this by using the amazing [`gem-release`](https://github.com/svenfuchs/gem-release) gem.

Make sure that you have the recognised labels on the PR before you merge it.
The recognised labels are:
* `version:major`
* `version:minor`
* `version:patch`

## Inputs

### `github_packages_owner`

**Required** The name of the GitHub Packages organisation. The gem will be published
under the organisation.

### `github_packages_token`

Personal access token (PAT) used to push the gem to the repository.
We recommend using a service account with the least permissions necessary.  Also when generating a new PAT, select the least scopes necessary.

Default: `${{ secrets.github_token }}`

### `pr_labels`

A list of labels, separated by "|" that triggers a specific version bump.
The recognised labels are "version:patch", "version:minor" and "version:major".

Default: `${{ join(github.event.pull_request.labels.*.name, '|') }}`

## Example usage

```yaml
on:
  pull_request:
    types:
      - closed
    branches:
      - master
jobs:
  release:
    runs-on: ubuntu-latest
    # Run if merged and has a version specifying label
    if: >-
      github.event.pull_request.merged &&
      (
        contains(github.event.pull_request.labels.*.name, 'version:major') ||
        contains(github.event.pull_request.labels.*.name, 'version:minor') ||
        contains(github.event.pull_request.labels.*.name, 'version:patch')
      )
    steps:
      # actions/checkout@v2 stores the git credentials and with that it allows
      # git push in subsequent steps
      - uses: actions/checkout@v2
      - uses: catawiki/gem-release-action@v1
        with:
          owner: 'catawiki'
```
