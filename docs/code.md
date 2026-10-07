# Code guide

Write code that a reader understands the first time they read it. If a rule here would make a piece of code harder to read, choose the clearer code and explain why in the pull request.

## Keep the design simple

- Build the simplest design that meets what the project needs now, including any accuracy or speed that the issue asks for.
- Add a layer, an option or a general version of something only when the project needs it now. For example, add a storage interface only once the project has a second storage backend, not in case it gets one.
- If you find dead code that your change didn't leave behind, open an issue to remove it rather than removing it in your change.
- Follow the conventions the code already uses for naming style, file layout and error handling, even where this guide would choose differently. To change a convention, open an issue for it, and change it everywhere in a pull request of its own.
- Keep each decision the code makes, such as a limit or how a total is rounded, in one place, so that changing it takes one edit. Before you write code that makes a decision, check whether other code already makes it, and use that code if it does. But two pieces of code or two values can look alike and still be separate decisions. Keep those apart. For example, if the limit on a description and the limit on a category name are both 50 characters, don't use one constant for both, because either limit can change without the other.
- Keep the code that calculates a result apart from the code that reads input or writes output. Pass every value that can differ from one run to the next, such as today's date, to the calculating code as an argument. The calculating code reads nothing but its arguments, and does nothing but return its result. Files, the network, the screen, the clock, random numbers and environment variables all count as input or output, so the calculating code leaves them to the code that calls it. For example, the function that totals this month's expenses takes the expenses and today's date as arguments and returns the total. The code that calls it reads the expense file and the clock, and prints the result.
- Fix the cause of a problem, not only the place where it shows up. For example, if listing expenses crashes on an expense without a category, change the code that reads expenses so that it gives that expense the category "none". Don't catch the crash in the code that prints the list.
- If the code you need to change is hard to change as it is, refactor it first, in a commit of its own. Refactor only the code your change touches, and leave it at least as easy to read as before.
- A refactoring must pass every test as the test stands. Don't change what a test checks to make it pass. If no test runs the code, write one before you refactor. If a test fails after the refactoring and you can't make it pass, undo the part of the refactoring that fails it, and open an issue that asks whether the test checks something the product needs.
- If fixing the cause, together with any refactoring that the fix needs, would make the pull request too big to review in one sitting, open an issue for the larger work. Mark the issue you're working on as blocked by it, as step 4 of "Make a change" in AGENTS.md describes.

## Write functions a reader can follow

- Give each function one purpose, and name it for that purpose.
- Return early instead of nesting conditions.
- Prefer a plain loop and named steps to a clever one-liner.
- Choose names that explain themselves, in whole words. Name a boolean as a yes-or-no question, such as `is_empty`.

## Add complexity only for a requirement or a measurement

Keep the complex code in one place behind a plain interface, so that the code that calls it doesn't need to know how it works.

- Complexity is required when a simpler version would fail a requirement. Examples are code that must reach the accuracy an issue asks for, and the fix for a reported bug. Name the requirement in a comment.
- Complexity is a choice when a simpler version already meets the requirements and the complex one does better, such as running faster, using less memory or giving more accurate results. Make that choice only where a measurement shows what the complex version gains. Say in a comment what the code gains and where the measurement is, such as a benchmark name or an issue.
- Keep tests that check the complex code's results. For speed or memory, keep a plain version in the test code, such as the code before you optimized it, and check that both give the same results. For accuracy, keep the test cases that measure it, so that a later change can't make the results worse without anyone noticing.

## Comment only what the code can't show

- A comment gives a reason, a hidden constraint or a surprise. It doesn't repeat what the code says.
- Make the code clearer before you add a comment. A better name or a smaller function often makes the comment unnecessary.

For example, in an expense tracker, this comment gives a reason that the code can't show: "Amounts are whole cents, because a fraction such as 0.10 can't be stored exactly, and the errors add up in a total."

## Fail with a clear error

- Check input where it enters the program: command-line arguments, files, network traffic and, in a library, the arguments to its public functions. Trust values that come from inside the program.
- Catch an error only where you can recover from it or add useful context. Never hide an error, such as by returning an empty list when the expense file can't be read.

## Test behavior

- Test what the code does through its public interface, not how it does it.
- In every test, check the result against what the requirement says: a fixed expected value, or a rule that must hold for every input, such as "reading a saved expense back gives the same expense". Don't take the expected value from the code's own output, and don't compute it the way the code does, because then the test repeats the code instead of checking it. The tests may still compare optimized code with a plain version of it, because the plain version computes the result another way.
- Test the edges of each requirement as well as a typical case: empty input, and the values on both sides of each limit, such as files of 50,000 and 50,001 rows.
- Write the test for a bug fix first, and run it to see it fail. Then fix the bug, and run the test again to see it pass.
- Name each test for the behavior and the condition, such as "leaves an expense in a foreign currency out of the total".
- Keep tests independent of anything that can differ from one run to the next, such as the network, the clock, random numbers and the order in which the tests run. Give the code fixed values or stand-ins for those only, and never a stand-in for the project's own code.
- Never weaken a test. You weaken a test when you change it so that it passes for code that made it fail before, while the requirement it checks stays the same. Skipping or deleting a test weakens it too. Delete a test only when your issue removes its requirement.
- When your issue changes a requirement, change the tests for it before you change the code. Take the new expected results from the issue, and run the tests to see them fail. Then change the code until they pass. If a test for any other requirement fails, fix the code, not the test.
- If you think a test is wrong, leave it as it is and open an issue for it.
- Say in the pull request which tests you changed or deleted, and why.
- Write code that works for every input, not only for the inputs in the tests. For example, don't return a fixed total when the amounts match the ones in a test.
- When the checks on pull requests take longer than the time limit under "Commands" in AGENTS.md, first make them faster without removing any test, such as by caching or by running tests in parallel. If they're still too slow, move the slow tests that check the product as a whole, such as end-to-end tests, into a separate command. Have CI run that command after each merge to main. Every other test stays in the checks on pull requests. If the checks are still too slow after that, open an issue that says so, and leave those tests where they are.
- If the project's coverage check fails on a line that no test runs, delete the line if the project doesn't need it. Otherwise, write a test that runs it. Mark the line as excluded from coverage only when no test can run it, such as code that runs only on another operating system, and say why in the marker.
- List in the pull request each exclusion marker that it adds.
