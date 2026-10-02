# Dependencies guide

This guide holds the rules for choosing, pinning and updating tools, packages and GitHub Actions.

## Pin versions

- When you add a tool or a dependency, use its newest stable version that is at least 7 days old. This project's Dependabot settings also wait 7 days before they take a new version.
- Record the exact version of every tool and package that the project installs. The language's version goes in its version file, such as `.python-version`. Packages go in a committed lockfile. A tool that the lockfile doesn't cover gets its version and checksum in the file that installs it, as `.github/workflows/ci.yml` does for shellcheck.
- Pin each GitHub Action to a full commit SHA, with its version in a comment. The repository's settings stop any workflow that uses an action without a commit SHA.
- Add a dependency only when it saves more work than it costs to review, update and secure. Prefer the standard library.
- Leave routine updates to Dependabot. When your change needs a new package, or a newer version of one, add or update it in the same pull request, and name each package you added or updated in the pull request's description. The lockfile changes that come with it, including updates to other packages, stay in that pull request too.
