# How to work in this repository

This repository is repo-template, a starting point for new projects.

These rules apply to every coding agent and every person who changes the repository. In them, the owner is the person who has admin access to the repository and decides what happens to it. If a rule conflicts with what the owner asks for, point out the conflict and ask before you break the rule.

## Where things are

- `README.md`: what the project does, how to set it up, and an example.
- `AGENTS.md`: these rules.
- `docs/writing.md`: how to write docs, issues, pull requests, commit messages, comments and error messages.
- `docs/code.md`: how to write code.
- `scripts/check`: runs the checks that CI runs on the code.
- `scripts/configure-github`: applies the repository's settings on GitHub.
- `.github/`: the CI workflows, issue forms, pull request template, Dependabot and release note settings, and the contributing and security pages.
- `.claude/settings.json`: settings that stop Claude Code from adding attribution to commits and pull requests, and from reading `.env` files.

## Commands

- `scripts/check`: run it before you push. CI runs the same script and also checks the pull request title.
- `scripts/configure-github`: the owner runs it after creating the repository on GitHub, and again whenever the script changes. It needs admin access.

The project has no slow tests yet. When it has some, list their command here. CI doesn't run slow tests, so run them before each release.

The `gh` commands in these rules need gh 2.98 or later. If `gh --version` shows an older version, stop and tell the owner.

## Write text and code

Read both guides before you write or review anything in a session:

- [docs/writing.md](docs/writing.md) covers all text: docs, issues, pull requests, commit messages, comments and error messages.
- [docs/code.md](docs/code.md) covers all code.

## Labels

Use only these labels. To add, rename or remove one, change this section and `scripts/configure-github` in the same pull request.

Every issue has exactly one type label. Choose it by what users notice:

- `bug`: something is broken, such as a crash, a wrong result or docs that don't match the product.
- `feature`: new or changed behavior or docs that users notice, other than a fix. The pieces of a split feature are features too.
- `maintenance`: work that users don't notice, such as refactoring, tooling, tests or CI.
- `research`: a question to answer before anyone builds. It ends in a comment, not in code.

A status label says what an issue is waiting for. An issue that's ready to build has none:

- `needs-triage`: the owner hasn't accepted or rejected it yet. The issue forms add it. An agent adds it to every issue it opens on its own, for something it noticed. Issues the owner asks for don't get it, including the ones created while planning a release.
- `needs-breakdown`: accepted, but too big for one pull request. While planning a release, split it into sub-issues with `gh issue create --parent <issue>`, then remove the label. The original stays open as their parent and closes when they're all closed.
- `needs-decision`: waiting for the owner to answer a question or make a decision. Remove it once the owner has answered, on the issue or in the conversation.

Triage is the owner's decision. An agent carries it out when the owner says so, and asking an agent to work on an issue accepts it. To accept an issue, remove `needs-triage` and make sure it has a type label. To reject one, comment why and close it with `gh issue close <issue> --reason "not planned"`. To close a duplicate, use `gh issue close <issue> --duplicate-of <other issue>`.

Dependabot adds `dependencies` to its pull requests. Pull requests get no other labels.

## Make a change

Every change goes through an issue, a branch and a pull request. Dependabot's pull requests are the only exception. They skip the issue, because each one already says what it updates.

1. Start from an issue. If there is none, open one with `gh issue create`. Write its body under three headings, as the form in `.github/ISSUE_TEMPLATE/change.yml` does: "What should change", "Why" and "Done when". Make "Done when" a list of results that someone can check. Give it one type label, as "Labels" describes. If the owner asks you to work on an issue that has `needs-triage`, remove that label, because the request accepts the issue.
2. Create a branch for the issue with `gh issue develop <issue> --checkout`. GitHub creates the branch from the latest main and links it to the issue. If the issue already has a branch, check out that branch instead.
3. Before you edit a file, read every AGENTS.md from the root down to the file's own folder. Where they differ, the one closest to the file wins.
4. Before you commit, check that `git config user.email` is a GitHub noreply address, because every commit records it and the repository is public. If it isn't, stop and tell the owner.
5. Make the change in small commits. Run `scripts/check` and fix every failure that your change causes. A failure that also happens on main isn't yours, and neither is any other problem you notice outside your issue. Open an issue for each one, with `needs-triage` and the type that fits, unless one is open already. If your change can't pass without that fix, mark your issue as blocked by it with `gh issue edit <issue> --add-blocked-by <other issue>`. Then tell the owner.
6. Push the branch and open a pull request with `gh pr create`.
7. Wait for the checks with `gh pr checks --watch`. If it reports that no checks exist yet, wait a few seconds and run it again. Fix each failure as step 5 describes.
8. Merge only when the owner has asked you to, either for this pull request or for a whole milestone. Merge with `gh pr merge --squash`.

