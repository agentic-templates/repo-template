# Code guide

Write code that a reader understands the first time they read it. If a rule here would make a piece of code harder to read, choose the clearer code and explain why in the pull request.

## Keep the design simple

- Build the simplest design that works for what the project needs now.
- Add a layer, an option or a general version of something only when the project needs it now. For example, add a storage interface only once the project has a second storage backend, not in case it gets one.
- Delete the code that your change leaves unused. Don't commit commented-out code, because git keeps the history. If you find other dead code, open an issue to remove it rather than removing it in your change.
- When the problem needs complex code, such as a parser, put that code in one place behind a plain interface. The code that calls it shouldn't need to know how it works.
- Follow the conventions the code already uses for naming style, file layout and error handling, even where this guide would choose differently. To change a convention, open an issue for it, and change it everywhere in a pull request of its own.

## Write functions a reader can follow

- Give each function one purpose, and name it for that purpose.
- Return early instead of nesting conditions.
- Prefer a plain loop and named steps to a clever one-liner.
- Choose names that explain themselves, in whole words. Name a boolean as a yes-or-no question, such as `is_empty`.

## Make code fast only where a measurement shows the need

- Trade readability for speed only where a measurement shows the need.
- Keep the fast code behind a plain interface.
- Give the fast code a comment that says what it gains and where the measurement is, such as a benchmark name or an issue.
- Keep a plain version in the test code, such as the version from before you made it fast. Test that the fast version returns the same results.

## Comment only what the code can't show

- A comment gives a reason, a hidden constraint or a surprise. It doesn't repeat what the code says.
- Make the code clearer before you add a comment. A better name or a smaller function often makes the comment unnecessary.

For example, in a tool that moves duplicate photos to the trash, this comment gives a reason that the code can't show: "The trash cannot hold files from a network drive, so those copies are listed and left in place."

## Fail with a clear error

- Check input where it enters the program: command-line arguments, files and network responses. Trust values that come from inside the program.
- Catch an error only where you can recover from it or add useful context. Never hide an error.
- Write error messages as [docs/writing.md](writing.md#write-error-messages) describes. Each one says what failed and what the person who sees it can do about it.

## Test behavior

- Test what the code does through its public interface, not how it does it.
- Pair every bug fix with a test that fails without the fix.
- Name each test for the behavior and the condition, such as "leaves photos on a network drive in place".
- Keep tests independent of the network, the clock and the order in which they run.
- Keep `scripts/check` under five minutes in CI, because it runs on every pull request. If it takes longer, move the slowest tests, such as end-to-end tests, into a second script, such as `scripts/test-slow`, in a pull request of their own. List that script under "Commands" in AGENTS.md, because the steps for publishing a release run the slow tests listed there.

## Pin versions

- When you add a tool or a dependency, use its current stable version.
- Record the exact version of every tool and package that the project installs. The language's version goes in its version file, such as `.python-version`. Packages go in a committed lockfile. A tool that the lockfile doesn't cover gets its version and checksum in the file that installs it, as `.github/workflows/ci.yml` does for shellcheck.
- Pin each GitHub Action to a full commit SHA, with its version in a comment. The repository's settings stop any workflow that uses an action without a commit SHA.
- Add a dependency only when it saves more work than it costs to review, update and secure. Prefer the standard library.
- Update versions in pull requests of their own. Dependabot opens most of them. If your change needs a newer version of a package, update it in a separate pull request and merge that first. Adding a package is the one exception: the lockfile changes that come with it, including updates to other packages, stay in the pull request that adds it.
