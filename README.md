# code-workflow

Installs two Claude Code plugins together:

- [code-guard](https://github.com/103kaz/claude-code-guard): hooks that stop dangerous operations, and a verify loop that runs an approved `.claude/verify.sh` when Claude ends a response that changed files.
- [code-loops](https://github.com/103kaz/claude-code-loops): a review loop and a docs check before a pull request, and a hook that asks for the review before the first push of each commit.

This plugin has no code of its own. It declares the two plugins as dependencies, so installing it installs both, and each stays usable on its own. This marketplace lists code-guard and code-loops too, pointing at their own repositories, so it is the only marketplace you need to add.

## Install

```bash
claude plugin marketplace add https://github.com/103kaz/claude-code-workflow.git
claude plugin install code-workflow@claude-code-workflow
```

The https URL keeps the install from using an SSH key (the `103kaz/claude-code-workflow` shorthand clones over SSH when a key is configured). code-guard and code-loops are pinned to a commit sha in `.claude-plugin/marketplace.json` and fetched over https too. The `Update pins` workflow runs daily and, when either repository has moved, opens a pull request (or updates the one that is already open); `scripts/update-pins.sh` (needs `jq` and `gh`) moves the pins in the file locally. A pin moves only when that pull request is merged. Before opening it, the workflow runs `scripts/verify.sh`, which installs code-workflow into an empty Claude Code config directory, checks that both plugins are enabled at the pinned commits, and runs code-guard's own tests; if that fails, no pull request is opened. The same script runs on pull requests that change the manifests, the scripts or the workflows (needs `claude`, `jq`, `perl` and `git`).

Start a new session afterwards. `claude plugin list` shows `code-workflow`, `code-guard` and `code-loops`, all from `claude-code-workflow`.

If you already installed code-guard or code-loops from their own marketplaces (`code-guard@claude-code-guard`, `code-loops@claude-code-loops`), uninstall those first, so that only one copy of each plugin is enabled. Two copies run their hooks twice.

## What changes when they run together

- **Verification is code-guard's.** With code-guard enabled, `/code-loops:review-loop` does not run `.claude/verify.sh`; code-guard runs it at the end of a turn in which files changed, and only after you approved the script. Approve it once in a terminal before the first review (see code-guard's README, "Verify loop"). A review that changes nothing, an unapproved script, or a missing `.claude/verify.sh` means nothing was verified, and the review-loop report says so.
- **A push meets both plugins.** code-guard blocks a push to a protected branch and the other shapes it lists (`--no-verify`, `--delete` and the like), asks on a force push, and asks on every push when `confirm_push` is on. code-loops blocks the first push of each commit and lets the retry through once `/code-loops:review-loop` has run after the block (code-loops 0.3.2 and later; earlier versions let the retry through without checking). If either blocks, the push does not run. Both are aids for Claude; a push you run yourself in a terminal is not affected by either.
- **Settings are per plugin id.** code-guard's settings (`protected_branches`, `confirm_push`, the packs) are stored under the id of the installed plugin. Installed from this marketplace the id is `code-guard@claude-code-workflow`, so settings you made for `code-guard@claude-code-guard` do not carry over; set them again in the `/plugin` screen.
- **Requirements are code-guard's.** bash 3.2+, `jq` and `perl`, on macOS or Linux; Windows is not supported. Without `jq` or `perl` the guards block what they cover. code-loops itself works without `jq`.
- **The sandbox.** If you use Claude Code's sandbox, code-guard's chained-command guard blocks a command listed in `sandbox.excludedCommands` (for example `git push`) when it is chained with another command, and asks for one command per call. This applies to `git push`, including the retry that code-loops asks for, if you list it there. See code-guard's README, "Using it with the sandbox".

## Using one of them

Each plugin works alone, with its own cautions: code-guard without code-loops has no review loop and no push reminder; code-loops without code-guard runs `.claude/verify.sh` with no approval step and does not stop a push to `main`. See "Using it alone" in [code-loops' README](https://github.com/103kaz/claude-code-loops#using-it-alone) and "Using it alone" in [code-guard's README](https://github.com/103kaz/claude-code-guard#using-it-alone). To use only one, install it from its own marketplace instead of this one.

## License

MIT
