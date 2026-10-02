# Pages guide

This guide holds the rules for the README and the pages in `docs/`: how to organize a page, write a README, and review a changed page with a fresh reader.

## Organize a page

- Headings name what the reader does or learns, in words they would search for. Write "Install on macOS", not "Getting started".
- Use numbered steps for a procedure, bullets for items of the same kind, and prose for reasoning.
- Put each command the reader runs in a code block they can copy. Show the output when it helps them check their work.
- Make link text name the page it opens. Never write "click here".
- Update a page in place when something changes. Don't add notes such as "Updated in May", because git keeps the history.

## Write a README

A README opens with what the reader can do with the project. Then it covers these parts, in this order, each under a heading that follows the rule above:

1. A demo of the project as it works today, if there is one: a screenshot, a recording or a live link.
2. Setup.
3. One example from start to finish.

Until the example ends, explain only what the reader needs in order to use the project. After the example, state the project's known limits. A section on how the project works, if the README needs one, goes after the limits. Move it to `docs/` when it grows longer than the rest of the README.

## Review a changed page with a fresh reader

A README or docs page where you added or rewrote text gets a review by a reader who has seen only that page. Run the review before you open the pull request:

1. Start a new agent with no other context. Put the page's text in the prompt. Tell the agent not to open any files, so that it doesn't read the repository.
2. Give the reader this prompt: "You are <the page's reader, for example a developer who has never seen this project>. Read this page once, the way that reader would. Quote each sentence you had to read twice, and say what made you stop."
3. If a quoted sentence is in the text you added or rewrote, and you agree that it's unclear, rewrite it. Leave quoted sentences elsewhere on the page as they are. If one of them is wrong, contradicts another rule or leaves out something the reader needs in order to act, open an issue for it, as step 4 of "Make a change" in AGENTS.md describes. Once you've made the rewrites from a review, repeat it with another fresh reader. Stop when a reader quotes no sentence that you agree is unclear in the text you added or rewrote.
