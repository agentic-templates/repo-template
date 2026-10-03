# repo-template

Start a GitHub project where people and coding agents follow the same rules to plan, build and release it. Every change goes from an issue to a branch to a pull request. Instead of reviewing each pull request, you approve the issues before agents build them. Each approved issue's pull request merges once its checks pass.

The template works with any language. Agents follow `AGENTS.md` and the guides it links to in `docs/`. Claude Code, Codex, Cursor, GitHub Copilot and most other coding agents read `AGENTS.md` on their own. Gemini CLI and Aider read it only after you point their settings at it.

## Start a project

You need:

- The GitHub CLI 2.98 or later, signed in with `gh auth login`.
- bash, which macOS and Linux include. On Windows, use Git Bash or WSL.
- Claude Code 2.1.281 or later, if you use Claude Code. Earlier versions don't always read `AGENTS.md`.

Optional: to keep your email address out of the project's commits, set git's `user.email` to the noreply address in your GitHub email settings.

1. Create a repository from the template, and clone it. On GitHub Free, make it public, because GitHub Free doesn't offer branch protection or auto-merge for private repositories.

   ```bash
   gh repo create expense-tracker --public --template jtmpl/repo-template --clone
   ```

2. Apply the GitHub settings from inside the clone:

   ```bash
   cd expense-tracker
   scripts/configure-github
   ```

3. Ask your agent to set up the project, for example: "Set up this repository for expense-tracker, a command-line tool in Python that records what you spend. Follow the setup list in README.md." Add any notes or spec you have about the project to your request. The agent asks you whatever else the setup needs, such as which languages, frameworks or database to use.

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

