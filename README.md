# repo-template

Start a GitHub project where people and coding agents follow the same rules to plan, build and release it. Every change goes from an issue to a branch to a pull request. The pull request needs no approval, so it can merge as soon as the automated checks pass. This way, you can plan the work as issues and have agents build them in long runs, such as overnight.

The template works with any language. Agents get their instructions from one file, `AGENTS.md`, which Claude Code, Codex, Cursor, GitHub Copilot and most other coding agents read on their own. Gemini CLI and Aider read it only after you point their settings at it.

## What you get

- `AGENTS.md`: the rules for agents and people. They say how to make a change, plan the work, build it and publish a release.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments and error messages.
- `docs/code.md`: how to write code in any language, from design to tests and pinned versions.
- `docs/planning.md`: how an agent turns ideas into issues that are ready to build, and how you decide which ones get built. The ideas can come from any text you share or point the agent to.
- `scripts/check`: one command that runs the same checks on your machine and in CI.
- `scripts/configure-github`: applies the settings that GitHub doesn't copy from a template. It allows only squash merges, makes every change to main go through a pull request that passes CI, lets a pull request merge on its own once its checks pass, and turns on security alerts.
- `.github/`: CI, a check of pull request titles, issue forms, a pull request template, weekly Dependabot updates, release notes settings, and the contributing and security pages.
- `.claude/settings.json`: stops Claude Code from adding its name to commits and pull requests. It also stops Claude Code's file tools and shell commands such as `cat` from reading `.env` files. A script can still read a `.env` file, and so can a command that doesn't name it, such as `grep -r`.

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
   - Add the formatter, linter and tests to `scripts/check`.
   - If the project's output is visual, such as a web page or a 3D scene, list a command under "Commands" in `AGENTS.md` that gives agents something to look at. It has to work without anyone at the screen, but it may keep running, as a development server does. The project's run command is enough if its line under "Commands" says what to open, such as the page's address. Otherwise, add one, such as a script that renders the scene to an image. Rendered images go outside the repository, such as in a temporary folder.
   - Add the project's package manager, such as pip or npm, to `.github/dependabot.yml`, so that Dependabot updates its packages too.
   - Set the year and the copyright holder in `LICENSE`.
   - Last, replace this README with one for the project, as `docs/writing.md` describes.

4. Before you go on to the example below, review the setup's pull request and ask the agent to merge it. The agent merges it only when you ask.

## Example: from idea to first release

These are the requests you give your agent, in your own words. You can start each one in a new conversation, because the agent finds the state of the work in the repository's files, issues and pull requests. `AGENTS.md` tells it what each one involves.

1. "Plan the first version of photo-sorter: it finds duplicate photos in a folder and moves the extra copies to the trash." If you have notes, a spec or other text about the project, include it in this request or point the agent to it. Do this even if you gave it to an agent before, because an agent in a new conversation can't see earlier ones. The agent splits the work into issues, each small enough for one pull request. If issue #2 needs the change from #1 first, the agent marks #2 as blocked by #1. Read the issues, and correct them on GitHub or ask the agent to. Tell the agent which ones you approve, and it adds the `ready` label. That label lets agents build those issues and merge their pull requests without checking with you.
2. "Build the ready issues." The agent works through them, lowest number first, and skips an issue until the changes it depends on have merged. For each issue, it opens a pull request that merges on its own once the checks pass, and it starts the next issue without waiting for those checks. If the agent can't finish an issue, it comments on the issue with what it needs from you. If it needs a decision, it also adds the `needs-decision` label. The agent closes the issue's pull request, if there is one, so that unfinished work can't merge. The work itself stays on the issue's branch. The agent goes on to build the issues that don't depend on that one. When it's done, it reports what merged and what's waiting for you. To answer its questions, ask your agent "Which issues need my decision?" and tell it your answers. It writes your answers into the issues, so your next "Build the ready issues" can continue those issues. You can read every merged pull request afterwards, because each one records what changed and why.
3. "Publish a release." The agent checks that CI passed on main. It picks the next version number from the changes merged since the last release, following semantic versioning. The first release is v0.1.0. Then the agent publishes a GitHub release with notes built from the merged pull requests.

### Build several issues at once

Ask for helpers: "Build the ready issues, with up to 3 helpers." A helper is another agent that your agent launches to build one issue in its own copy of the repository. With this request, no more than 3 helpers run at once. If your agent can't launch other agents, it builds the issues one at a time.

Helpers use the same model and effort as your agent. To choose another model, name it: "Build the ready issues, with up to 3 helpers on Opus." In Claude Code, you can also choose their effort. Write a subagent file in `~/.claude/agents/`, as the [subagent docs](https://code.claude.com/docs/en/sub-agents) describe. In it, set a `name`, such as `photo-helper`, and the `effort` you want, and a `model` if you want another one. Then ask for it by name: "Build the ready issues, with up to 3 helpers using photo-helper."

### Other requests

Plan, build and release each later version with the same three requests. The requests below cover the rest of the work.

- "Triage these ideas:", followed by the text or a link to it. The agent splits the text into single ideas and recommends what to do with each. It opens issues only for the ideas you accept.
- "Triage the new issues." The agent recommends what to do with each new issue that you didn't ask for, such as a bug report from a user, and carries out what you decide.
- "Which issues need my decision?" The agent lists the issues that have `needs-decision`, with the question on each. Tell it your answers, and it writes each one into its issue and removes the label.
- "Fix the typo in the README's first sentence.", or any other small change. The agent opens an issue and a pull request for it. Unlike a ready issue's pull request, this one merges only if you ask, so add "and merge it" to your request, or ask later.
- "Review pull request #12." The agent compares the change with its issue and comments with what should change. It doesn't run code from someone else's pull request on your machine, where that code could reach your credentials. CI runs it on GitHub's machines instead.

## Limits

- The template works only with GitHub. Its settings script works only on public repositories, because GitHub offers private vulnerability reporting only for them. On a free plan, a private repository also can't protect main or merge pull requests on its own.
- A repository made from the template doesn't get the template's later changes. GitHub copies the files once, when it creates the repository.
- A build run merges its pull requests, and Dependabot's, once their checks pass, without anyone reviewing them. The checks catch only what the tests and linters cover.
- Run one build of the ready issues per repository at a time, because two builds can take the same issue. To build faster, ask for helpers rather than start another session. Helpers need an agent that can launch other agents.
- "Publish a release" creates a GitHub release. It doesn't publish a package or deploy the project. To do either, add a workflow that runs when a release is published.

## License

MIT. See [LICENSE](LICENSE).
