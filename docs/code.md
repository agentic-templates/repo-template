# Code guide

Write code that a reader understands the first time they read it. If a rule here would make a piece of code harder to read, choose the clearer code and explain why in the pull request.

## Keep the design simple

- Build the simplest design that meets what the project needs now, including any accuracy or speed that the issue asks for.
- Add a layer, an option or a general version of something only when the project needs it now. For example, add a storage interface only once the project has a second storage backend, not in case it gets one.
- Delete the code that your change leaves unused. Don't commit commented-out code, because git keeps the history. If you find other dead code, open an issue to remove it rather than removing it in your change.
- Follow the conventions the code already uses for naming style, file layout and error handling, even where this guide would choose differently. To change a convention, open an issue for it, and change it everywhere in a pull request of its own.

## Write functions a reader can follow

- Give each function one purpose, and name it for that purpose.
- Return early instead of nesting conditions.
- Prefer a plain loop and named steps to a clever one-liner.
- Choose names that explain themselves, in whole words. Name a boolean as a yes-or-no question, such as `is_empty`.

## Add complexity only for a requirement or a measurement

Some code has to be complex, and some complexity is a choice. Either way, keep the complex code in one place behind a plain interface, so that the code that calls it doesn't need to know how it works.

- Complexity is required when a simpler version would fail a requirement. Examples are a parser, a matching method that must reach the accuracy an issue asks for, and the handling for a reported bug. Name the requirement in a comment.
- Complexity is a choice when a simpler version already meets the requirements and the complex one does better, such as running faster, using less memory or giving more accurate results. Make that choice only where a measurement shows the need. Say in a comment what the code gains and where the measurement is, such as a benchmark name or an issue.
- Keep the tests that show the complexity is worth it. For speed or memory, keep a plain version in the test code, such as the code before you optimized it, and check that both give the same results. For accuracy, keep the test cases that measure it, so that a later change can't make the results worse without anyone noticing.

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
- When the checks on pull requests take longer than "Commands" in AGENTS.md says they should, first make them faster without removing any test, such as by caching or by running tests in parallel. If they're still too slow, move only the slow tests that check the product as a whole, such as end-to-end tests, into a separate command, such as a script. Have CI run that command after each merge to main, and list it under "Commands", so that CI and people run the same tests.

## Pin versions

- When you add a tool or a dependency, use its newest stable version that is at least 7 days old, as Dependabot does.
- Record the exact version of every tool and package that the project installs. The language's version goes in its version file, such as `.python-version`. Packages go in a committed lockfile. A tool that the lockfile doesn't cover gets its version and checksum in the file that installs it, as `.github/workflows/ci.yml` does for shellcheck.
- Pin each GitHub Action to a full commit SHA, with its version in a comment. The repository's settings stop any workflow that uses an action without a commit SHA.
- Add a dependency only when it saves more work than it costs to review, update and secure. Prefer the standard library.
- Update versions in pull requests of their own. Dependabot opens most of them. If your change needs a newer version of a package, update it in a separate pull request and merge that first. Adding a package is the one exception: the lockfile changes that come with it, including updates to other packages, stay in the pull request that adds it.
