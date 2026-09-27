# repo-template

Start a GitHub project where people and coding agents follow the same rules to plan, build and release it. Every change goes from an issue to a branch to a pull request, and the pull request merges once the automated checks pass, without anyone having to approve it. This way, you can plan the work as issues and have agents build them in long runs, such as overnight.

The template works with any language. Agents get their instructions from one file, `AGENTS.md`, which Claude Code, Codex, Cursor, GitHub Copilot and most other coding agents read on their own. Gemini CLI and Aider read it only after you point their settings at it.

## What you get

- `AGENTS.md`: the rules for agents and people. They say how to make a change, plan the work, build it and publish a release.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments and error messages.
- `docs/code.md`: how to write code in any language, from design to tests and pinned versions.
- `docs/planning.md`: how an agent turns ideas into issues that are ready to build, and how you decide which ones get built. The ideas can come from any text you share or point the agent to.
- `scripts/check`: one command that runs the same checks on your machine and in CI.
- `scripts/configure-github`: applies the settings that GitHub doesn't copy from a template. It allows only squash merges, makes every change to main go through a pull request that passes CI, lets a pull request merge on its own once its checks pass, and turns on security alerts.
- `.github/`: CI, a check of pull request titles, issue forms, a pull request template, weekly Dependabot updates, release notes settings, and the contributing and security pages.
- `.claude/settings.json`: stops Claude Code from adding its name to commits and pull requests, and keeps its file tools and shell commands such as `cat` away from `.env` files.

## Start a project

You need the GitHub CLI 2.98 or later, signed in with `gh auth login`. If you use Claude Code, update it to version 2.1.281 or later, because earlier versions don't always read `AGENTS.md`.

1. Create a public repository from the template, and clone it. The settings script works only on public repositories.

   ```bash
   gh repo create photo-sorter --public --template jtmpl/repo-template --clone
   ```

2. Apply the GitHub settings from inside the clone:

   ```bash
   cd photo-sorter
   scripts/configure-github
   ```

3. Have your agent set up the project. Like every change, the setup goes through a pull request. You can ask, for example: "Set up this repository for photo-sorter, a command-line tool in Python that finds duplicate photos. Follow the setup list in README.md." If you already have text about the project, add it to your request or point the agent to it. The agent asks you about anything on the list below that your request doesn't settle, such as which languages, frameworks or database to use. The list:

   - In `AGENTS.md`, rewrite "What this project is" for the project: what it's for, and the direction that should guide its changes. Then update the "Where things are" and "Commands" sections with the project's files and its install, run and test commands.
   - Pin the version of each main technology, such as Python in `.python-version`. Commit the lockfile for the project's packages, and add steps to `.github/workflows/ci.yml` that install the technologies and packages.
   - Add the formatter, linter and fast tests to `scripts/check`. If the project has slow tests, such as end-to-end tests, list their command under "Commands" in `AGENTS.md`.
   - Add the project's package manager, such as pip or npm, to `.github/dependabot.yml`, so that Dependabot updates its packages too.
   - Set the year and the copyright holder in `LICENSE`.
   - Last, replace this README with one for the project, as `docs/writing.md` describes.

## Example: from idea to first release

These are the requests you give your agent, in any wording that asks for the same thing. `AGENTS.md` tells it what each one involves.

1. "Plan the first version of photo-sorter: it finds duplicate photos in a folder and moves the extra copies to the trash." If you have text about the project, add it to this request as well, or point the agent to it, because an agent in a new conversation doesn't know what you gave the agent during setup. The agent splits the work into issues, each small enough for one pull request. If issue #2 needs the change from #1 first, the agent marks #2 as blocked by #1. Read the issues and correct them. Tell the agent which ones you approve, and it adds the `ready` label, which lets agents build them.
2. "Build the ready issues." The agent works through them, lowest number first. For each issue, it opens a pull request that merges on its own once the checks pass, and the agent starts the next issue without waiting for the checks. To build several issues at once, ask for helpers, if your agent can start them: "Build the ready issues, with up to 3 helpers." The agent then gives each issue it can start to a helper that works in its own worktree. You can read every merged pull request afterwards, because each one records what changed and why. If an agent can't build an issue, it asks its question in a comment on the issue and adds the `needs-decision` label. It closes the issue's pull request, if there is one, and keeps the branch for the next try. It skips the issues that depend on that one and builds the rest. When it's done, it reports what merged and what's waiting for you, including the issues it couldn't finish.
3. "Publish a release." The agent checks that CI passed on main. It picks the version from the biggest change merged since the last release: a fix, a new feature or a breaking change. The first release is v0.1.0. Then the agent publishes a GitHub release with notes built from the merged pull requests.

### After the first release

Plan, build and release each later version with the same three requests. The requests below cover the rest of the work.

- "Triage these ideas:", followed by the text or a link to it. The agent splits the text into single ideas and recommends what to do with each. It opens issues only for the ideas you approve.
- "Triage the new issues." The agent recommends what to do with each issue that someone else opened, and carries out what you decide.
- "Which issues need my decision?" The agent lists the issues that have `needs-decision`, with the question on each. Tell it your answers, and it writes each one into its issue and removes the label. The next time you ask it to build the ready issues, it builds those issues too.
- "Fix the typo in the README's first sentence.", or any other small change. The agent opens an issue and a pull request for it. Ready issues merge on their own because you approved them while planning, but this pull request waits until you ask. Add "and merge it" to your request, or ask later.
- "Review pull request #12." The agent compares the change with its issue and comments with what should change. It doesn't run code from someone else's pull request on your machine, where that code could reach your credentials. CI runs it on GitHub's machines instead.

## Limits

- The template works only with GitHub. Its settings script works only on public repositories, because GitHub offers private vulnerability reporting only for them. On a free plan, a private repository also can't protect main or merge pull requests on its own.
- A build run merges its pull requests, and Dependabot's, once their checks pass, without anyone reviewing them. The checks catch only what the tests and linters cover.
- Run one build of the ready issues per repository at a time, and ask for helpers to build faster. Two builds that start together can take the same issue. Helpers need an agent that can start other agents.
- On an organization's repository, people with GitHub's Triage role can add `ready`, so give that role only to people you'd let approve work.

## License

MIT. See [LICENSE](LICENSE).
