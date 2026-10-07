# Release guide

This guide holds the steps for publishing a release and checking the security advisories, the steps for recording and fixing a security vulnerability that isn't public yet, and the rules for a workflow that publishes or deploys the project. [AGENTS.md](../AGENTS.md) says when each one applies.

The steps that list or check security advisories need admin access, which `gh repo view --json viewerPermission` shows as `ADMIN`. Without it, ask the maintainer to do them.

## Publish a release

When a maintainer asks you to publish a release:

1. Check whether a fix that isn't released yet is waiting in a security advisory's private fork. List the advisories with `gh api "repos/{owner}/{repo}/security-advisories"`. For each one that isn't published or closed, check whether its `private_fork` has commits that main doesn't have. If a fix is waiting, ask the maintainer whether this release should include it. If so, merge it first, as steps 2 and 3 in "Fix a security vulnerability" describe. Then go on to step 2 below, so that the SHA you release includes the fix.
2. After `git fetch`, `git rev-parse origin/main` gives the full SHA of main's latest commit. Check that the CI runs on that commit passed, and wait for any that are still running. `gh run list --commit <sha>` lists them. Ignore the "Dependabot Updates" runs. If one failed, stop and tell the maintainer. Also stop and tell the maintainer if code scanning has an open alert of high or critical severity, which `gh api --paginate "repos/{owner}/{repo}/code-scanning/alerts?state=open"` lists. Do the same if Dependabot has an open alert of high or critical severity, which `gh api "repos/{owner}/{repo}/dependabot/alerts?state=open&severity=high,critical"` lists. Keep using that SHA even if more pull requests merge while you wait.
3. Choose the version. `gh release list --exclude-drafts --limit 1` shows the latest release. `git log --format=%s <latest release>..<sha>` lists the titles of the pull requests merged since then. If it lists none, or only Dependabot's updates, stop and tell the maintainer. If a title has `!` before its colon, raise the major version, or the minor version while the project's version is below 1.0. If no title has `!`, raise the minor version if a title starts with `feat`, and the patch version if none does. A first release is `v0.1.0`. If the maintainer named a version that doesn't fit, ask which one to publish.
4. Publish the release with notes built from the merged pull requests:
   `gh release create <version> --target <sha> --generate-notes`

   If the project attaches files to its releases, such as binaries, add `--draft`. A draft doesn't start release workflows, so use `gh workflow run` to start the workflow that builds the files from `<sha>` and attaches them to the draft. Once that run has succeeded, publish the draft.

   If the release starts a workflow that waits for approval, such as one that publishes a package, tell the maintainer to approve it.
5. Tell the maintainer about each advisory from step 1 that isn't published or closed.
6. If you told the maintainer about any advisories in step 5, tell the maintainer to start a new session to check whether they're fixed, because an agent performs worse when its context also holds the work of publishing the release.

Fixing a mistake in a published release's tag or files takes a new release, but its notes stay editable.

## Protect the credentials that publish and deploy

- Run the build in a job that can only read the repository. Give the credentials, or a token that can write, only to a separate job that uploads what the build made, so that code from the build's dependencies can't reach those credentials.
- In the `release` environment, run the job that publishes a package to a registry or deploys the project. `scripts/configure-github` sets it up so that only release tags can use it, and each run waits for the maintainer's approval.
- Where the registry or host accepts GitHub's OpenID Connect login, such as PyPI's trusted publishing, use it. Tell the maintainer the exact steps to set it up on the registry or host.
- Where the registry or host doesn't accept that login, ask the maintainer to store the job's token as a secret of the `release` environment, not of the repository.

## Check the security advisories

When a maintainer asks you to check the security advisories, check them against the latest release:

1. List the advisories that aren't published or closed, as step 1 of "Publish a release" describes.
2. For each advisory on that list, check whether its problem is still in the release. If the advisory's private fork holds a fix, check whether the release includes that fix, and check the fix closely, because a fix can be incomplete.
3. For each advisory on the list, tell the maintainer whether you're sure the release fixes it, and how you checked.
4. Publish an advisory only when the maintainer asks you to, and only once users can install the release that fixes it, because publishing shows attackers where the problem is. If a workflow that publishes a package or deploys hasn't succeeded for the release, which `gh run list` shows, or you can't tell whether users can install it, such as when an app store makes it available later, tell the maintainer and don't publish the advisory.

   Before you publish it, set the release's version as its fixed version, and the versions before it as affected. If the project publishes a package, also set the package's ecosystem and name.
5. Once an advisory is published, add a line to the release notes that links it.

## Record a vulnerability privately

As soon as you find a vulnerability that isn't public yet, open a draft security advisory if you have admin access: `gh api --method POST repos/{owner}/{repo}/security-advisories -f summary="<summary>" -f description="<description>" -f 'vulnerabilities[][package][ecosystem]=other'`. Without it, report it privately: `gh api --method POST repos/{owner}/{repo}/security-advisories/reports -f summary="<summary>" -f description="<description>"`.

## Fix a security vulnerability

1. Build the fix in the advisory's temporary private fork, which an admin can create with `gh api --method POST repos/{owner}/{repo}/security-advisories/<ghsa_id>/forks`.
2. When the maintainer asks for a release that includes the fix, check that main meets step 2 of "Publish a release", so that nothing stops the release once the fix is public.
3. Push the fix to the repository, and open its issue and pull request. As soon as its checks pass, merge it.
4. Publish the release in the same session.
