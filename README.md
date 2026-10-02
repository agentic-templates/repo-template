# repo-template

Start a GitHub project where people and coding agents follow the same rules to plan, build and release it. Every change goes from an issue to a branch to a pull request. Instead of reviewing each pull request, you approve the issues before agents build them. Their pull requests then merge as soon as the automated checks pass.

The template works with any language. Agents get their instructions from `AGENTS.md` and the guides it links to in `docs/`. Claude Code, Codex, Cursor, GitHub Copilot and most other coding agents read `AGENTS.md` on their own. Gemini CLI and Aider read it only after you point their settings at it.

## What you get

- `AGENTS.md`: the rules for agents and people. They say how to make a change, plan the work, build it and publish a release.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments and error messages.
- `docs/code.md`: how to write code in any language, covering design, tests, pinned versions and keeping publishing credentials safe.
- `docs/planning.md`: how an agent turns ideas into issues that are ready to build, and how you decide which ones get built. The ideas can come from any text you share or point the agent to.
- `docs/building.md`: how an agent builds the issues you approved, alone or with helpers, and merges their pull requests.
- `docs/reviewing.md`: how an agent reviews a pull request, and reviews the code for security problems.
- `docs/releasing.md`: how an agent publishes a release, checks the security advisories and fixes a security problem that isn't public yet.
- `scripts/check`: one command that runs the same checks on your machine and in CI.
- `scripts/configure-github`: applies the settings that GitHub doesn't copy from a template. It allows only squash merges, makes every change to main go through a pull request that passes CI, lets a pull request merge on its own once its checks pass, and turns on security alerts and code scanning. It also creates a `release` environment, where a job that publishes the project waits for your approval.
- `.github/`: CI, a check of each pull request's title and body, issue forms, a pull request template, weekly Dependabot updates, release notes settings, and the contributing and security pages.
- `.claude/settings.json`: stops Claude Code from adding its name to commits and pull requests. It also stops Claude Code from reading `.env` files, both with its file tools and with shell commands such as `cat`.

## Start a project

You need the GitHub CLI 2.98 or later, signed in with `gh auth login`. The scripts in `scripts/` need bash, which macOS and Linux include. On Windows, use Git Bash or WSL. If you use Claude Code, update it to version 2.1.281 or later, because earlier versions don't always read `AGENTS.md`. If you want to keep your email address out of the project's commits, set git's `user.email` to the noreply address listed in your GitHub email settings.

1. Create a repository from the template, and clone it. A private repository needs a paid GitHub plan to protect main and to let pull requests merge on their own, as "Limits" explains.

   ```bash
   gh repo create expense-tracker --public --template jtmpl/repo-template --clone
   ```

2. Apply the GitHub settings from inside the clone:

   ```bash
   cd expense-tracker
   scripts/configure-github
   ```

3. Have your agent set up the project. Like every change, the setup goes through a pull request. You can ask, for example: "Set up this repository for expense-tracker, a command-line tool in Python that records what you spend. Follow the setup list in README.md." If you already have text about the project, add it to your request or point the agent to it. The agent asks you about anything on the list below that your request doesn't settle, such as which languages, frameworks or database to use. The list:

   - In `AGENTS.md`, rewrite the section "What this project is": what the project is for, and which kinds of change belong in it. Then update the "Where things are" and "Commands" sections with the project's files and its install, run and test commands.
   - Pin the version of each language, framework and database that the project uses, such as Python in `.python-version`. Commit the lockfile for the project's packages, and add steps to `.github/workflows/ci.yml` that install those versions and the packages.
   - Add the formatter, the linter, the type checker if the language has one, and the tests to `scripts/check`.
   - If the language's coverage tool can mark single lines as excluded, add a coverage check to `scripts/check`. The check fails when a line never runs in a test. Where the tool measures branches, the check also fails when a branch is never taken. Lines marked as excluded don't count, but the check fails on an exclusion marker that gives no reason. Measure coverage with the tests that `scripts/check` runs, and with no others. If the tool can't mark lines as excluded, add no coverage check, because the check would always fail on code that no test can run.
   - If the project publishes a library and its language has a tool that finds breaking changes, such as cargo-semver-checks for Rust, add a check to CI that looks for a break in the library's public interface. If a pull request breaks the interface, the check fails, unless the pull request's title marks the change with `!` before the colon, as in `feat!: rename the import command`. Have the check compare the pull request with the commit on main that it branched from, not with the last release. Once a breaking change has merged, main itself differs from the last release, so a comparison with that release would fail every later pull request.
   - If the project's output is visual, such as a web page or a 3D scene, add a command that saves a picture of that output, such as a screenshot of the page or a render of the scene. List the command under "Commands" in `AGENTS.md`. Agents look at the picture to check their changes, so the command has to run without anyone at the screen. Save the pictures outside the repository, such as in a temporary folder.
   - Add the project's package manager, such as pip or npm, to `.github/dependabot.yml`, so that Dependabot updates its packages too.
   - If the project publishes a package or deploys, add a workflow that does it when a release is published.
   - Set the year and the copyright holder in `LICENSE`.
   - Last, replace this README with one for the project, as `docs/writing.md` describes. Until users can do something with the project, the new README says what the project is for, and that it can't do anything yet.