## Commits

- Make each commit a small working change that can be reviewed on its own.
- Write the subject as `<type>: <what changed>` in plain words. Describe the change as a user or developer would notice it, not how it was built.
  - Not `feat: switch dedupe to perceptual dHash with a Hamming threshold of 10`
  - But `feat: group photos that were resized or saved in another format`
  - For a change that only developers notice: `refactor: keep all photo comparison code in one module`
- Use one of these types:
  - `feat`: new behavior
  - `fix`: a bug fix
  - `docs`: documentation only
  - `test`: tests only
  - `refactor`: a code change that keeps behavior the same
  - `perf`: a change that makes the code faster or use less memory
  - `build`: the toolchain, dependencies or packaging
  - `ci`: the CI workflows
  - `revert`: undoes an earlier commit
  - `chore`: anything else
- A scope is optional, as in `fix(cli): ...`. Add `!` before the colon when the change breaks existing use.
- Add a body only to explain why, when the subject and the diff don't show it.
- Don't add a `Co-Authored-By` trailer or any other attribution to commits or pull requests.

## Pull requests

- Keep each pull request to one issue, and small enough to review in one sitting.
- The title follows the rules for a commit subject, because it becomes the commit subject on main. CI checks its format.
- The body has the three parts of `.github/pull_request_template.md`: `Closes #<issue>`, what changed and why, and how you checked it. If a test covers the change but you didn't run it, such as a slow test, say so and say why.
- If the pull request changes `scripts/configure-github`, say in its description that the owner needs to run the script after the merge.

## Definition of done

A change is done when all of these are true:

- It meets every item in the issue's "Done when" list, and it adds nothing the issue didn't ask for.
- `scripts/check` passes on your machine and in CI.
- New behavior has tests. A bug fix has a test that fails without the fix.
- The docs match the change: README, AGENTS.md, help text and comments.
- Nothing is left behind: no dead code, debug output, commented-out code, or TODO without an issue number.
- A new or rewritten README or docs page has had a fresh-reader review, as `docs/writing.md` describes.
- The pull request links its issue and says how the change was checked.

## Review a pull request

- Compare the change with its issue's "Done when" list and the definition of done.
- Report only what needs to change: wrong behavior, a missing test, a security problem, or text and code that break the guides. For each one, say what to change and why.
- Don't ask for changes that a formatter would make, or for work outside the issue.
- Post the review as a comment on the pull request, with `gh pr review <number> --comment --body "<review>"`.

## Plan a release

A release is a milestone of issues. Plan the whole release before anyone builds it, so that an agent can build it in one run.

1. Agree on the goal with the owner: what a user can do after the release that they can't do now.
2. Choose the version, such as `v0.2.0`. It also names the milestone, and the commands below show it as `<version>`. Versions follow semantic versioning: raise the patch number for a release with only fixes, the minor number for new features, and the major number for a change that breaks existing use. Before version 1.0, a breaking change raises the minor number instead.
3. Create the milestone. `gh` fills in `{owner}` and `{repo}`:
   `gh api repos/{owner}/{repo}/milestones -f title=<version> -f description="<goal>"`
4. Split the goal into issues. Each issue fits in one pull request and leaves main working when it merges. Its body has the three headings from "Make a change". Write it for a builder who has read nothing but the issue and the code.
5. Create the issues in the order they should be built, because the builder takes the lowest-numbered issue first. Use `gh issue create --milestone <version> --label <type>`. If an issue needs another issue's change first, add `--blocked-by <other issue>`.
6. Ask the owner to review the milestone before anyone builds it.

