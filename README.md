# repo-template

Start a GitHub project where people and coding agents follow the same rules to plan, build and release it. Every change goes from an issue to a branch to a pull request. You approve issues instead of reviewing pull requests. Agents build the approved issues, and each pull request merges once its checks pass.

The template works with any language. Agents follow `AGENTS.md` and the guides it links to in `docs/`. Claude Code, Codex, Cursor, GitHub Copilot and most other coding agents read `AGENTS.md` on their own. Gemini CLI and Aider read it only after you point their settings at it.

## Start a project

You need:

- The GitHub CLI 2.98 or later, signed in with `gh auth login`.
- bash, which macOS and Linux include. On Windows, use Git Bash or WSL.
- Claude Code 2.1.281 or later, if you use Claude Code. Earlier versions don't always read `AGENTS.md`.

To keep your email address out of the project's commits, set git's `user.email` to the noreply address in your GitHub email settings.

1. Create a repository from the template, and clone it. On GitHub Free, make it public, as "Limits" explains.

   ```bash
   gh repo create expense-tracker --public --template jtmpl/repo-template --clone
   ```

2. Apply the GitHub settings from inside the clone:

   ```bash
   cd expense-tracker
   scripts/configure-github
   ```

3. Ask your agent to set up the project, for example: "Set up this repository for expense-tracker, a command-line tool in Python that records what you spend. Follow the setup list in README.md." Include any text you have about the project. The agent asks you about anything else the list needs, such as which languages, frameworks or database to use.

   <details>
   <summary>The setup list, for your agent</summary>


   - In `AGENTS.md`, rewrite the section "What this project is": what the project is for, and which kinds of change belong in it. Then update the "Where things are" and "Commands" sections with the project's files and its install, run and test commands.
   - Pin the version of each language, framework and database that the project uses, such as Python in `.python-version`. Commit the lockfile for the project's packages, and add steps to `.github/workflows/ci.yml` that install those versions and the packages.
   - Add the formatter, the linter, the type checker if the language has one, and the tests to `scripts/check`.
   - If the language's coverage tool can mark single lines as excluded, add a coverage check to `scripts/check`. The check fails when a line never runs in a test. Where the tool measures branches, the check also fails when a branch is never taken. Lines marked as excluded don't count, but the check fails on an exclusion marker that gives no reason. Measure coverage with the tests that `scripts/check` runs, and with no others. If the tool can't mark lines as excluded, add no coverage check, because the check would always fail on code that no test can run.
   - If the project publishes a library and its language has a tool that finds breaking changes, such as cargo-semver-checks for Rust, add a check to CI that looks for a break in the library's public interface. If a pull request breaks the interface, the check fails, unless the pull request's title marks the change with `!` before the colon, as in `feat!: rename the import command`. Have the check compare the pull request with the commit on main that it branched from, not with the last release. Once a breaking change has merged, main itself differs from the last release, so a comparison with that release would fail every later pull request.
   - If the project's output is visual, such as a web page or a 3D scene, add a command that saves a picture of that output, such as a screenshot of the page or a render of the scene. List the command under "Commands" in `AGENTS.md`. Agents look at the picture to check their changes, so the command has to run without anyone at the screen. Save the pictures outside the repository, such as in a temporary folder.
   - Add the project's package manager, such as pip or npm, to `.github/dependabot.yml`, so that Dependabot updates its packages too.
   - If the project publishes a package or deploys, add a workflow that does it when a release is published.
   - Set the year and the copyright holder in `LICENSE`.
   - Last, replace this README with one for the project, as `docs/pages.md` describes. Until users can do something with the project, the new README says what the project is for, and that it can't do anything yet.

   </details>