4. Before you go on to the example below, review the setup's pull request and ask the agent to merge it. Unlike the pull requests for issues you approve, it doesn't merge on its own. Once the setup merges, your README describes your project. Read the rest of this page in [the template's README](https://github.com/jtmpl/repo-template#example-from-idea-to-first-release).

## Example: from idea to first release

These are examples of the requests you give your agent. Use your own words. You can start each one in a new conversation, because the agent finds the state of the work in the repository's files, issues and pull requests. `AGENTS.md` tells it what each request involves.

1. "Plan the first version of expense-tracker: it adds an expense, lists the expenses and shows the total for each month." If you have notes, a spec or other text about the project, include it in this request or point the agent to it. Do this even if you gave it to an agent before, because an agent in a new conversation can't see earlier ones. The agent splits the work into issues, each small enough for one pull request. If issue #2 needs the change from #1 first, the agent marks #2 as blocked by #1. Read the issues, and correct them on GitHub or ask the agent to. Tell the agent which ones you approve, and it adds the `ready` label. That label lets agents build those issues and merge their pull requests without checking with you.
2. "Build the ready issues." The agent works through them, lowest number first, and skips an issue until the changes it depends on have merged. For each issue, it opens a pull request that merges on its own once the checks pass, and it starts the next issue without waiting for those checks. It also merges Dependabot's updates once their checks pass, and leaves the ones that fail for you. If the agent can't finish an issue, it comments on the issue with what it needs from you. It also closes that issue's pull request, if there is one, so that unfinished work can't merge. The work itself stays on the issue's branch. If the issue needs your decision, the agent adds the `needs-decision` label. If the issue is too big for one pull request, it adds `needs-breakdown` instead. The agent goes on to build the issues that don't depend on that one. When it's done, it reports what merged and what's waiting for you. To see its questions again later, ask "Which issues need my decision?" Tell the agent your answers, and it writes them into the issues. Your next "Build the ready issues" then builds those issues, starting from the work on their branches. You can read every merged pull request afterwards, because each one records what changed and why.
3. "Publish a release." The agent checks that CI passed on main, and that neither code scanning nor Dependabot has an open alert of high or critical severity. It picks the next version number from the changes merged since the last release, following semantic versioning. The first release is v0.1.0. Then the agent publishes a GitHub release with notes built from the merged pull requests. If the project publishes a package or deploys, GitHub then asks you to approve that run. Last, it lists any security advisories that aren't published yet. An advisory is GitHub's record of a security problem, which stays private until you publish it. "Fix security problems" below says what to do with one.

### Build several issues at once

Ask for helpers: "Build the ready issues, with up to 3 helpers." A helper is another agent that your agent launches to build one issue in its own copy of the repository. With this request, no more than 3 helpers run at once. If your agent can't launch other agents, it builds the issues one at a time.

Helpers use the same model and effort as your agent. To choose another model, name it: "Build the ready issues, with up to 3 helpers on Opus." In Claude Code, you can also choose their effort. Write a subagent file in `~/.claude/agents/`, as the [subagent docs](https://code.claude.com/docs/en/sub-agents) describe. In it, set a `name`, such as `build-helper`, and a `description`, such as "Builds one ready issue". Also set the `effort` you want, and a `model` if you want another one. Then ask for it by name: "Build the ready issues, with up to 3 helpers using build-helper."

### Requests for everyday work

Plan, build and release each later version with the same three requests. The requests below cover the rest of the work.

- "Triage these ideas:", followed by the text or a link to it. The agent splits the text into single ideas and recommends what to do with each. It opens issues only for the ideas you accept. Those issues wait in the backlog until you ask the agent to make them ready to build.
- "Triage the new issues." The agent recommends what to do with each issue that's waiting for triage, such as a bug report from a user, and carries out what you decide.
- "Make #14 ready to build." Use this request for an issue you accepted at triage, or for one that has `needs-breakdown`. The agent splits a big issue into smaller ones, and rewrites each issue until it meets the definition of ready in `docs/planning.md`. Then it asks you to approve them. Your next "Build the ready issues" builds the ones you approved.
- "Which issues need my decision?" The agent lists the issues that have `needs-decision`, with the question on each. Tell it your answers, and it writes each one into its issue and removes the label.
- "Fix the typo in the README's first sentence.", or any other small change. The agent opens an issue and a pull request for it. Unlike a ready issue's pull request, this one merges only if you ask, so add "and merge it" to your request, or ask later.
- "Review pull request #12." The agent compares the change with its issue and comments with what should change. If the pull request comes from someone without write access to the repository, the agent doesn't run its code on your machine, where that code could reach your credentials. CI runs it on GitHub's machines instead.
- "Review the code for security problems." The agent reviews the whole repository, unless you name a part or a range of changes. For example, before a release, ask it to review the changes since the last release. It tells you what it finds and which parts it reviewed. "Fix security problems" below says what happens next.

### Fix security problems

The agent doesn't describe a security problem in an issue or a pull request until a release fixes it, because those are public or can become public. On a public repository, it records the problem privately as a security advisory. When someone reports a problem privately, as `.github/SECURITY.md` asks, GitHub creates an advisory for it too.

1. Ask the agent to fix the problem. On a public repository, it builds the fix in a temporary private fork that GitHub creates for the advisory. On a private repository, it makes the fix through an issue and a pull request that describe the change, not the problem.
2. Ask for a release. If a fix is waiting in a private fork, the agent asks whether to include it. If the problem is of high or critical severity or already public, ask for the release right away. If someone reported the problem, ask for the release within 90 days of their report, because `.github/SECURITY.md` asks reporters to keep a problem private only that long.
3. When you include a fix from a private fork, the agent merges it and publishes the release as soon as the checks pass. Merging makes the fix public. The agent releases right away, so that attackers have as little time as possible before users can update.
4. After the release, the agent lists the advisories that aren't published yet. Start a new conversation to check whether they're fixed, because an agent performs worse when its context also holds the work of publishing the release. The request is "Check the security advisories." The agent checks whether each advisory's problem is still in the release, and looks closely at each fix, because a fix can still be incomplete. Ask the agent to publish only the ones you're sure are fixed, and only once users can install the release, because publishing an advisory shows attackers where to look. When the agent publishes one, it records in the advisory which release fixes the problem, and adds a link to the advisory in the release notes.

## Limits

- The template works only with GitHub. On GitHub Free, use a public repository. A private repository there can't protect main, and its pull requests can't merge on their own.
- On a private repository, `scripts/configure-github` skips secret scanning and code scanning, and CI skips its check for known vulnerabilities in new dependencies, because GitHub charges extra for these on private repositories. The script also skips private vulnerability reporting, which GitHub offers only for public repositories. It skips the `release` environment on every private repository, because GitHub offers its approval rule there only with GitHub Enterprise. After you make the repository public, run the script again. CI starts checking new dependencies by itself.
- `.claude/settings.json` doesn't stop every read of a `.env` file. A script can still read one, and so can a command that doesn't mention the file by name, such as `grep -r`.
- A repository made from the template doesn't get the template's later changes. GitHub copies the files once, when it creates the repository.
- A build run of the ready issues merges its pull requests once their checks pass, without anyone reviewing them. It merges Dependabot's updates the same way. The checks catch only what the tests, the linters, the type checker and the check of new dependencies cover. Code scanning reports security problems in the code, but it doesn't stop a merge.
- Nothing checks for breaking changes, unless the project is a library whose setup added that check. In every other project, an agent marks a breaking change with `!` in the pull request's title only when it notices one.
- Start one build run per repository at a time, because two build runs can take the same issue. To build faster, ask for helpers rather than start a second build run in another conversation. Helpers need an agent that can launch other agents.

## License

MIT. See [LICENSE](LICENSE).
