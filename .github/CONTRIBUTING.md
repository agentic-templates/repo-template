# Contributing

- Every pull request starts from an issue. Search the issues first, and open a new one only if none fits. Once you've found or opened the issue, you can open the pull request, with `Closes #<issue>` in its description.
- Follow the rules in [AGENTS.md](../AGENTS.md). They apply to people as well as coding agents. They say how to write commits, pull requests and code. If you don't have write access, create your branch in a fork, and skip the steps that add labels, because a maintainer adds them.
- Before you push, run `scripts/check` from the repository's root folder. The script runs several checks, and each one needs its own tool. If a tool isn't installed, the script skips that tool's check and prints a link to install the tool. CI runs every check, so a check that your machine skipped can still fail your pull request. The script needs bash, which macOS and Linux include. On Windows, use Git Bash or WSL.
- Report a security problem privately, as [SECURITY.md](SECURITY.md) describes. Don't open a public issue or pull request for it.
