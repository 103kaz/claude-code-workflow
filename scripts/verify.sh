#!/usr/bin/env bash
# Install code-workflow from this checkout into an empty Claude Code config directory and check that
# code-guard and code-loops come with it, at the pinned commits, and that code-guard's own tests pass.
# Needs claude, jq, perl and git, and network access to github.com. Does not touch ~/.claude.
set -euo pipefail

cd "$(dirname "$0")/.."
root=$PWD
file=.claude-plugin/marketplace.json

if ! command -v claude >/dev/null 2>&1; then
  npm install -g @anthropic-ai/claude-code@2.1.311
fi

validation=$(claude plugin validate . 2>&1) || { echo "$validation" >&2; exit 1; }

# Every plugin that is not in this repository comes from an https url (so that no ssh key is needed
# to install it) and is pinned to a full commit sha.
bad=$(jq -r '.plugins[] | select((.source | type) == "object") | select(.source.source != "url" or ((.source.url // "") | startswith("https://") | not)) | .name' "$file")
if [ -n "$bad" ]; then
  echo "not an https url source: $bad" >&2
  exit 1
fi
bad=$(jq -r '.plugins[] | select((.source | type) == "object") | select((.source.sha // "") | test("^[0-9a-f]{40}$") | not) | .name' "$file")
if [ -n "$bad" ]; then
  echo "not pinned to a commit sha: $bad" >&2
  exit 1
fi

config=$(mktemp -d "${TMPDIR:-/tmp}/verify.XXXXXX")
[ -n "$config" ] && [ -d "$config" ] || { echo "cannot create a temporary directory" >&2; exit 1; }
trap 'rm -rf "$config"' EXIT
export CLAUDE_CONFIG_DIR=$config

marketplace=$(jq -r .name "$file")
claude plugin marketplace add "$root" >/dev/null
claude plugin install "code-workflow@$marketplace"

installed=$(claude plugin list --json)
enabled=$(jq -r '.[] | select(.enabled) | .id' <<<"$installed" | sort | tr '\n' ' ')
expected="code-guard@$marketplace code-loops@$marketplace code-workflow@$marketplace "
if [ "$enabled" != "$expected" ]; then
  echo "enabled plugins: $enabled" >&2
  echo "expected:        $expected" >&2
  exit 1
fi

# The installed copy of each plugin is the pinned commit.
for name in code-guard code-loops; do
  pinned=$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .source.sha' "$file")
  actual=$(jq -r --arg id "$name@$marketplace" '.plugins[$id][0].gitCommitSha // empty' "$config/plugins/installed_plugins.json")
  if [ "$actual" != "$pinned" ]; then
    echo "$name: installed '$actual', pinned '$pinned'" >&2
    exit 1
  fi
done

# code-guard's own tests, from the installed copy.
guard=$(jq -r --arg id "code-guard@$marketplace" '.[] | select(.id == $id) | .installPath' <<<"$installed")
for t in test-guard test-chain test-check-deps test-check-enabled test-verify test-defaults; do
  bash "$guard/tests/$t.sh"
done

echo "verify: ok"
