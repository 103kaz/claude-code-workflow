# Changelog

## 0.1.3 (2026-10-28)

- Pins code-guard 0.5.4 and code-loops 0.3.5.
  - code-guard 0.5.4 guards the config directory set by `CLAUDE_CONFIG_DIR` as it guards `~/.claude`, and reads the sandbox settings from there.
  - code-loops 0.3.5 lets the commits of the review loop's fixes through once on the same push after a block, instead of stopping the push again. Without `CLAUDE_PLUGIN_DATA`, its record goes under `CLAUDE_CONFIG_DIR`.
- The README's "After installing" step 5 and "A push meets both plugins" say what happens when the review loop's fixes are committed.

## 0.1.2 (2026-10-27)

- Pins code-guard 0.5.3 and code-loops 0.3.4.
- The README opens with what the plugins stop or check, and has an "After installing" section with the first-run steps. The pin and CI details moved to "Pinned versions".
- code-guard and code-loops are fetched over their https URLs instead of the `github` source, which cloned over SSH when a key was configured.
- `scripts/verify.sh` installs code-workflow into an empty Claude Code config directory, checks that both plugins are enabled at the pinned commits, and runs code-guard's tests. The `Update pins` workflow runs it before opening a pull request, and the `Verify` workflow runs it on pull requests that change the manifests, the scripts or the workflows.

## 0.1.1 (2026-10-27)

- Pins code-guard 0.5.2 and code-loops 0.3.3.
- The README says what changes when code-guard and code-loops run together.

## 0.1.0 (2026-10-27)

- First version. Installing `code-workflow` installs code-guard and code-loops, which this marketplace lists too.
- code-guard and code-loops are pinned to a commit (code-guard 0.5.1, code-loops 0.3.1). The `Update pins` workflow runs daily and opens a pull request, or updates the open one, when either repository has moved; `scripts/update-pins.sh` moves the pins locally.
