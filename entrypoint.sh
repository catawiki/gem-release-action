#!/bin/sh -l

set -o nounset
set -o errexit
set -o pipefail

# Passed by the GitHub Action Runner
[ -z "$INPUT_GITHUB_PACKAGES_TOKEN" ] && { echo "Missing input.github-packages-token!"; exit 2; }
[ -z "$INPUT_GITHUB_PACKAGES_OWNER" ] && { echo "Missing input.github-packages-owner!"; exit 2; }
[ -z "$INPUT_PR_LABELS" ] && { echo "Missing input.pr-labels!"; exit 2; }

# Exit unless we have a specified version bump
version=$(echo "$INPUT_PR_LABELS" | sed -n -e 's/.*version:\([^|]*\).*/\1/p')
case "$version" in
  major|minor|patch)
    ;; # Continue to the next step
  *)
    echo "Skipping release; Next version cannot be deduced from labels."
    exit 0
esac

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------
group_start() { echo "##[group]$*"; }
group_end()   { echo "##[endgroup]"; }
run_command() { echo "[command]$*"; "$@"; }


# ------------------------------------------------------------------------------
# Setup and configuration
# ------------------------------------------------------------------------------
# Authorization for git push should be done using actions/checkout@v2
# See token and persist-credentials
group_start "Add git user information"
run_command git config user.email "github-action@users.noreply.github.com"
run_command git config user.name "GitHub Action"
group_end

group_start "Setting up access to GitHub Package Registry"
run_command mkdir -p ~/.gem
run_command touch ~/.gem/credentials
run_command chmod 600 ~/.gem/credentials
printf -- "---\n:github: Bearer %s\n" "$INPUT_GITHUB_PACKAGES_TOKEN" > "$HOME/.gem/credentials"
group_end


# ------------------------------------------------------------------------------
# Steps to release a new version
# ------------------------------------------------------------------------------
group_start 'Bump version, commit, push'
run_command gem bump --verbose --version "$version" --push
group_end

group_start "Create git tag and push"
run_command gem tag --verbose --push
group_end

group_start "Build gem and publish on GitHub Packages"
run_command gem release --key github --host "https://rubygems.pkg.github.com/${INPUT_GITHUB_PACKAGES_OWNER}"
group_end
