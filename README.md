# code-workflow

When Claude Code changes your code, it can also push to `main`, read a `.env` file, run `rm -r`, end a response without running your tests, or push a branch nobody has reviewed. code-workflow adds checks for these to Claude Code, in one install:

- **Guards.** Claude's commands and file access are checked before they run. A push to `main` or `master`, reading secret files such as `.env` or `*.pem`, and piping `curl` to a shell are blocked; a force push, `rm -r` outside build directories and `git reset --hard` ask you first.
- **A verify loop.** When Claude ends a response that changed files, your project's checks (`.claude/verify.sh`, for example lint and tests) run. If they fail, the output goes back to Claude to fix.
- **A review loop.** `/code-loops:review-loop` reviews the branch diff, fixes what it finds, and repeats until a lap finds nothing. When the diff changes code that the documentation describes, it also checks that the documentation still matches.
- **A review before push.** The first time Claude pushes a commit, the push is stopped and Claude is asked to run the review loop first.

These come from two plugins, [code-guard](https://github.com/103kaz/claude-code-guard) (guards and the verify loop) and [code-loops](https://github.com/103kaz/claude-code-loops) (the review loop and the push reminder). This plugin has no code of its own: it declares both as dependencies, so installing it installs both.

The guards read command strings and file paths; they are not a sandbox. See "What it does not guarantee" in [code-guard's README](https://github.com/103kaz/claude-code-guard#what-it-does-not-guarantee).

## Install

Requires bash 3.2+, `jq` and `perl`, on macOS or Linux. Windows is not supported.

```bash
claude plugin marketplace add https://github.com/103kaz/claude-code-workflow.git
claude plugin install code-workflow@claude-code-workflow
```

Start a new session afterwards. `claude plugin list` shows `code-workflow`, `code-guard` and `code-loops`, all from `claude-code-workflow`.

If you already installed code-guard or code-loops from their own marketplaces (`code-guard@claude-code-guard`, `code-loops@claude-code-loops`), uninstall those first, so that only one copy of each plugin is enabled. Two copies run their hooks twice.

## After installing

The guards work as soon as a new session starts. The verify loop needs a script, and your approval of it, in each project.

1. **Create the checks.** In a session in your project, run `/code-guard:setup-verify`. It looks at your build files, proposes a `.claude/verify.sh` that runs fast checks (lint, tests), and writes it only after you agree.
2. **Approve the script.** The verify loop runs `.claude/verify.sh` only after you approved its content, because a script from a cloned repository is someone else's code. `/code-guard:setup-verify` ends by showing the command to run; run it yourself in a terminal, read the script it shows, and type `yes`. Until then the script is skipped and you are told once per session. Each change to the script needs a new approval.
3. **Work as usual.** At the end of each response that changed files, `.claude/verify.sh` runs, and failures go back to Claude.
4. **Review before a pull request.** Run `/code-loops:review-loop` on your work branch. It reviews and fixes the diff against the base branch, then reports what is left and whether the checks passed. It does not commit, push or open a pull request.
5. **Push.** When Claude pushes a commit for the first time, the push is stopped and Claude is asked to run the review loop. After the review loop has run, the retried push goes through. A push you run yourself in a terminal is not affected.

Settings (protected branches, asking before every push, and others) are in `/plugin` → **Installed** → **code-guard** → **Configure options**. See "Settings" in code-guard's README.

## What changes when they run together

- **Verification is code-guard's.** With code-guard enabled, `/code-loops:review-loop` does not run `.claude/verify.sh`; code-guard runs it at the end of a turn in which files changed, and only after you approved the script. A review that changes nothing, an unapproved script, or a missing `.claude/verify.sh` means nothing was verified, and the review-loop report says so.
- **A push meets both plugins.** code-guard blocks a push to a protected branch and the other shapes it lists (`--no-verify`, `--delete` and the like), asks on a force push, and asks on every push when `confirm_push` is on. code-loops blocks the first push of each commit and lets the retry through once `/code-loops:review-loop` has run after the block (code-loops 0.3.2 and later; earlier versions let the retry through without checking). If either blocks, the push does not run. Both are aids for Claude; a push you run yourself in a terminal is not affected by either.
- **Settings are per plugin id.** code-guard's settings (`protected_branches`, `confirm_push`, the packs) are stored under the id of the installed plugin. Installed from this marketplace the id is `code-guard@claude-code-workflow`, so settings you made for `code-guard@claude-code-guard` do not carry over; set them again in the `/plugin` screen.
- **Requirements are code-guard's.** Without `jq` or `perl` the guards block what they cover. code-loops itself works without `jq`.
- **The sandbox.** If you use Claude Code's sandbox, code-guard's chained-command guard blocks a command listed in `sandbox.excludedCommands` (for example `git push`) when it is chained with another command, and asks for one command per call. This applies to `git push`, including the retry that code-loops asks for, if you list it there. See code-guard's README, "Using it with the sandbox".

## Using one of them

Each plugin works alone, with its own cautions: code-guard without code-loops has no review loop and no push reminder; code-loops without code-guard runs `.claude/verify.sh` with no approval step and does not stop a push to `main`. See "Using it alone" in [code-loops' README](https://github.com/103kaz/claude-code-loops#using-it-alone) and "Using it alone" in [code-guard's README](https://github.com/103kaz/claude-code-guard#using-it-alone). To use only one, install it from its own marketplace instead of this one.

## Pinned versions

This marketplace lists code-guard and code-loops too, pointing at their own repositories, so it is the only marketplace you need to add. Both are pinned to a commit sha in `.claude-plugin/marketplace.json` and fetched over https. The https URL in the install command keeps the install from using an SSH key (the `103kaz/claude-code-workflow` shorthand clones over SSH when a key is configured).

The `Update pins` workflow runs daily and, when either repository has moved, opens a pull request (or updates the one that is already open); `scripts/update-pins.sh` (needs `jq` and `gh`) moves the pins in the file locally. A pin moves only when that pull request is merged. Before opening it, the workflow runs `scripts/verify.sh`, which installs code-workflow into an empty Claude Code config directory, checks that both plugins are enabled at the pinned commits, and runs code-guard's own tests; if that fails, no pull request is opened. The same script runs on pull requests that change the manifests, the scripts or the workflows (needs `claude`, `jq`, `perl` and `git`).

## License

MIT
