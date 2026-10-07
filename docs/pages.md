# Pages guide

This guide holds the rules for the README and the pages in `docs/`: how to organize a page, write a README, and review a changed page with a fresh reader.

## Organize a page

- Headings name what the reader does or learns, in words they would search for. Write "Install on macOS", not "Getting started".
- Use numbered steps for a procedure, bullets for items of the same kind, and prose for reasoning.
- Put each command the reader runs in a code block they can copy. Show the output when it helps them check their work.
- Make link text name the page it opens. Never write "click here".
- Update a page in place when something changes. Don't add notes such as "Updated in May".

## Write a README

A README opens with what the reader can do with the project. Then it covers these parts, in this order, each under a heading that follows the rule above:

1. A demo of the project as it works today, if there is one: a screenshot, a recording or a live link.
2. Setup.
3. One example from start to finish.

Until the example ends, explain only what the reader needs in order to use the project. After the example, state the project's known limits. A section on how the project works, if the README needs one, goes after the limits. Move it to `docs/` when it grows longer than the rest of the README.

## Review a changed page with a fresh reader

A README or docs page where you added or rewrote text gets a review by a reader who has seen only that page. Run the review before you open the pull request:

1. Start a new agent with no other context. Put the page's text in the prompt. Tell the agent not to open any files.
2. Give the reader this prompt: "You are <the page's reader and what they want to do, for example a developer who wants to use this project>. Read this page once, the way that reader would. Quote each sentence you had to read twice, and say what made you stop. Then quote each sentence you didn't need, and say why. Leave out sentences that you'd only word differently."
3. In the text you added or rewrote, rewrite each sentence that you agree is unclear. Cut a sentence that the reader didn't need only if `docs/rules.md` allows it, for a rule, or `docs/writing.md` allows it, for any other text. Leave quoted sentences elsewhere on the page as they are. If one of them is wrong, contradicts another rule or leaves out something the reader needs in order to act, open an issue for it, as step 4 of "Make a change" in AGENTS.md describes.
4. If you rewrote or cut sentences after the first review, run one more review with a new reader, and then stop. Change nothing after that review.
5. In the pull request, list each sentence that the last reader quoted, with the reader's reason.

The text you added or rewrote includes each sentence whose words the issue gives, and each sentence that a cut next to it made unclear. If you reword a sentence whose words the issue gives, say in the pull request how it differs from the issue.
