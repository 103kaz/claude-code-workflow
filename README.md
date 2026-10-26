# code-workflow

Installs two Claude Code plugins together:

- [code-guard](https://github.com/103kaz/claude-code-guard): hooks that stop dangerous operations, and a verify loop that runs an approved `.claude/verify.sh` when Claude ends a response that changed files.
- [code-loops](https://github.com/103kaz/claude-code-loops): a review loop and a docs check before a pull request, and a hook that asks for the review before the first push of each commit.

This plugin has no code of its own. It declares the two plugins as dependencies, so installing it installs both, and each stays usable on its own. This marketplace lists code-guard and code-loops too, pointing at their own repositories, so it is the only marketplace you need to add.

## Install

```bash
claude plugin marketplace add 103kaz/claude-code-workflow
claude plugin install code-workflow@claude-code-workflow
```

Start a new session afterwards. `claude plugin list` shows `code-workflow`, `code-guard` and `code-loops`, all from `claude-code-workflow`.

If you already installed code-guard or code-loops from their own marketplaces (`code-guard@claude-code-guard`, `code-loops@claude-code-loops`), uninstall those first. With two enabled plugins of the same name, the hooks of only one of them run.

## License

MIT
