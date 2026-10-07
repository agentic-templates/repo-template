# Languages guide

This guide holds the steps for adding a language to the project, at setup or later.

## Add a language

1. Pin the version of the language and of each framework and database that the code in the language uses, such as Python in `.python-version`. Commit the lockfile for the language's packages, and add steps to `.github/workflows/ci.yml` that install those versions and the packages.
2. Add the formatter, the linter, the type checker if the language has one, and the tests to `scripts/check`.
3. Add a hook to `.claude/settings.json` and `.codex/hooks.json` that runs the formatter on each file in the language that the agent edits.
4. If the language's coverage tool can mark single lines as excluded, add a coverage check to `scripts/check`. The check fails when a line never runs in a test. Where the tool measures branches, the check also fails when a branch is never taken. Lines marked as excluded don't count, but the check fails on an exclusion marker that gives no reason. Measure coverage with the tests that `scripts/check` runs, and with no others. If the tool can't mark lines as excluded, add no coverage check.
5. If the project publishes a library in the language, and the language has a tool that finds breaking changes, such as cargo-semver-checks for Rust, add a check to CI that looks for a break in the library's public interface. If a pull request breaks the interface, the check fails, unless the pull request's title marks the change with `!` before the colon, as in `feat!: rename the import command`. Have the check compare the pull request with the commit on main that it branched from, not with the last release. Once a breaking change has merged, main itself differs from the last release, so a comparison with that release would fail every later pull request.
6. Add the language's package manager, such as pip or npm, to `.github/dependabot.yml`, so that Dependabot updates its packages too.
7. Update the "Where things are" and "Commands" sections in `AGENTS.md` with the language's files and its install, run and test commands.
