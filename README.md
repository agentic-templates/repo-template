# repo-template

Start a GitHub project that people and coding agents plan, build and release the same way. Every change goes from an issue to a branch to a pull request, and it merges once fast checks pass. No approval is required, so you can plan a whole release as a milestone of issues and let an agent build and merge it in one long run.

The template works with any language. Agents get their instructions from one file, `AGENTS.md`, which Claude Code, Codex, Cursor, GitHub Copilot and most other coding agents read on their own. Gemini CLI and Aider read it only after you point their settings at it.

## What you get

- `AGENTS.md`: the rules for agents and people. They say how to make a change, and how to plan, build and publish a release.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments and error messages.
- `docs/code.md`: how to write code in any language, from design to tests and pinned versions.
- `scripts/check`: one command that runs the same checks on your machine and in CI.
- `scripts/configure-github`: applies the settings that GitHub doesn't copy from a template. It allows only squash merges, makes every change to main go through a pull request that passes CI, and turns on security alerts.
- `.github/`: CI, issue forms, a pull request template, weekly Dependabot updates, and the contributing and security pages.
- `.claude/settings.json`: stops Claude Code from adding attribution lines and from reading `.env` files.

## Start a project

You need the GitHub CLI 2.94 or later, signed in with `gh auth login`. If you use Claude Code, update it to version 2.1.277 or later, because earlier versions don't read `AGENTS.md`.

1. Create a public repository from the template, and clone it. The settings script is written for public repositories. On a private repository in a personal account, it can stop partway, because GitHub doesn't offer some of its settings there, such as secret scanning.

   ```bash
   gh repo create photo-sorter --public --template jtmpl/repo-template --clone
   ```

2. Apply the GitHub settings from inside the clone:

   ```bash
   cd photo-sorter
   scripts/configure-github
   ```

3. Set up the project in its first pull request. You can ask your agent, for example: "Set up this repository for photo-sorter, a command-line tool in Python that finds duplicate photos. Follow the setup list in README.md." The list:

   - In `AGENTS.md`, replace the first paragraph with one sentence about the project. Then update the "Where things are" and "Commands" sections with the project's files and its install, run and test commands.
   - Pin the language version in its version file, such as `.python-version`, and commit the lockfile for the project's packages. Add a step to `.github/workflows/ci.yml` that installs the language and the packages.
   - Add the formatter, linter and fast tests to `scripts/check`. If the project has slow tests, such as end-to-end tests, list their command under "Commands" in `AGENTS.md`.
   - Add the project's package manager, such as pip or npm, to `.github/dependabot.yml`, so that Dependabot updates its packages too.
   - Set the year and the copyright holder in `LICENSE`.
   - Last, replace this README with one for the project, as `docs/writing.md` describes.

## Example: from idea to first release

These are the requests you give your agent. `AGENTS.md` tells it what each one involves.

1. "Plan release v0.1.0: photo-sorter finds duplicate photos in a folder and moves the extra copies to the trash." The agent creates the milestone v0.1.0 and splits the work into issues, each small enough for one pull request. It creates the issues in the order they should be built. When one issue depends on another, the agent marks the first as blocked by the second. Read the issues and correct them before the build starts.
2. "Build milestone v0.1.0." The agent works through the issues one at a time. For each issue, it opens a pull request and merges it once the checks pass. You can read every merged pull request afterwards, because each one records what changed and why. If the agent can't build an issue, it comments on the issue and adds the `needs-decision` label. It skips the issues that depend on that one and builds the rest. Once you have answered, ask it to build the milestone again.
3. "Publish release v0.1.0." The agent checks that every issue in the milestone is closed and runs the slow tests, if there are any. Then it publishes a GitHub release with notes built from the merged pull requests.

## License

MIT. See [LICENSE](LICENSE).
