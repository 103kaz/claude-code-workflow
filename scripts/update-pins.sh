#!/usr/bin/env bash
# Pin each github-sourced plugin in marketplace.json to the current HEAD commit
# of its repository. Needs jq and an authenticated gh.
set -euo pipefail

cd "$(dirname "$0")/.."
file=.claude-plugin/marketplace.json

names=$(jq -r '.plugins[] | select((.source | type) == "object" and .source.source == "github") | .name' "$file")

for name in $names; do
  repo=$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .source.repo' "$file")
  sha=$(gh api "repos/$repo/commits/HEAD" --jq .sha)
  if [[ ! $sha =~ ^[0-9a-f]{40}$ ]]; then
    echo "unexpected sha for $repo: $sha" >&2
    exit 1
  fi
  jq --arg n "$name" --arg s "$sha" '(.plugins[] | select(.name == $n) | .source.sha) = $s' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
  echo "$name: $repo@$sha"
done
