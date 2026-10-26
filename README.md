# code-workflow

Installs two Claude Code plugins together:

- [code-guard](https://github.com/103kaz/claude-code-guard): hooks that stop dangerous operations, and a verify loop that runs an approved `.claude/verify.sh` when Claude ends a response that changed files.
- [code-loops](https://github.com/103kaz/claude-code-loops): a review loop and a docs check before a pull request, and a hook that asks for the review before the first push of each commit.

This plugin has no code of its own. It declares the two plugins as dependencies, so installing it installs both, and each stays usable on its own.

## Install

```bash
claude plugin marketplace add 103kaz/claude-code-guard
claude plugin marketplace add 103kaz/claude-code-loops
claude plugin marketplace add 103kaz/claude-code-workflow
claude plugin install code-workflow@claude-code-workflow
```

## License

MIT
