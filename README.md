# repo-template

Start a GitHub project that coding agents plan, build and release, while you make only the decisions that need a person. Every change goes from an issue to a pull request, which merges without a review once its checks pass. You approve the issues that agents build by labeling them `ready`, or ask an agent for a change yourself. Agents label only the bugs they reproduce `ready` themselves.

It works with any language, in Claude Code and Codex.

## Start a project

You need:

- The GitHub CLI 2.98 or later, signed in with `gh auth login`.
- bash, which macOS and Linux include. On Windows, use Git Bash or WSL.
- [jq](https://jqlang.org/download/). Without it, the hooks let every action through.
- Claude Code 2.1.281 or later, if you use it. Earlier versions don't always read `AGENTS.md`.

Optional: to keep your email address out of public commits, set git's `user.email` to your GitHub noreply address.

1. If you don't have a GitHub organization, create one at https://github.com/account/organizations/new. The template merges through GitHub's merge queue, which only an organization's repositories have.
2. Create a public repository from the template, and go into its clone:

   ```bash
   gh repo create <organization>/expense-tracker --public --template agentic-templates/repo-template --clone
   cd expense-tracker
   ```

3. Start your agent there, and ask it to set up the project, with any notes or spec you have: "Set up this repository for expense-tracker, a command-line tool in Python that records what you spend. Follow the setup list in README.md."

   <details>
   <summary>The setup list, for your agent</summary>

   - Run `gh api "repos/{owner}/{repo}/rulesets?includes_parents=false"` as written, because gh fills in the owner and the repository. If it lists no ruleset named `main`, run `scripts/configure-github` before you open the setup's pull request. If the script fails, stop the setup and pass its error on. When it finishes, ask the person to turn on Dependabot malware alerts at the link it prints.
   - In `AGENTS.md`, rewrite "What this project is": what the project is for, and which changes belong in it. Under "Commands", add the commands that aren't tied to one language, such as one that starts the project's database.
   - For each language the project uses, follow `docs/languages.md`.
   - If the project's output is visual, such as a web page, add a command that saves a picture of it outside the repository, and that runs without anyone at the screen. List it under "Commands".
   - If the project publishes a package or deploys, add a workflow that does it when a release is published.
   - Set the year and the copyright holder in `LICENSE`.
   - Last, replace this README with one for the project, as `docs/pages.md` describes. Until the project can do something, it says what the project is for, and that it can't do anything yet.

   </details>

   The setup replaces this README. [The template's README](https://github.com/agentic-templates/repo-template#from-idea-to-first-release) stays online.

## From idea to first release

Each request can start a new conversation.

1. **"Plan the first version of expense-tracker: it adds an expense, lists the expenses and shows the total for each month."** Include your notes or spec again. It splits the work into issues of one pull request each, linked to the issues they need first. Correct them, and say which ones you approve.
2. **"Build the ready issues."** The agent builds several at once with helper agents, each as soon as its blocking issues close, and fixes each pull request that fails its checks or conflicts with main until it merges. When it can't finish an issue without you, it asks, and the next build run builds that issue once you answer. To change how many helpers work and how, add "with up to 3 helpers", "without helpers", "on Opus", or "using build-helper", where build-helper is a [Claude Code subagent](https://code.claude.com/docs/en/sub-agents) that sets their effort.
3. **"Publish a release."** The agent checks that CI passed on main and that no alert of high or critical severity is open. It publishes the next semantic version with notes from the merged pull requests. GitHub asks you to approve each run of a workflow that publishes a package or deploys. Then it lists any security advisories you haven't published, which "Fix security problems" covers.

## Everyday requests

For later versions, use the same three requests, and these:

- **"Triage these ideas:"**, followed by the text or a link. The agent opens issues for the ideas it accepts, and asks you about the rest.
- **"Triage the new issues."** The agent accepts the bugs it can reproduce, closes duplicates, and asks you about the rest.
- **"Make #14 ready to build."** The agent splits or rewrites the issue, and asks you to approve it.
- **"Which issues need my decision?"**
- **"Fix the typo in the README's first sentence."**, or any other small change. The agent sees its pull request through to the merge.
- **"Fix the pull requests that didn't merge."**
- **"Review pull request #12."**
- **"Review the code for security problems."**

## Fix security problems

Issues and pull requests are public, so the agent keeps a security problem in a private security advisory, where private reports also land, until a release fixes it.

1. Ask the agent to fix the problem. It builds the fix in the advisory's temporary private fork.
2. Ask for a release right away if the severity is high or critical, or if the problem is public. Otherwise, ask within 90 days of a report, as `.github/SECURITY.md` promises reporters. The agent asks whether to include each fix that waits in a private fork.
3. In a new conversation, ask "Check the security advisories." The agent checks each fix in the release more carefully than the conversation that published it.
4. Ask the agent to publish only the advisories you're sure are fixed, and only once users can install the release, because a published advisory shows attackers where to look. A package is installable only after you approve its workflow's run and the run finishes.

## Limits

- The template works only in a public repository that an organization owns, because GitHub's merge queue and code scanning are free only there.
- Codex runs the hooks only after you review them with `/hooks`.
- The hooks check only the commands on their lists, so a script or another command can still read a secret file such as `.env`, or get the GitHub token from gh or git. [Claude Code's sandbox doesn't stop this on macOS](https://github.com/agentic-templates/repo-template/issues/427#issuecomment-6160078401). To keep secrets out of an agent's reach, run it in a separate user account or virtual machine that holds only a token for the project's repository.
- A repository made from the template doesn't get the template's later changes.
- A workflow removes a `ready` label that someone without write access adds, but a build run can take the issue first. People with GitHub's Triage role can add it, so give that role only to people you'd let approve work.
- Nobody reviews what merges. Agents merge their own pull requests, and in a build run Dependabot's, once the checks and code scanning pass. Code scanning blocks only a high or critical security alert, or a CodeQL error, in the changed lines, and never Dependabot's pull requests.
- Only a library whose language has a tool that finds breaking changes gets a check for them. In other projects, a release can miss a breaking change and raise the version too little.
- Ask only one agent at a time to build the ready issues, because two can take the same issue.

## What you get

`AGENTS.md` and its guides in `docs/` hold the rules, `scripts/check` runs the checks locally and in CI, and the hooks in `scripts/hooks/` block an agent's risky actions, such as reading `.env`.

## License

[MIT](LICENSE)
