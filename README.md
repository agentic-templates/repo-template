# repo-template

Start a GitHub project where people and coding agents follow the same rules to plan, build and release it. Every change goes from an issue to a branch to a pull request. Instead of reviewing each pull request, you approve the issues before agents build them. Their pull requests then merge as soon as the automated checks pass.

The template works with any language. Agents get their instructions from `AGENTS.md` and the guides it links to in `docs/`. Claude Code, Codex, Cursor, GitHub Copilot and most other coding agents read `AGENTS.md` on their own. Gemini CLI and Aider read it only after you point their settings at it.

## What you get

- `AGENTS.md`: the rules for agents and people. They say how to make a change, plan the work, build it and publish a release.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments and error messages.
- `docs/code.md`: how to write code in any language, from design to tests and pinned versions.
- `docs/planning.md`: how an agent turns ideas into issues that are ready to build, and how you decide which ones get built. The ideas can come from any text you share or point the agent to.
- `scripts/check`: one command that runs the same checks on your machine and in CI.
- `scripts/configure-github`: applies the settings that GitHub doesn't copy from a template. It allows only squash merges, makes every change to main go through a pull request that passes CI, lets a pull request merge on its own once its checks pass, and turns on security alerts and code scanning.
- `.github/`: CI, a check of pull request titles, issue forms, a pull request template, weekly Dependabot updates, release notes settings, and the contributing and security pages.
- `.claude/settings.json`: stops Claude Code from adding its name to commits and pull requests. It also stops Claude Code's file tools and shell commands such as `cat` from reading `.env` files.

## Start a project

You need the GitHub CLI 2.98 or later, signed in with `gh auth login`. The scripts in `scripts/` need bash, which macOS and Linux include. On Windows, use Git Bash or WSL. If you use Claude Code, update it to version 2.1.281 or later, because earlier versions don't read `AGENTS.md` in every setup.

1. Create a repository from the template, and clone it. A private repository needs a paid GitHub plan, as "Limits" explains.

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
   - Pin the version of each language, framework and database that the project uses, such as Python in `.python-version`. Commit the lockfile for the project's packages, and add steps to `.github/workflows/ci.yml` that install those versions and the packages.
   - Add the formatter, linter and tests to `scripts/check`.
   - If the project's output is visual, such as a web page or a 3D scene, list a command under "Commands" in `AGENTS.md` that saves a picture of it, such as a screenshot of the page or a render of the scene. Agents look at the picture to check their changes, so the command has to run without anyone at the screen. Save the pictures outside the repository, such as in a temporary folder.
   - Add the project's package manager, such as pip or npm, to `.github/dependabot.yml`, so that Dependabot updates its packages too.
   - If the project publishes a package or deploys, add a workflow that does it when a release is published.
   - Set the year and the copyright holder in `LICENSE`.
   - Last, replace this README with one for the project, as `docs/writing.md` describes. Until users can do something with the project, the new README says what the project is for and how to set it up, and that it can't do anything yet.

4. Before you go on to the example below, review the setup's pull request and ask the agent to merge it. The agent merges it only when you ask.

## Example: from idea to first release

These are examples of the requests you give your agent. Use your own words. You can start each one in a new conversation, because the agent finds the state of the work in the repository's files, issues and pull requests. `AGENTS.md` tells it what each one involves.

