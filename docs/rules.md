# Rules guide

This guide holds the rules for changing AGENTS.md, the guides in `docs/` and the labels on issues and pull requests.

- Inside the repository, instructions for agents live in AGENTS.md files and the guides in `docs/`. Put a rule in the guide that matches its subject, and a rule for one folder in an AGENTS.md in that folder. Don't add instruction files for one tool, such as `.cursorrules` or `.github/copilot-instructions.md`. Some tools read such a file instead of AGENTS.md, so one file can switch off the rules in AGENTS.md for that tool. `scripts/instruction-file-names` lists the names of these files. `scripts/check` fails when the repository has such a file, and a hook blocks the agent from writing one.
- Add a rule only when a maintainer asks for one. Before you add it, say whether a check, a setting or a change to an existing rule would prevent the mistake instead. Keep a rule that explains what a check expects, so that nobody has to fail the check to learn what it wants. Remove a rule once it no longer applies.
- Keep each AGENTS.md and each guide in `docs/` under 200 lines and 25 KB. Keep the AGENTS.md files on the path from the repository's root down to any one folder under 32 KB together, because Codex stops reading them past that size. When a file grows past a limit, move a procedure that only one kind of request needs into a guide of its own.
- To add, rename or remove a label, change "Labels" in AGENTS.md, `scripts/configure-github` and every other file that names the label, in the same pull request.
