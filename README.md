# repo-template

Start a GitHub project that people and coding agents plan, build and release the same way. Every change goes from an issue to a branch to a pull request, and it merges once fast checks pass, without anyone having to approve it. So you can plan the work as issues and let agents build them in long runs, such as overnight.

The template works with any language. Agents get their instructions from one file, `AGENTS.md`, which Claude Code, Codex, Cursor, GitHub Copilot and most other coding agents read on their own. Gemini CLI and Aider read it only after you point their settings at it.

## What you get

- `AGENTS.md`: the rules for agents and people. They say how to make a change, plan the work, build it and publish a release.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments and error messages.
- `docs/code.md`: how to write code in any language, from design to tests and pinned versions.
- `docs/planning.md`: how an agent turns ideas into issues that are ready to build, with you deciding what gets built. The ideas can come from any text you share or point the agent to.
- `scripts/check`: one command that runs the same checks on your machine and in CI.
- `scripts/configure-github`: applies the settings that GitHub doesn't copy from a template. It allows only squash merges, makes every change to main go through a pull request that passes CI, lets a pull request merge on its own once its checks pass, and turns on security alerts.
- `.github/`: CI, issue forms, a pull request template, weekly Dependabot updates, and the contributing and security pages.
- `.claude/settings.json`: stops Claude Code from adding attribution lines and from reading `.env` files.

## Start a project

You need the GitHub CLI 2.98 or later, signed in with `gh auth login`. If you use Claude Code, update it to version 2.1.277 or later, because earlier versions don't read `AGENTS.md`.

1. Create a public repository from the template, and clone it. The settings script is written for public repositories. On a private repository, it stops at private vulnerability reporting, which GitHub offers only for public repositories. The settings after it, such as the rules that protect main, don't get applied.

   ```bash
   gh repo create photo-sorter --public --template jtmpl/repo-template --clone
   ```

2. Apply the GitHub settings from inside the clone:

   ```bash
   cd photo-sorter
   scripts/configure-github
   ```

3. Set up the project in its first pull request. You can ask your agent, for example: "Set up this repository for photo-sorter, a command-line tool in Python that finds duplicate photos. Follow the setup list in README.md." If you already have text about the project, add it to your request or point the agent to it. The agent asks you about anything on the list that your request doesn't settle, such as which languages, frameworks or database to use. The list:

   - In `AGENTS.md`, rewrite "What this project is" for the project: what it's for, and the direction that should guide its changes. Then update the "Where things are" and "Commands" sections with the project's files and its install, run and test commands.
   - Pin the version of each main technology, such as the language in its version file, like `.python-version`, and commit the lockfile for the project's packages. Add steps to `.github/workflows/ci.yml` that install them.
   - Add the formatter, linter and fast tests to `scripts/check`. If the project has slow tests, such as end-to-end tests, list their command under "Commands" in `AGENTS.md`.
   - Add the project's package manager, such as pip or npm, to `.github/dependabot.yml`, so that Dependabot updates its packages too.
   - Set the year and the copyright holder in `LICENSE`.
   - Last, replace this README with one for the project, as `docs/writing.md` describes.

## Example: from idea to first release

These are the requests you give your agent. `AGENTS.md` tells it what each one involves.

1. "Plan the first version of photo-sorter: it finds duplicate photos in a folder and moves the extra copies to the trash." If you have text about the project, add it to this request or point the agent to it. The agent splits the work into issues, each small enough for one pull request. When an issue needs another issue's change first, the agent marks it as blocked by that issue. Read the issues and correct them. Once you approve them, the agent adds the `ready` label, which lets agents build them.
2. "Build the ready issues." The agent works through them, lowest number first. For each issue, it opens a pull request that merges on its own once the checks pass, and it starts the next issue without waiting. To build faster, give the same request to several agents, each in its own clone or worktree, and they share the issues. You can read every merged pull request afterwards, because each one records what changed and why. If an agent can't build an issue, it comments on the issue and adds the `needs-decision` label. It skips the issues that depend on that one and builds the rest. Once you've answered, remove the label or ask the agent to, and ask it to build the ready issues again.
3. "Publish a release." The agent checks that CI passed on main and chooses the version from the merged pull requests, such as v0.1.0 for the first release. Then it publishes a GitHub release with notes built from them.

## License

MIT. See [LICENSE](LICENSE).
