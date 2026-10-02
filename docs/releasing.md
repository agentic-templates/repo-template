# Release guide

This guide holds the steps for three kinds of work: publishing a release, checking the security advisories, and fixing a security vulnerability that isn't public yet. [AGENTS.md](../AGENTS.md) says when each one applies.

## Publish a release

When a maintainer asks you to publish a release:

1. On a private repository, skip this step. On a public repository, find out whether a fix that isn't released yet is waiting in a security advisory's private fork. Run `gh repo view --json viewerPermission`. If it doesn't show `ADMIN`, GitHub hides the advisories that aren't published from you, so ask the maintainer whether a fix is waiting. If it shows `ADMIN`, `gh api "repos/{owner}/{repo}/security-advisories"` lists the security advisories and private reports with their state. Take the ones that aren't published or closed. In each of them, `private_fork` holds the advisory's private fork, or `null` if the advisory has none. Check whether each private fork has a branch with commits that main doesn't have. If a fix is waiting, ask the maintainer whether this release should include it. If so, merge it first, as steps 2 and 3 in "Fix a security vulnerability on a public repository" describe. Once it's merged, go on to step 2 below, so that the SHA you release includes the fix.
2. After `git fetch`, `git rev-parse origin/main` gives the full SHA of main's latest commit. Check that the CI runs on that commit passed, and wait for any that are still running. `gh run list --commit <sha>` lists them. Ignore the "Dependabot Updates" runs, because they look for new versions and don't test the code. If one failed, stop and tell the maintainer. Also stop and tell the maintainer if code scanning has an open alert of high or critical severity, which `gh api --paginate "repos/{owner}/{repo}/code-scanning/alerts?state=open"` lists. Do the same if Dependabot has an open alert of high or critical severity, which `gh api "repos/{owner}/{repo}/dependabot/alerts?state=open&severity=high,critical"` lists. Keep using that SHA even if more pull requests merge while you wait.
3. Choose the version. `gh release list --exclude-drafts --limit 1` shows the latest release. `git log --format=%s <latest release>..<sha>` lists the titles of the pull requests merged since then. If it lists none, or only Dependabot's updates, tell the maintainer, because the release notes leave out Dependabot's updates and would be empty. If a title has `!` before its colon, raise the major version, or the minor version while the project's version is below 1.0. If no title has `!`, raise the minor version if a title starts with `feat`, and the patch version if none does. A first release is `v0.1.0`. If the maintainer named a version that doesn't fit, ask which one to publish.
4. Publish the release with notes built from the merged pull requests:
   `gh release create <version> --target <sha> --generate-notes`

   If the project attaches files to its releases, such as binaries, add `--draft`, so that the release gets its files before it's published. A draft doesn't start release workflows, so use `gh workflow run` to start the workflow that builds the files from `<sha>` and attaches them. Once the workflow has finished, publish the draft.
5. On a public repository, tell the maintainer about each security advisory or private report that isn't published or closed. They're the ones you took from the list in step 1. Without admin access, you have no such list, so tell the maintainer that an admin needs to check the advisories on the repository's "Security and quality" tab.
6. If you told the maintainer about any advisories in step 5, tell the maintainer to start a new session to check whether they're fixed, because an agent performs worse when its context also holds the work of publishing the release.

The repository's settings lock the tag and files of a published release, so fixing a mistake in them takes a new release. The release notes stay editable.

## Check the security advisories

When a maintainer asks you to check the security advisories, check them against the latest release:

1. List the advisories that aren't published or closed, as step 1 of "Publish a release" describes. Without admin access, you can't see them, so tell the maintainer that the check needs an admin's access.
2. For each advisory on that list, check whether its problem is still in the release. If the advisory's private fork holds a fix, check whether the release includes that fix, and check the fix closely, because a fix can be incomplete.
3. For each advisory on the list, tell the maintainer whether you're sure the release fixes it, and how you checked.
4. Publish an advisory only when the maintainer asks you to, and only once users can install the release that fixes it, because publishing shows attackers where the problem is:
   - If users install from the GitHub release, they can install it as soon as it's published.
   - If the project publishes a package or deploys, users can install the release once the workflow that does so has succeeded for it, which `gh run list` shows.
   - If that workflow hasn't succeeded, or you can't tell whether users can install the release, such as when an app store makes it available later, tell the maintainer and don't publish the advisory.

   Before you publish it, set the release's version as its fixed version, and the versions before it as affected. If the project publishes a package, also set the package's ecosystem and name, because GitHub alerts the projects that use a package only when the advisory names it.
5. Once an advisory is published, add a line to the release notes that links it.

## Fix a security vulnerability on a public repository

"Keep a security vulnerability private" in AGENTS.md says how to record a vulnerability that isn't public yet, and what its issue and pull request may say. On a public repository, fix it this way:

1. Build the fix in the advisory's temporary private fork, which an admin can create with `gh api --method POST repos/{owner}/{repo}/security-advisories/<ghsa_id>/forks`.
2. When the maintainer asks for a release that includes the fix, check that main meets step 2 of "Publish a release", so that nothing stops the release once the fix is public.
3. Push the fix to the repository, and open its issue and pull request. As soon as its checks pass, merge it.
4. Publish the release in the same session.