## Build a milestone

When the owner asks you to build a milestone, work through its issues without stopping to ask. The request also allows you to merge each pull request once the change is done and its checks pass. If an issue would make you break one of these rules, handle it as step 5 below describes.

1. Merge each open Dependabot pull request whose checks have passed. `gh pr list --app dependabot` lists them. Leave the others for the owner.
2. List the milestone's open issues with `gh issue list --milestone <version> --json number,title,labels,blockedBy,subIssuesSummary`. The `blockedBy` field lists each blocking issue with its state, and `subIssuesSummary` counts the issue's sub-issues.
3. Take the lowest-numbered issue that has a type label, no status label and no open sub-issues, and whose blocking issues are all closed. Make the change as "Make a change" describes, and merge the pull request once the change meets the definition of done and its checks pass. Close a parent issue once all its sub-issues are closed.
4. If the issue has the `research` label, don't open a pull request. Answer its question in a comment, with the evidence and a recommendation. If you need to try code, do it outside the repository, and put the short parts that show the answer in the comment. If the answer fits what the issues it blocks ask for, close it. If it changes what they ask for, add `needs-decision` instead, so the owner decides before they're built.
5. If the issue is unclear or against one of these rules, or its checks fail because of your change and you can't fix them, stop working on it. Comment on the issue with what you need and add `needs-decision`. If it's too big for one pull request, add `needs-breakdown` instead. If it has a pull request, leave that open.
6. Go back to step 2. When no issue is left that you can build, report to the owner:
   - the pull requests that merged
   - the issues that have the `needs-decision` label
   - the issues you skipped because they have a status label or no type label, and the issues they block
   - the issues you opened for failures that your changes didn't cause
   - the Dependabot pull requests you didn't merge
   - anything the owner needs to run, such as `scripts/configure-github`

## Publish a release

When the owner asks you to publish a release:

1. Check that every issue in the milestone is closed. If some are open, stop and tell the owner, who can resolve them or move them to a later milestone.
2. Check that the version still fits the merged work. A new feature needs at least a minor release, and a breaking change needs a major one, or a minor one before version 1.0. If the version doesn't fit, ask the owner which version to publish.
3. Run the slow tests listed under "Commands", if there are any. If one fails, stop and tell the owner.
4. Publish the release with notes built from the merged pull requests:
   `gh release create <version> --target main --generate-notes`
5. Close the milestone. `gh api repos/{owner}/{repo}/milestones` shows its number:
   `gh api -X PATCH repos/{owner}/{repo}/milestones/<number> -f state=closed`

The repository's settings lock the tag and files of a published release, so fixing a mistake takes a new release.

## Keep the repository clean

The repository holds the product and the rules for building it. Everything in it, and in its issues and pull requests, is public.

- Put plans in issues and milestones, the reason for a change in its pull request, and review comments on the pull request.
- Don't commit plans, notes, session logs, TODO lists or review records. An old plan in the repository misleads readers and agents, who take it as current. Keep working files outside the repository.
- Never read, print or commit secrets. Keep them in `.env`, which git ignores, and list each variable in `.env.example` with a placeholder value.
- Keep personal email addresses, local paths, private links and internal ticket numbers out of files, commits, issues and pull requests.

## Change these rules

- Inside the repository, instructions for agents live in AGENTS.md files and the two guides in `docs/`. Put a writing or code rule in the matching guide, and a rule for one folder in an AGENTS.md in that folder. Don't add instruction files for one tool, such as `.cursorrules` or `.github/copilot-instructions.md`.
- Don't create a `CLAUDE.md` or `CLAUDE.local.md` in the repository or in any folder above it, such as your home folder. When Claude Code finds one there, it reads that file and ignores AGENTS.md. If you find one, tell the owner. Personal instructions in `~/.claude/CLAUDE.md` are fine, because that folder isn't above the repository.
- Add a rule only when the same mistake keeps happening and no check or setting can prevent it. Keep the rules that explain what a check expects. Remove a rule once it no longer applies.
