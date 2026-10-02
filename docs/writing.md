# Writing guide

This guide covers everything written for the project: docs, issues, pull requests, commit messages, code comments and error messages. It applies to people and agents alike. The aim is text that a reader understands the first time they read it. The examples use a made-up expense tracker. [docs/pages.md](pages.md) adds the rules for the README and docs pages.

## Know your reader

- Write for a reader who is new to the project but not to its field, and who reads once. For someone who uses the project, the field is the kind of work it helps with, such as keeping track of spending. For a developer, the field also includes the project's language and tools.
- Leave out what the reader already knows and what the code already shows.
- Start with what the reader came for: what they can do, what changed or what went wrong.

## Use plain words

- Use everyday words for the actual action. Write "adds the expense to the month's total", not "processes the expense".
- Replace vague verbs such as "handles", "deals with" and "manages" with the verb for what happens.
- Keep a technical term only when it is the precise name for the thing. Explain it where it first appears, unless people in the reader's field use it every day.
- Use one term for one thing, everywhere. Don't switch to a synonym for variety.
- Don't use metaphors or marketing words such as "seamless", "powerful" or "blazing fast".
- Cut filler such as "simply", "just", "basically" and "note that".
- When you give a single example, pick the case that applies to most readers, because readers take it for the main case.
- Replace a vague judgment with the fact behind it. Write "imports 10,000 expenses in 2 seconds", not "fast".

For example, in a README for people who use an expense tracker:

- Not "The import pass hashes each row and drops collisions."
- But "When you import a file, the app skips the expenses it already has."
- Not "The app handles foreign currencies differently."
- But "The app leaves expenses in a foreign currency out of the total and lists them below it."

## Write clear sentences

- Put one idea in each sentence. "The app totals the expenses for each month, and it can export them as a spreadsheet" holds two ideas, so it becomes two sentences.
- Keep the words that link ideas, such as "because", "so", "but" and "unless". "The app leaves an expense in a foreign currency out of the total, because it doesn't know the exchange rate" is one idea with its reason. Being concise means cutting what the reader doesn't need, never the reasoning.
- Don't use semicolons in prose. Don't join two sentences with a dash either. Write two sentences.
- Say who does what. Write "The app deletes the expense", not "The expense is deleted". Leave out the actor only when it is unknown or doesn't matter.
- In a step the reader follows, put the condition first: "If the command reports that the disk is full, free at least 2 GB and run it again."
- Use the present tense for what the software does.
- Give exact numbers with their units, and exact names, commands and paths.

## Claim only what is true

- Claim only what the project delivers today. Never invent results, demos, benchmarks, users or quotes.
- In docs and READMEs, mention planned work only when an open issue with the `ready` label describes it, and link to that issue.
- State what the project can't do, not only what it can.
- Say only what you verified. If you didn't run a check, don't say that it passed.

## Write error messages

An error message says what failed and what the reader can do about it. When a limit or rule was broken, the message names it and includes the value that broke it.

- Not "Invalid file."
- But "bank.csv has 60,000 rows, and the limit is 50,000. Split it into two files and try again."
- Not "Error: ENOENT"
- But "Can't find the file ~/Downloads/bank.csv. Check the path, or choose another file with --file."

## Write issues, pull requests and commit messages

- Write for a reader who hasn't seen your conversation, notes or session. Don't refer to any of them.
- A pull request is the lasting record of a change. Write it for a developer who joins the project later, not only for today's reviewer. Say what changed and why. Don't list the changed files, because the diff shows them.
- Say how you checked the change: the checks you ran and what they showed. That includes the review described under "Review a changed page with a fresh reader" in [docs/pages.md](pages.md). Name any check from AGENTS.md that you skipped, and say why.
- A commit message follows the rules in [AGENTS.md](../AGENTS.md#commits).
