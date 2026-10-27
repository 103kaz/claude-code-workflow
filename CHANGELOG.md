# Changelog

## Unreleased

- The README opens with what the plugins stop or check, and has an "After installing" section with the first-run steps. The pin and CI details moved to "Pinned versions".
- code-guard and code-loops are fetched over their https URLs instead of the `github` source, which cloned over SSH when a key was configured.
- `scripts/verify.sh` installs code-workflow into an empty Claude Code config directory, checks that both plugins are enabled at the pinned commits, and runs code-guard's tests. The `Update pins` workflow runs it before opening a pull request, and the `Verify` workflow runs it on pull requests that change the manifests, the scripts or the workflows.

## 0.1.1 (2026-10-27)

- Pins code-guard 0.5.2 and code-loops 0.3.3.
- The README says what changes when code-guard and code-loops run together.

## 0.1.0 (2026-10-27)

- First version. Installing `code-workflow` installs code-guard and code-loops, which this marketplace lists too.
- code-guard and code-loops are pinned to a commit (code-guard 0.5.1, code-loops 0.3.1). The `Update pins` workflow runs daily and opens a pull request, or updates the open one, when either repository has moved; `scripts/update-pins.sh` moves the pins locally.
