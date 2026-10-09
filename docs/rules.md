# Rules guide

This guide holds the rules for changing AGENTS.md, the guides in `docs/` and the labels on issues and pull requests.

- Put a rule in the guide that matches its subject, and a rule for one folder in an AGENTS.md in that folder. Don't add instruction files for one tool, such as `.cursorrules` or `.github/copilot-instructions.md`. Some tools read such a file instead of AGENTS.md, so one file can switch off the rules in AGENTS.md for that tool.
- Add a rule only when a maintainer asks for one and it passes its trial, as "Try a rule on agents" describes. Before you add it, say whether a check, a setting or a change to an existing rule would prevent the mistake instead. Remove a rule once it no longer applies, such as when the file or command that it names is gone.
- Leave out what the files show and how a mechanism works.
- Before you remove a rule that still applies, find out why it was added, with `git log -S "<words>"`. Keep it if its issue or pull request records a trial that it passed. Otherwise run the trial, and keep the rule only if it passes.
- Write a rule for the common case. When a rare case would need an exception, don't write one. Change the rule so that it covers that case too, or leave the case to the agent's judgment.
- Prefer a hook, a check or a setting to a rule. Don't write a rule for what one of them enforces with a message that says what to do. If a check runs only in CI, state what it expects, so that nobody fails CI to learn it.
- Agents follow rules less reliably as the number of rules grows. Aim to keep the rules that one session reads to about 250 sentences, but never remove a rule that passes its trial just to get there.
- To add, rename or remove a label, change "Labels" in AGENTS.md, `scripts/configure-github` and every other file that names the label, in the same pull request.

## Try a rule on agents

A rule is anything in AGENTS.md or a guide that asks agents to do something. Try on agents each rule that you add or change. A quote from a fresh reader's review, or anyone's view of what agents would do, isn't evidence for a rule. A change that asks for less removes part of a rule, as the bullet on removing a rule that still applies describes. A change that asks for the same thing in other words or in another place needs no trial, and neither does a fix to a step or command that gives a wrong result.

1. Write the mistake that the rule should prevent as a yes-or-no question about harm that an agent's run caused, such as "Does the run weaken a test?" Harm counts when someone has to fix or rework the run's result after the session, when a person has to step in during the session, or when the harm can't be undone. Results that someone has to fix or rework include code that's hard to read or change, text that a reader has to read twice, and a test that no longer guards anything. If no such question fits, the rule fails without a trial.
2. Write a prompt for a task from real work where the rule applies, or write a task if real work has none. Paste the task's text, not an issue's number. Pick a commit where the task isn't done yet. If the task needs code that the commit doesn't have, such as a small project that you wrote for it, commit that code on top of the commit.
3. Write the rule as a patch to main's AGENTS.md and guides.
4. Run `scripts/try-rule`. It runs the task 3 times without the rule.
5. Answer the question for each run from its output. If all 3 runs make the mistake, go on to step 6. Otherwise, the rule fails. Skip to step 7.
6. Run the command that the script printed last. It runs the task 3 times with the rule. Answer the question for each of these runs. The rule passes when none of them makes the mistake.
7. Record the question, the prompt, the patch and each run's answer in the issue for the change. Add the script's last table, which lists every run of the trial.
