# Building guide

This guide holds the steps for building the ready issues.

## Build the ready issues

When a maintainer asks you to build the ready issues, work through them without stopping to ask. The request also allows you to merge each pull request once the change is done and its checks pass. Don't wait for the checks: turn on auto-merge, and GitHub merges the pull request once they pass while you take the next issue. A maintainer starts a build run only when no other build run is going on the repository, so you don't need to check for another one.

If the maintainer asks for helpers, such as "with up to 3 helpers", and you can start agents that each work in their own clone or worktree, build several issues at once. Take and assign each issue as step 4 below describes, then give it to a helper, up to the number the maintainer asked for. Put "read `docs/building.md` first" in each helper's instructions, because a helper starts in a new session, which loads AGENTS.md but no guide. A helper uses the same model and effort as you. If the maintainer names another model, or an agent that the maintainer set up for helpers, the helper uses that instead. The helper follows the rest of step 4 below for that one issue, and step 5 below if it can't finish it. It tells you its pull request's number or why it stopped, and any problems it noticed outside its issue. If a helper fails without saying why, remove the assignment from its issue, so that another helper can try it. If that helper fails too, also add `needs-decision`, and comment on the issue that two helpers failed. You do the other steps below yourself, including step 2 for the helpers' pull requests.

1. Remove your assignment from each ready issue that's assigned to you and has no open pull request. For each open Dependabot pull request whose checks haven't failed, turn on auto-merge with `gh pr merge <number> --auto --squash`. `gh pr list --app dependabot` lists them.
2. Check each open pull request that has auto-merge turned on. Leave every pull request from a fork alone.
   - For one that closes a ready issue, if its `mergeStateStatus` is `BEHIND`, update it with `gh pr update-branch <number>`. If it's `DIRTY` or its checks failed, and you can still message the helper that built it, ask that helper to fix it. Leave the pull request alone until the helper reports, and count the helper toward the number the maintainer asked for. If no helper built it, or you can't message the one that did, resolve the conflicts with main, or fix the checks as step 4 of "Make a change" in AGENTS.md describes. If you find it `BLOCKED` after all its reported checks have passed, and again on your next pass through this step, it can't merge, so give its issue back as step 5 below describes.
   - For one of Dependabot's, if it's `BEHIND`, ask Dependabot to update it with `gh pr comment <number> --body "@dependabot rebase"`. If it's `DIRTY` or its checks failed, turn off its auto-merge with `gh pr merge <number> --disable-auto`, and leave it for the maintainer. Never fix or close Dependabot's pull requests.
3. List the ready issues with `gh issue list --label ready --limit 200 --json number,title,labels,assignees,blockedBy,subIssuesSummary`. The `blockedBy` field lists each blocking issue with its state, and `subIssuesSummary` counts the issue's sub-issues.
4. Take the lowest-numbered ready issue that has a type label, no status label, no assignee and no open sub-issues, and whose blocking issues are all closed. Assign it to yourself with `gh issue edit <issue> --add-assignee @me`, so that other agents skip it. Then check that it still has `ready`, because a maintainer may have asked another agent to work on it since you listed the ready issues. If it doesn't, remove your assignment and go back to step 2.
   - For a research issue, don't open a pull request. Answer its question in a comment, with the evidence and a recommendation. If you need to try code, do it outside the repository, and put the short parts that show the answer in the comment. Check each issue that the research issue blocks. If the answer changes what that issue asks for, add `needs-decision` to it and comment there with the decision it needs, so the maintainer decides before it's built. Then close the research issue.
   - For a parent whose sub-issues are all closed, don't build anything. Close it if its "Done when" is met, and give it back if it isn't.
   - For any other issue, make the change as "Make a change" in AGENTS.md describes, up to opening the pull request. Once the change meets the definition of done in AGENTS.md, apart from CI, turn on auto-merge with `gh pr merge <number> --auto --squash`.

   Then go back to step 2.
5. Give an issue back to the maintainer when you can't finish it, for example because it's unclear, against one of the rules in AGENTS.md or too big for one pull request, or because its pull request can't merge and you can't fix that. Comment on the issue with what you need, and remove your assignment with `gh issue edit <issue> --remove-assignee @me`. If it's too big, add `needs-breakdown`. Otherwise, if the issue is now blocked by another issue, add no status label, because a build run skips it until its blocking issues are closed. Otherwise, add `needs-decision`. If it has a pull request, close it with `gh pr close <number>`, and keep its branch.
6. When no issue is left that you can start, wait for your helpers, if you have any. Also wait for the checks of each open pull request that closes a ready issue and has auto-merge turned on, with `gh pr checks <number> --watch`. Then go back to step 2. Once no such pull request is open, no helper is working and no issue is left that you can start, report to the maintainer:
   - the pull requests that merged
   - the issues that have the `needs-decision` label
   - the ready issues that are still open, and what each one waits for
   - the issues you opened on your own, for problems you noticed
   - the security vulnerabilities you noticed
   - the open code scanning alerts, which `gh api --paginate "repos/{owner}/{repo}/code-scanning/alerts?state=open"` lists
   - the Dependabot pull requests you didn't merge
   - whether the latest CI run on main passed, failed or is still running
   - anything a maintainer needs to run, such as `scripts/configure-github`
