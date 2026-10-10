# Release guide

The steps that list or check security advisories need admin access, which `gh repo view --json viewerPermission` shows as `ADMIN`. Without it, ask the maintainer to do them.

## Publish a release

When a maintainer asks you to publish a release:

1. Run `scripts/waiting-fixes`. It lists each security advisory that isn't published, closed or withdrawn, and prints a line for each branch of the advisory's private fork. For each line that says `holds a fix` or `can't tell`, ask the maintainer whether this release should include the fix that may wait there. If so, merge it first, as steps 2 and 3 in "Fix a security vulnerability" describe. Then go on to step 2 below, so that the SHA you release includes the fix.
2. Run `scripts/release-checks`. Its first line is the full SHA of main's latest commit, and its last line is `go`, `wait` or `stop`. While it prints `wait`, run `scripts/release-checks <sha>` with that SHA every minute, so that you keep the same SHA even if more pull requests merge. If it prints `stop`, stop and tell the maintainer what the lines before it say.
3. Choose the version with `scripts/next-version <sha>`. If the script prints an error instead of a version, tell the maintainer the error. If the maintainer named a version that differs from the one the script printed, ask which one to publish.
4. Publish the release with notes built from the merged pull requests:
   `gh release create <version> --target <sha> --generate-notes`

   If the project attaches files to its releases, such as binaries, add `--draft`. A draft doesn't start release workflows, so use `gh workflow run` to start the workflow that builds the files from `<sha>` and attaches them to the draft. Once that run has succeeded, publish the draft.

   If the release starts a workflow that waits for approval, such as one that publishes a package, tell the maintainer to approve it.
5. Tell the maintainer about each advisory that step 1 listed.
6. If you told the maintainer about any advisories in step 5, tell the maintainer to start a new session to check whether they're fixed, because an agent performs worse when its context also holds the work of publishing the release.

## Protect the credentials that publish and deploy

- Run the build in a job that can only read the repository. Give the credentials, or a token that can write, only to a separate job that uploads what the build made, so that code from the build's dependencies can't reach those credentials.
- In the `release` environment, run the job that publishes a package to a registry or deploys the project.
- Where the registry or host accepts GitHub's OpenID Connect login, such as PyPI's trusted publishing, use it. Tell the maintainer the exact steps to set it up on the registry or host.
- Where the registry or host doesn't accept that login, ask the maintainer to store the job's token as a secret of the `release` environment, not of the repository.

## Check the security advisories

When a maintainer asks you to check the security advisories, check them against the latest release:

1. Run `scripts/waiting-fixes <tag>`, with the latest release's tag, which `gh release view --json tagName --jq .tagName` prints. It lists the advisories as step 1 of "Publish a release" describes, but compares each branch of their private forks with the release instead of main.
2. For each advisory on that list, check whether its problem is still in the release. For a branch of its fork, `nothing waiting` means that the release has every change in the branch, and `holds a fix` means that the release lacks some. Check each fix closely too, because a fix can be incomplete.
3. For each advisory on the list, tell the maintainer whether you're sure the release fixes it, and how you checked.
4. Publish an advisory only when the maintainer asks you to, and only once users can install the release that fixes it, because publishing shows attackers where the problem is. If a workflow that publishes a package or deploys hasn't succeeded for the release, which `gh run list` shows, tell the maintainer and don't publish the advisory. Do the same if you can't tell whether users can install the release, such as when an app store makes it available later.

   Before you publish it, set the release's version as its fixed version, and the versions before it as affected. If the project publishes a package, also set the package's ecosystem and name.
5. Once an advisory is published, add a line to the release notes that links it.

## Record a vulnerability privately

As soon as you find a vulnerability that isn't public yet, write its summary and its description to two files outside the repository with your tool for writing files, not with a shell command. If you have admin access, open a draft security advisory with them: `gh api --method POST repos/{owner}/{repo}/security-advisories -F summary=@<summary file> -F description=@<description file> -f 'vulnerabilities[][package][ecosystem]=other'`. Without it, report it privately: `gh api --method POST repos/{owner}/{repo}/security-advisories/reports -F summary=@<summary file> -F description=@<description file>`.

## Fix a security vulnerability

1. Build the fix in the advisory's temporary private fork. If the advisory has no fork yet, an admin can create it with the commands below. GitHub copies each of the repository's branches into the fork, and step 1 of "Publish a release" would report a copy as a waiting fix. GitHub makes the copies after it creates the fork, so the commands wait until the fork has `main`, and then delete every other branch from the fork:

   ```bash
   fork=$(gh api --method POST "repos/{owner}/{repo}/security-advisories/<ghsa_id>/forks" --jq .full_name)
   until gh api --paginate "repos/$fork/branches" --jq '.[].name' | grep -qx main; do
     sleep 5
   done
   for branch in $(gh api --paginate "repos/$fork/branches" --jq '.[].name'); do
     if [ "$branch" != main ]; then
       gh api --method DELETE "repos/$fork/git/refs/heads/$branch" && echo "Deleted $branch"
     fi
   done
   ```
2. When the maintainer asks for a release that includes the fix, check that main meets step 2 of "Publish a release", so that nothing stops the release once the fix is public.
3. The fix's issue, pull request and commits say only what the change does, not what the vulnerability is. Push the fix to the repository, and open its issue and pull request. Go on to step 4 below only once the merge queue has merged it, so that the release includes the fix.
4. Publish the release in the same session.