4. Review the setup's pull request, and ask the agent to merge it. Unlike the pull requests for approved issues, this one doesn't merge on its own. The setup replaces this README with one for your project. To read the rest of this page later, open [the template's README](https://github.com/jtmpl/repo-template#example-from-idea-to-first-release).

## Example: from idea to first release

Give your agent these requests in your own words. Each one can start in a new conversation, because the agent finds the state of the work in the repository, its issues and its pull requests.

1. **"Plan the first version of expense-tracker: it adds an expense, lists the expenses and shows the total for each month."**

   Add any notes or spec you have, because the agent can't see what you told it in earlier conversations. It splits the work into issues that each fit in one pull request, and marks each issue as blocked by the ones it needs first. Correct the issues, then tell the agent which ones you approve. It adds the `ready` label to them, so that agents can build and merge them without asking you.

2. **"Build the ready issues."**

   The agent builds them lowest number first, and waits to build an issue until the issues that block it are closed. Each pull request merges once its checks pass. The agent also merges Dependabot's updates once their checks pass. It leaves failing Dependabot updates open for you.

   If the agent can't finish an issue, it closes the issue's pull request, so that unfinished work can't merge. The work stays on the issue's branch. The agent comments on the issue with what it needs, and labels it `needs-decision`. An issue that's too big for one pull request gets `needs-breakdown` instead.

   At the end, the agent reports what merged and what waits for you. Tell it your decisions. It writes each one into its issue and removes `needs-decision`, so the issue is ready to build again. The next build continues the issue's work from its branch.

3. **"Publish a release."**

   The agent checks that CI passed on main, and that code scanning and Dependabot have no open alert of high or critical severity. It picks the next semantic version, starting at v0.1.0, and publishes a GitHub release with notes from the merged pull requests. If a workflow publishes a package or deploys the project, GitHub asks you to approve each of its runs. After the release, the agent lists any security advisories that aren't published yet. An advisory is GitHub's private record of a security problem, and "Fix security problems" below says what to do with one.

### Build several issues at once

Ask for helpers: "Build the ready issues, with up to 3 helpers." A helper is another agent that builds one issue in its own copy of the repository. If your agent can't launch other agents, it builds one issue at a time.

Helpers use the same model and reasoning effort as your agent. To choose another model, name it: "Build the ready issues, with up to 3 helpers on Opus."

In Claude Code, you can also choose their effort. Write a [subagent](https://code.claude.com/docs/en/sub-agents) file in `~/.claude/agents/` with these fields:

- `name`, such as `build-helper`
- `description`
- `effort`
- `model`, if you want another model

Then name it in your request: "Build the ready issues, with up to 3 helpers using build-helper."

### Requests for everyday work

For your project's later versions, use the same three requests. The requests below cover the rest of the work:

- **"Triage these ideas:"**, followed by the text or a link to it. The agent splits the text into single ideas and recommends what to do with each. It opens issues only for the ideas you accept, and those wait in the backlog until you ask to make them ready to build.
- **"Triage the new issues."** The agent recommends what to do with each issue that waits for triage, such as a bug report from a user, and carries out what you decide.
- **"Make #14 ready to build."** Use it for an issue you accepted at triage, or one with `needs-breakdown`. The agent splits a big issue into smaller ones, and rewrites each one until it meets the definition of ready in `docs/planning.md`. Then it asks you to approve them.
- **"Which issues need my decision?"** The agent lists the issues with `needs-decision`, and the question on each. Tell it your answers, and it writes each one into its issue and removes the label.
- **"Fix the typo in the README's first sentence."**, or any other small change. The agent opens an issue and a pull request for it. Unlike a ready issue's pull request, this one merges only when you ask, so add "and merge it" to your request, or ask later.
- **"Review pull request #12."** The agent compares the change with its issue and comments with what should change. If the pull request comes from someone without write access, the agent doesn't run the pull request's code on your machine, where it could reach your credentials. CI runs it on GitHub's machines instead.
- **"Review the code for security problems."** The agent reviews the whole repository, unless you name a part of it or a range of changes, such as the changes since the last release. It tells you what it found and which parts it reviewed.

### Fix security problems

Issues and pull requests are public or can become public, so the agent keeps a security problem out of them until a release fixes it. On a public repository, it records the problem in a security advisory. `.github/SECURITY.md` asks people to report problems privately, and GitHub creates an advisory for each such report.

1. Ask the agent to fix the problem. On a public repository, it builds the fix in a temporary private fork that GitHub creates for the advisory. On a private repository, it uses an issue and a pull request that say what the fix changes, without describing the problem.
2. Ask for a release. Ask right away if the problem's severity is high or critical, or if the problem is already public. If someone reported the problem, ask within 90 days of their report, because `.github/SECURITY.md` asks reporters to keep a problem private only that long. The agent asks whether the release should include each fix that's waiting in a private fork.
3. Once the checks pass, the agent merges the fix and publishes the release right away. Merging makes the fix public, and users can't update until the release is out, so the agent keeps that gap short.
4. Start a new conversation, because an agent checks less carefully in the conversation where it published the release. In it, ask "Check the security advisories." The agent checks whether each problem is still in the released code, and looks closely at each fix, because a fix can be incomplete.
5. Ask the agent to publish only the advisories you're sure are fixed, and only once users can install the release, because a published advisory shows attackers where to look. In each advisory it publishes, the agent names the release that fixes the problem, and it links to the advisory from the release notes.

## Limits

- The template works only with GitHub. On GitHub Free, it works only with a public repository.
- On a private repository, even on a paid plan, `scripts/configure-github` and CI skip these features:
  - Secret scanning, code scanning and CI's check of new dependencies for known vulnerabilities, because GitHub charges extra for these on private repositories.
  - Private vulnerability reporting, which GitHub offers only for public repositories.
  - The `release` environment, where jobs that publish the project wait for your approval. On private repositories, GitHub offers that approval only with GitHub Enterprise.

  After you make the repository public, run the script again to turn on what it skipped. CI turns its check of new dependencies back on by itself.

- `.claude/settings.json` blocks only some of the ways that Claude Code could read a `.env` file. A script can still read one, and so can a command that doesn't name the file, such as `grep -r`.
- A repository made from the template doesn't get the template's later changes, because GitHub copies the files only once.
- On an organization's repository, people with GitHub's Triage role can add `ready`, so give that role only to people you'd let approve work.
- When an agent builds the ready issues, it merges their pull requests, and Dependabot's, without anyone reviewing them. If a change passes the tests, the linters, the type checker and the check of new dependencies, it merges, whatever else is wrong with it. Code scanning reports security problems, but it doesn't stop a merge.
- If your project is a library, the setup in step 3 of "Start a project" can add a check that finds breaking changes. In any other project, nothing checks for them, and an agent marks a pull request as a breaking change only when it notices the break. So a release can miss a breaking change and raise the version number too little.
- Ask only one agent at a time to build a repository's ready issues, because two agents can take the same issue. To build faster, ask that agent for helpers. Helpers need an agent that can launch other agents.

## What you get

- `AGENTS.md`: the rules for agents and people, from making a change to publishing a release.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments and error messages.
- `docs/pages.md`: how to organize a page and write a README, and how to check that a changed page reads clearly.
- `docs/rules.md`: how to change AGENTS.md, the guides and the labels.
- `docs/code.md`: how to write code in any language, covering design and tests.
- `docs/dependencies.md`: how to choose, pin and update tools, packages and GitHub Actions.
- `docs/planning.md`: how an agent turns ideas into issues that are ready to build, and how you choose which ones get built.
- `docs/building.md`: how an agent builds the issues you approved, alone or with helpers.
- `docs/reviewing.md`: how an agent reviews a pull request, and reviews the code for security problems.
- `docs/releasing.md`: how an agent publishes a release, writes a workflow that publishes or deploys the project, checks the security advisories, and records and fixes a security problem that isn't public yet.
- `scripts/check`: runs the same checks on your machine and in CI.
- `scripts/configure-github`: applies the settings that GitHub doesn't copy from a template.
  - Pull requests merge only as squash merges.
  - Pull requests can merge on their own once their checks pass.
  - Every change to main goes through a pull request that passes CI.
  - Security alerts and code scanning are on.
  - Jobs that publish the project wait for your approval in a `release` environment.
- `.github/`: CI, a check of each pull request's title and body, issue forms, a pull request template, weekly Dependabot updates, release notes settings, and the contributing and security pages.
- `.claude/settings.json`: stops Claude Code from adding its name to commits and pull requests, and from reading `.env` files with its file tools or with shell commands such as `cat`.

## License

[MIT](LICENSE)
