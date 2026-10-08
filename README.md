# repo-template

Start a GitHub project where people and coding agents follow the same rules to plan, build and release it. Every change goes from an issue to a branch to a pull request. You don't need to review each pull request. You approve the issues before agents build them, or ask an agent for a change yourself. Either way, the agent's pull request merges once its checks pass.

The template works with any language, and with any coding tool that runs the hooks set up in `.claude/settings.json` or `.codex/hooks.json`. Agents follow `AGENTS.md` and the guides it links to in `docs/`.

## Start a project

You need:

- The GitHub CLI 2.98 or later, signed in with `gh auth login`.
- bash, which macOS and Linux include. On Windows, use Git Bash or WSL.
- [jq](https://jqlang.org/download/). Without it, the agent hooks let every action through, and `scripts/check` skips the hooks' tests on your machine.
- Claude Code 2.1.281 or later, if you use Claude Code. Earlier versions don't always read `AGENTS.md`.

Optional: to keep your email address out of the project's commits, set git's `user.email` to the noreply address in your GitHub email settings.

1. The template merges pull requests through GitHub's merge queue, which only an organization's repositories can use. If you don't have a GitHub organization yet, create a free one in your browser, at https://github.com/account/organizations/new, because GitHub has no command for it.

2. Create a repository in the organization from the template, clone it, and go into the clone. Make the repository public, because the template supports only public repositories.

   ```bash
   gh repo create <organization>/expense-tracker --public --template agentic-templates/repo-template --clone
   cd expense-tracker
   ```

3. Start your agent in the clone, and ask it to set up the project, for example: "Set up this repository for expense-tracker, a command-line tool in Python that records what you spend. Follow the setup list in README.md." Add any notes or spec you have about the project to your request. The agent asks you whatever else the setup needs, such as which languages, frameworks or database to use.

   <details>
   <summary>The setup list, for your agent</summary>


   - First, run `gh api "repos/{owner}/{repo}/rulesets?includes_parents=false"`, as written, because gh fills in the owner and the repository. If it lists no ruleset named `main`, the repository's settings haven't been applied yet, so run `scripts/configure-github` to apply them. Run the script before you open the setup's pull request, so that the rules that protect main apply to it. If the script stops with an error, stop the setup, and pass the error on to the person who asked for it. When the script finishes, tell the person who asked for the setup to turn on Dependabot malware alerts at the link that the script prints.
   - In `AGENTS.md`, rewrite the section "What this project is": what the project is for, and which kinds of change belong in it. Then update the "Where things are" and "Commands" sections with the files and commands that belong to the whole project rather than to one language, such as a Docker Compose file.
   - For each language the project uses, follow `docs/languages.md`.
   - If the project's output is visual, such as a web page or a 3D scene, add a command that saves a picture of that output, such as a screenshot of the page or a render of the scene. List the command under "Commands" in `AGENTS.md`. The command has to run without anyone at the screen. Save the pictures outside the repository, such as in a temporary folder.
   - If the project publishes a package or deploys, add a workflow that does it when a release is published.
   - Set the year and the copyright holder in `LICENSE`.
   - Last, replace this README with one for the project, as `docs/pages.md` describes. Until users can do something with the project, the new README says what the project is for, and that it can't do anything yet.

   </details>

   The setup replaces this README with one for your project. To read the rest of this page later, open [the template's README](https://github.com/agentic-templates/repo-template#example-from-idea-to-first-release).

## Example: from idea to first release

Give your agent these requests in your own words. Each one can start in a new conversation, because the agent finds the state of the work in the repository, its issues and its pull requests.

1. **"Plan the first version of expense-tracker: it adds an expense, lists the expenses and shows the total for each month."**

   Add your notes or spec, even if you gave them for the setup, because the agent can't see what you told it in earlier conversations. It splits the work into issues that each fit in one pull request, and marks each issue as blocked by the ones it needs first. Correct the issues on GitHub or ask the agent to, then tell it which ones you approve. It adds the `ready` label to them, so that agents can build and merge them without asking you.

2. **"Build the ready issues."**

   The agent builds them lowest number first, and waits to build an issue until the issues that block it are closed.

   If the agent can't finish an issue, it closes the issue's pull request and keeps the work on the issue's branch. The agent comments on the issue with what it needs, and labels it `needs-decision`. An issue that's too big for one pull request gets `needs-breakdown` instead.

   At the end, the agent reports what merged and what waits for you. Tell it your decisions. It writes each one into its issue and removes `needs-decision`. The issue still has `ready`, so your next "Build the ready issues" takes it again, starting from the work on the issue's branch.

3. **"Publish a release."**

   The agent checks that CI passed on main, and that code scanning and Dependabot have no open alert of high or critical severity. It picks the next semantic version, starting at v0.1.0, and publishes a GitHub release with notes from the merged pull requests. If a workflow publishes a package or deploys the project, GitHub asks you to approve each of its runs. An advisory is GitHub's record of a security problem, which stays private until you publish it. After the release, the agent lists the advisories that you haven't published yet, and "Fix security problems" below says what to do with them.

### Build several issues at once

When you ask your agent to build the ready issues, it uses up to 4 helpers at the same time, so that it builds several issues at once. A helper is another agent that builds one issue in its own copy of the repository. To change how many helpers work at the same time, name the number: "Build the ready issues, with up to 3 helpers." To build one issue at a time, ask "Build the ready issues, without helpers." If your agent can't launch other agents, it builds one issue at a time.

Helpers use the same model and reasoning effort as your agent. To choose another model, name it: "Build the ready issues, with up to 3 helpers on Opus."

In Claude Code, you can also choose their effort. Write a [subagent](https://code.claude.com/docs/en/sub-agents) file in `~/.claude/agents/` with these fields:

- `name`, such as `build-helper`
- `description`
- `effort`
- `model`, if you want another model

Then name it in your request: "Build the ready issues, with up to 3 helpers using build-helper."

### Requests for everyday work

For your project's later versions, use the same three requests. The requests below cover the rest of the work:

- **"Triage these ideas:"**, followed by the text or a link to it. The agent splits the text into single ideas. It opens issues for the ideas it accepts, and asks you about the ones it would drop, that are too vague or that need your decision. The issues wait in the backlog until you ask to make them ready to build.
- **"Triage the new issues."** The agent recommends what to do with each issue that waits for triage, such as a bug report from a user, and carries out what you decide.
- **"Make #14 ready to build."** Use it for any issue in the backlog, including one with `needs-breakdown`. The agent splits a big issue into smaller ones, and rewrites each one until it meets the definition of ready in `docs/planning.md`. Then it asks you to approve them.
- **"Which issues need my decision?"** The agent lists the issues with `needs-decision`, and the question on each. Tell it your answers.
- **"Fix the typo in the README's first sentence."**, or any other small change. The agent opens an issue and a pull request for it.
- **"Review pull request #12."** The agent compares the change with its issue and comments with what should change.
- **"Review the code for security problems."** The agent reviews the whole repository, unless you name a part of it or a range of changes, such as the changes since the last release. It tells you what it found and which parts it reviewed.

### Fix security problems

Issues and pull requests are public, so the agent keeps a security problem out of them until a release fixes it. It records the problem in a security advisory. `.github/SECURITY.md` asks people to report problems privately, and GitHub creates an advisory for each such report.

1. Ask the agent to fix the problem. It builds the fix in a temporary private fork that GitHub creates for the advisory.
2. Ask for a release. Ask right away if the problem's severity is high or critical, or if the problem is already public. If someone reported the problem, ask within 90 days of their report, because `.github/SECURITY.md` asks reporters to keep a problem private only that long. The agent asks whether the release should include each fix that's waiting in a private fork.
3. Once the checks pass, the agent merges the fix and publishes the release right away.
4. Start a new conversation, because an agent checks less carefully in the conversation where it published the release. In it, ask "Check the security advisories." The agent checks whether each problem is still in the released code, and looks closely at each fix, because a fix can be incomplete.
5. Ask the agent to publish only the advisories you're sure are fixed, and only once users can install the release, because a published advisory shows attackers where to look. If a workflow publishes a package for the release, users can install the package only once you've approved the workflow's run and the run has finished.

## Limits

- The template supports only public GitHub repositories that an organization owns. A repository made private, or moved to a personal account, after setup no longer works with the template.
- Codex runs the hooks only after you review them with `/hooks`.
- The hook for secret files checks only the commands on its list, such as `cat`, `grep` and `cp`. Another command can still read a `.env` file, and so can a script, or a command that doesn't name the file, such as `grep -r`.
- A repository made from the template doesn't get the template's later changes.
- People with GitHub's Triage role can add `ready`, so give that role only to people you'd let approve work.
- An agent merges the pull request for each ready issue and for each change you ask for, without anyone reviewing it. When it builds the ready issues, it also merges Dependabot's pull requests. If a change passes the tests, the linters, the type checker and the check of new dependencies, it merges, whatever else is wrong with it. Code scanning reports security problems, but it doesn't stop a merge.
- If your project is a library and its language has a tool that finds breaking changes, the setup adds a check that runs it. In any other project, nothing checks for them. So a release can miss a breaking change and raise the version number too little.
- Ask only one agent at a time to build a repository's ready issues, because two agents can take the same issue. That agent's helpers don't count, and they need an agent that can launch other agents.

## What you get

- `AGENTS.md`: the rules for agents and people, from making a change to publishing a release.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments, error messages, and replies and reports to you.
- `docs/pages.md`: how to organize a page and write a README, and how to check that a changed page reads clearly.
- `docs/rules.md`: how to change AGENTS.md, the guides and the labels.
- `docs/code.md`: how to write code in any language, covering design and tests.
- `docs/dependencies.md`: how to choose, pin and update tools, packages and GitHub Actions.
- `docs/languages.md`: how an agent gives each language in your project pinned versions, checks and Dependabot updates, at setup or when you add the language later.
- `docs/planning.md`: how an agent turns ideas into issues that are ready to build, and how you choose which ones get built.
- `docs/building.md`: how an agent builds the issues you approved, alone or with helpers.
- `docs/reviewing.md`: how an agent reviews a pull request, and reviews the code for security problems.
- `docs/releasing.md`: how an agent publishes a release, writes a workflow that publishes or deploys the project, checks the security advisories, and records and fixes a security problem that isn't public yet.
- `scripts/check`: runs the same checks on your machine and in CI.
- `scripts/configure-github`: applies the settings that GitHub doesn't copy from a template.
- `.github/`: CI, a check of each pull request's title and body, a weekly check that the rules for main still require CI and the title and body check before a merge, issue forms, a pull request template, weekly Dependabot updates, release notes settings, and the contributing and security pages.
- `scripts/hooks/`: hooks that block risky actions of the agent, such as reading a `.env` file or checking out a pull request from a fork.
- `.claude/settings.json`: runs the hooks in Claude Code, Copilot CLI and Cursor, and stops Claude Code from adding its name to commits and pull requests. It also lets Claude Code make files in `scripts/` executable without asking.
- `.codex/hooks.json`: has Codex run the hooks.

## License

[MIT](LICENSE)
