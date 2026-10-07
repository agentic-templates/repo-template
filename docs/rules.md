# Rules guide

This guide holds the rules for changing AGENTS.md, the guides in `docs/` and the labels on issues and pull requests.

- Put a rule in the guide that matches its subject, and a rule for one folder in an AGENTS.md in that folder. Don't add instruction files for one tool, such as `.cursorrules` or `.github/copilot-instructions.md`. Some tools read such a file instead of AGENTS.md, so one file can switch off the rules in AGENTS.md for that tool.
- Add a rule only when a maintainer asks for one. Before you add it, say whether a check, a setting or a change to an existing rule would prevent the mistake instead. Remove a rule once it no longer applies.
- Keep a rule only if, without it, an agent would do something the maintainer doesn't want. Leave out what agents already do right, what the files show and how a mechanism works.
- Before you remove a rule, find out why it was added, with `git log -S "<words>"`. Keep it if it prevents a mistake that happened, or records a decision that would be costly to make again.
- Write a rule for the common case. When a rare case would need an exception, change the rule or leave the case to the agent's judgment.
- Prefer a check or a setting to a rule, and don't restate what `scripts/check` or a GitHub setting enforces with a message that says what to do. A hook helps too, but keep its rule written, because some agents run no hooks. State what a check that runs only in CI expects, so that nobody fails CI to learn it.
- Agents follow rules less reliably as their number grows. Aim to keep the rules that one session reads to about 250 sentences, but never remove a rule that passes the test above just to get there.
- Keep each AGENTS.md and each guide in `docs/` under 200 lines and 25 KB. Keep the AGENTS.md files on the path from the repository's root down to any one folder under 32 KB together. When a file grows past a limit, move a procedure that only one kind of request needs into a guide of its own.
- To add, rename or remove a label, change "Labels" in AGENTS.md, `scripts/configure-github` and every other file that names the label, in the same pull request.
