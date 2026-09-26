# Contributing

- Every pull request starts from an issue. Search the issues first, and open a new one only if none fits. For a small fix, you can open the pull request right away, with `Closes #<issue>` in its description. For a larger change, such as a new feature, wait until you and the maintainer agree on the issue.
- Follow the rules in [AGENTS.md](../AGENTS.md). They apply to people as well as coding agents. They say how to write commits, pull requests and code.
- Before you push, run `scripts/check` from the repository's root folder. If a tool it uses isn't installed, it skips that check and prints a link to install the tool. CI installs every tool and runs the whole script. The script needs bash, which macOS and Linux include. On Windows, use Git Bash or WSL.
- Report a security problem privately, as [SECURITY.md](SECURITY.md) describes. Don't open a public issue or pull request for it.
