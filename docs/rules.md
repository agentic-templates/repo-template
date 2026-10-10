# Rules guide

- Put a rule in the guide that matches its subject, and a rule for one folder in an AGENTS.md in that folder. Don't add instruction files for one tool, such as `.cursorrules` or `.github/copilot-instructions.md`.
- Add a rule only when a maintainer asks for one. Before you add it, say whether a check, a setting or a change to an existing rule would prevent the mistake instead. Remove a rule once it no longer applies, such as when the file or command that it names is gone.
- Leave out what agents already do without being told, what the files show and how a mechanism works.
- Before you remove a rule that still applies, find out why it was added, with `git log -S "<words>"`. Keep it if it prevents a mistake that happened, or records a decision that would be costly to make again.
- Write a rule for the common case. When a rare case would need an exception, don't write one. Change the rule so that it covers that case too, or leave the case to the agent's judgment.
- Prefer a hook, a check or a setting to a rule. Don't write a rule for what one of them enforces with a message that says what to do.
- Agents follow rules less reliably as the number of rules grows. Aim to keep the rules that one session reads to about 250 sentences.
- To add, rename or remove a label, change "Labels" in AGENTS.md, `scripts/configure-github` and every other file that names the label, in the same pull request.