4. Review the setup's pull request, and ask the agent to merge it, because it doesn't merge on its own. The setup replaces this README, so read the rest of this page in [the template's README](https://github.com/jtmpl/repo-template#example-from-idea-to-first-release).

## Example: from idea to first release

Give your agent these requests in your own words. Each one can start in a new conversation, because the agent finds the state of the work in the repository, its issues and its pull requests.

1. **"Plan the first version of expense-tracker: it adds an expense, lists the expenses and shows the total for each month."**

   Add your notes or spec, because the agent can't see earlier conversations. It splits the work into issues that each fit in one pull request, and marks each issue as blocked by the ones it needs first. Correct the issues, then tell the agent which ones you approve. It labels them `ready`, so that agents can build and merge them without asking you.

2. **"Build the ready issues."**

   The agent builds them lowest number first, and skips an issue until its blocking issues are closed. Each pull request merges once its checks pass, while the agent moves on to the next issue. Dependabot's updates merge the same way, and the agent leaves the ones that fail for you.

   If the agent can't finish an issue, it comments with what it needs, and labels the issue `needs-decision`, or `needs-breakdown` if it's too big for one pull request. It closes the issue's pull request, so that unfinished work can't merge, and keeps the work on the issue's branch.

   At the end, the agent reports what merged and what waits for you. Tell it your answers, and it writes them into the issues. Your next "Build the ready issues" builds those issues from their branches.

3. **"Publish a release."**

   The agent checks that CI passed on main, and that no security alert of high or critical severity is open. It picks the next semantic version, starting at v0.1.0, and publishes a GitHub release with notes from the merged pull requests. If the project publishes a package or deploys, GitHub asks you to approve that run. Then the agent lists the security advisories that aren't published yet, as "Fix security problems" explains.

### Build several issues at once

Ask for helpers: "Build the ready issues, with up to 3 helpers." A helper is another agent that builds one issue in its own copy of the repository. If your agent can't launch other agents, it builds one issue at a time.

Helpers use your agent's model and effort. To choose another model, name it: "Build the ready issues, with up to 3 helpers on Opus."

In Claude Code, you can also choose their effort. Write a [subagent](https://code.claude.com/docs/en/sub-agents) file in `~/.claude/agents/` with a `name` such as `build-helper`, a `description`, an `effort` and, if you want another model, a `model`. Then name it in your request: "Build the ready issues, with up to 3 helpers using build-helper."

### Requests for everyday work

Later versions use the same three requests. These cover the rest of the work:

- **"Triage these ideas:"**, followed by the text or a link to it. The agent splits the text into single ideas and recommends what to do with each. It opens issues only for the ideas you accept, and those wait in the backlog until you ask to make them ready to build.
- **"Triage the new issues."** The agent recommends what to do with each issue that waits for triage, such as a bug report from a user, and carries out what you decide.
- **"Make #14 ready to build."** Use it for an issue you accepted at triage, or one with `needs-breakdown`. The agent splits a big issue into smaller ones, and rewrites each one until it meets the definition of ready in `docs/planning.md`. Then it asks you to approve them.
- **"Which issues need my decision?"** The agent lists the issues with `needs-decision`, and the question on each. Tell it your answers, and it writes each one into its issue and removes the label.
- **"Fix the typo in the README's first sentence."**, or any other small change. The agent opens an issue and a pull request for it. This pull request merges only when you ask, so add "and merge it" to your request, or ask later.
- **"Review pull request #12."** The agent compares the change with its issue and comments with what should change. It doesn't run code from someone without write access on your machine, where that code could reach your credentials. CI runs it on GitHub's machines instead.
- **"Review the code for security problems."** The agent reviews the whole repository, or the part or range of changes you name, such as the changes since the last release. It tells you what it found and which parts it reviewed.

### Fix security problems

Issues and pull requests are public or can become public, so the agent keeps a security problem out of them until a release fixes it. On a public repository, it records the problem in a security advisory, GitHub's private record of a problem. A problem that someone reports privately, as `.github/SECURITY.md` asks, gets an advisory too.

1. Ask the agent to fix the problem. On a public repository, it builds the fix in a temporary private fork that GitHub creates for the advisory. On a private repository, it uses an issue and a pull request that describe the change, not the problem.
2. Ask for a release, right away if the problem is of high or critical severity or already public. Ask within 90 days of a report, because `.github/SECURITY.md` asks reporters to keep a problem private only that long. If a fix waits in a private fork, the agent asks whether to include it.
3. Merging the fix makes it public, so the agent publishes the release as soon as the checks pass. That leaves attackers as little time as possible before users can update.
4. In a new conversation, ask "Check the security advisories." An agent does worse when its context also holds the release. The agent checks whether each problem is still in the release, and looks closely at each fix, because a fix can be incomplete.
5. Ask the agent to publish only the advisories you're sure are fixed, and only once users can install the release, because a published advisory shows attackers where to look. The agent records in each advisory the release that fixes the problem, and links to the advisory from the release notes.

## Limits

- The template works only with GitHub. On GitHub Free, a private repository can't protect main, and its pull requests can't merge on their own.
- On a private repository, `scripts/configure-github` and CI skip the features below. After you make the repository public, run the script again. CI starts its check by itself.
  - Secret scanning, code scanning and CI's check of new dependencies for known vulnerabilities, because GitHub charges extra for these on private repositories.
  - Private vulnerability reporting, which GitHub offers only for public repositories.
  - The `release` environment, because GitHub offers its approval rule on private repositories only with GitHub Enterprise.
- `.claude/settings.json` doesn't stop every read of a `.env` file. A script can still read one, and so can a command that doesn't name the file, such as `grep -r`.
- A repository made from the template doesn't get the template's later changes, because GitHub copies the files only once.
- On an organization's repository, people with GitHub's Triage role can add `ready`, so give that role only to people you'd let approve work.
- A build run merges pull requests, Dependabot's included, without anyone reviewing them. The checks catch only what the tests, the linters, the type checker and the check of new dependencies cover. Code scanning reports security problems, but it doesn't stop a merge.
- Nothing checks for breaking changes, unless the project is a library whose setup added that check. In every other project, an agent marks a breaking change with `!` in the pull request's title only when it notices one.
- Start one build run per repository at a time, because two build runs can take the same issue. To build faster, ask for helpers, which need an agent that can launch other agents.

## What you get

- `AGENTS.md`: the rules for agents and people, from making a change to publishing a release.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments and error messages.
- `docs/pages.md`: how to organize a page, write a README and review a changed page with a fresh reader.
- `docs/rules.md`: how to change AGENTS.md, the guides and the labels.
- `docs/code.md`: how to write code in any language, covering design and tests.
- `docs/dependencies.md`: how to choose, pin and update tools, packages and GitHub Actions.
- `docs/planning.md`: how an agent turns ideas into issues that are ready to build, and how you choose which ones get built.
- `docs/building.md`: how an agent builds the issues you approved, alone or with helpers.
- `docs/reviewing.md`: how an agent reviews a pull request, and reviews the code for security problems.
- `docs/releasing.md`: how an agent publishes a release, writes a workflow that publishes or deploys the project, checks the security advisories, and records and fixes a security problem that isn't public yet.
- `scripts/check`: runs the same checks on your machine and in CI.
- `scripts/configure-github`: applies the settings that GitHub doesn't copy from a template: squash merges only, a pull request that passes CI for every change to main, auto-merge, security alerts, code scanning, and a `release` environment where a job that publishes the project waits for your approval.
- `.github/`: CI, a check of each pull request's title and body, issue forms, a pull request template, weekly Dependabot updates, release notes settings, and the contributing and security pages.
- `.claude/settings.json`: stops Claude Code from adding its name to commits and pull requests, and from reading `.env` files with its file tools or with shell commands such as `cat`.

## License

[MIT](LICENSE)