1. "Plan the first version of photo-sorter: it finds duplicate photos in a folder and moves the extra copies to the trash." If you have notes, a spec or other text about the project, include it in this request or point the agent to it. Do this even if you gave it to an agent before, because an agent in a new conversation can't see earlier ones. The agent splits the work into issues, each small enough for one pull request. If issue #2 needs the change from #1 first, the agent marks #2 as blocked by #1. Read the issues, and correct them on GitHub or ask the agent to. Tell the agent which ones you approve, and it adds the `ready` label. That label lets agents build those issues and merge their pull requests without checking with you.
2. "Build the ready issues." The agent works through them, lowest number first, and skips an issue until the changes it depends on have merged. For each issue, it opens a pull request that merges on its own once the checks pass, and it starts the next issue without waiting for those checks. It also merges Dependabot's patch and minor updates once their checks pass, and leaves major updates for you. If the agent can't finish an issue, it comments on the issue with what it needs from you. If it needs your decision, it also adds the `needs-decision` label. If the issue is too big for one pull request, it adds `needs-breakdown` instead. The agent closes the issue's pull request, if there is one, so that unfinished work can't merge. The work itself stays on the issue's branch. The agent goes on to build the issues that don't depend on that one. When it's done, it reports what merged and what's waiting for you. To answer its questions, ask your agent "Which issues need my decision?" and tell it your answers. It writes your answers into the issues, so your next "Build the ready issues" can continue those issues. You can read every merged pull request afterwards, because each one records what changed and why.
3. "Publish a release." The agent checks that CI passed on main. It picks the next version number from the changes merged since the last release, following semantic versioning. The first release is v0.1.0. Then the agent publishes a GitHub release with notes built from the merged pull requests.

### Build several issues at once

Ask for helpers: "Build the ready issues, with up to 3 helpers." A helper is another agent that your agent launches to build one issue in its own copy of the repository. With this request, no more than 3 helpers run at once. If your agent can't launch other agents, it builds the issues one at a time.

Helpers use the same model and effort as your agent. To choose another model, name it: "Build the ready issues, with up to 3 helpers on Opus." In Claude Code, you can also choose their effort. Write a subagent file in `~/.claude/agents/`, as the [subagent docs](https://code.claude.com/docs/en/sub-agents) describe. In it, set a `name`, such as `build-helper`, and a `description`, such as "Builds one ready issue". Also set the `effort` you want, and a `model` if you want another one. Then ask for it by name: "Build the ready issues, with up to 3 helpers using build-helper."

### Requests for everyday work

Plan, build and release each later version with the same three requests. The requests below cover the rest of the work.

- "Triage these ideas:", followed by the text or a link to it. The agent splits the text into single ideas and recommends what to do with each. It opens issues only for the ideas you accept. Those issues wait in the backlog until you approve them for building.
- "Triage the new issues." The agent recommends what to do with each issue that's waiting for triage, such as a bug report from a user, and carries out what you decide.
- "Make #14 ready to build.", for an issue you accepted at triage or one that has `needs-breakdown`. The agent rewrites the issue, or splits a big one into smaller issues, until it meets the definition of ready in `docs/planning.md`, then asks you to approve it. Your next "Build the ready issues" builds it.
- "Which issues need my decision?" The agent lists the issues that have `needs-decision`, with the question on each. Tell it your answers, and it writes each one into its issue and removes the label.
- "Fix the typo in the README's first sentence.", or any other small change. The agent opens an issue and a pull request for it. Unlike a ready issue's pull request, this one merges only if you ask, so add "and merge it" to your request, or ask later.
- "Review pull request #12." The agent compares the change with its issue and comments with what should change. If the pull request comes from someone without write access to the repository, the agent doesn't run its code on your machine, where that code could reach your credentials. CI runs it on GitHub's machines instead.

## Limits

- The template works only with GitHub. On GitHub Free, use a public repository. A private repository there can't protect main, and its pull requests can't merge on their own.
- On a private repository, `scripts/configure-github` skips private vulnerability reporting, secret scanning and code scanning, and CI skips the check of new dependencies. GitHub offers the first only for public repositories, and the others only with paid add-ons. After you make the repository public, run the script again. CI starts checking new dependencies by itself.
- `.claude/settings.json` doesn't stop every read of a `.env` file. A script can still read one, and so can a command that doesn't mention the file by name, such as `grep -r`.
- A repository made from the template doesn't get the template's later changes. GitHub copies the files once, when it creates the repository.
- A build run of the ready issues merges its pull requests once their checks pass, without anyone reviewing them. It merges Dependabot's patch and minor updates the same way. The checks catch only what the tests, the linters and the check of new dependencies cover. Code scanning reports security problems in the code, but it doesn't stop a merge.
- Start one build run per repository at a time, because two build runs can take the same issue. To build faster, ask for helpers rather than start a second build run in another conversation. Helpers need an agent that can launch other agents.

## License

MIT. See [LICENSE](LICENSE).
