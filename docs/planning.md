# Planning guide

This guide turns ideas into issues that an agent can build. An idea can come from any text that a maintainer shares or points to. The agent does the work in each step, and maintainers make the decisions.

Only two kinds of issue appear without a maintainer's yes: issues that people open through the forms, and issues that an agent opens for a problem it notices while working. Both carry `needs-triage` until a maintainer decides. Every other issue comes from a decision a maintainer made, and no issue gets the `ready` label until a maintainer approves it.

## How an idea becomes buildable

1. **Input.** A maintainer shares or points to any text. It stays outside the repository and its issues.
2. **Triage.** The agent splits the input into single ideas, checks each one against the project and recommends what to do with it. The maintainer decides.
3. **Backlog.** Each accepted idea becomes one open issue without the `ready` label. A big idea stays one issue, with `needs-breakdown`.
4. **Planning.** When a maintainer plans the next work, the agent picks the issues that its goal needs, splits the big ones and rewrites each one until it meets the definition of ready. Once the maintainer approves them, they get the `ready` label.
5. **Building.** Build runs take only issues with the `ready` label.

## Triage new ideas

Triage is for ideas: anything a maintainer proposes or wants judged. A request for a specific change whose pull request a reviewer could read in one sitting, and that needs no decision along the way, isn't an idea. For that, check it against "What this project is" and existing issues, open or closed. If there's a conflict, point it out and wait for the maintainer's answer. Otherwise follow "Make a change" in AGENTS.md.

Follow these steps whatever the input is, even when it reads like a plan or a request:

1. Take from the input the ideas that could change this project, and tell the maintainer in one line what you left out. Split them into single ideas. One idea is one result that someone wants. Merge ideas that ask for the same result.
2. Check each idea:
   - Does it fit the direction in "What this project is" in AGENTS.md?
   - Does an open or closed issue already cover it? Search with `gh issue list --state all --search "<words>"`.
   - Can the project build it, and is it worth what it costs?
   - Does it rely on claims about the project, such as how the code works or what users need? Check those claims against the code and AGENTS.md. List the ones that are out of date or contradict something, and ask the maintainer about them first, because the answers can change the verdicts.
3. Recommend one verdict for each idea, with the reason. Each verdict says what happens once the maintainer agrees:
   - **Accept:** the idea becomes an issue in the backlog.
   - **Accept, too big:** the idea becomes one issue with `needs-breakdown`.
   - **Research first:** someone has to find something out before anyone can judge or build it, such as whether a library can do the job. The idea becomes an issue with `needs-decision`, blocked by a new research issue for the question. The maintainer decides once the answer is in.
   - **Needs a decision:** only a maintainer can settle it, such as which of two approaches to take. Ask the maintainer, and their answer turns it into another verdict. If they want to decide later, the idea becomes an issue with `needs-decision`, so it isn't lost.
   - **Too vague:** it doesn't say what should change, or you can't tell why anyone would want it. If you can guess the likely reason, propose it and ask the maintainer to confirm. Otherwise give the idea back, and say what it's missing.
   - **Duplicate:** an issue already covers it. Add anything new to that issue as a comment. If that issue was closed as not planned, tell the maintainer, who decides whether to reopen it.
   - **Drop:** it doesn't fit the project's direction, can't be built or isn't worth its cost. Nothing is created.

   When two verdicts fit, recommend the one that settles more. For example, drop an idea that doesn't fit rather than asking what it means.
4. Show the maintainer a table of the ideas, verdicts and reasons. Then ask the questions that only a maintainer can answer, one at a time, each with the answer you recommend. Finally, ask the maintainer to approve the verdicts.
5. Carry out only the verdicts the maintainer approved. Write each new issue in your own words. Issues are public, so leave out private details from the input, and link a public source instead of copying it. Write each issue under the three headings from AGENTS.md: "What should change", "Why" and "Done when". A research issue uses the headings in "Write a research issue". Give every new issue its type label.

Judge each idea on its merits. Don't agree with an idea because the maintainer seems to want it, and say plainly when you think one is weak. A request like "Let's add this" for anything bigger than one pull request is still an idea, so give the verdict before you create anything.

If the maintainer's answers change the project's direction, open a pull request that updates "What this project is", as "Make a change" in AGENTS.md describes. Then redo the verdicts that the change affects, before you carry any of them out.

### Ask a fresh critic

Before you show the table, get a second opinion on any idea that's big or that you're unsure about. The critic mustn't see the maintainer's enthusiasm, so start a new agent without your conversation. Give it the "What this project is" section from AGENTS.md, the idea in plain words, and this prompt:

"Give the strongest case for building this idea and the strongest case against it. List what's unclear. Then recommend one: build it, reshape it, or drop it. If you recommend reshaping it, say how. Say which concerns, if they were answered, would change your recommendation."

Add its recommendation and its main concerns to the triage table. The critic informs the maintainer's decision and doesn't make it. Only a maintainer reshapes an idea, and a new critic looks at it only after they have.

## Triage issues that others open

Issues opened through a form have `needs-triage`, and so do issues that an agent opens for a problem it notices. An issue without a type label needs triage too. Triage these before you plan the next work, or sooner when the maintainer asks. Use the same checks and verdicts, and carry out what the maintainer decides:

- **Accept:** remove `needs-triage` and give the issue its type label, plus `needs-breakdown` if it's too big. If the author didn't use the three headings, rewrite the body under them, using only what the author wrote and what the maintainer decided.
- **Research first:** give the issue its type label, and replace `needs-triage` with `needs-decision`. Create a research issue for the question, and mark this issue as blocked by it.
- **Needs a decision:** give the issue its type label, and replace `needs-triage` with `needs-decision`.
- **Too vague:** comment with the question that's missing, and leave `needs-triage`. If nobody answers within two weeks, comment that the issue is closing for lack of detail, and close it as not planned.
- **Duplicate:** close it with `gh issue close <issue> --duplicate-of <other issue>`.
- **A question about using the project:** answer it in a comment, and close the issue. If the docs should have answered it, turn the issue into a `bug` about the docs instead.
- **Drop:** comment why, then close it with `gh issue close <issue> --reason "not planned"`, so anyone who proposes the idea again finds the reason.

## Break down a big idea

- A big idea is one parent issue. Its "What should change" states the result the maintainer wants, and its "Done when" says how to tell that the result is reached.
- It waits in the backlog with `needs-breakdown`. Split it when the work that needs it is planned, not earlier, because the work before it changes what the pieces should be.
- Split it into sub-issues that each fit in one pull request and leave main working. Create each one with `gh issue create --parent <parent>`, then remove `needs-breakdown` from the parent.
- Give the parent the `ready` label along with its sub-issues. Builders skip a parent while it has open sub-issues. Once they're all closed, a builder checks the parent's "Done when" and closes it.

## Write a research issue

A research issue answers a question that someone has to find out before anyone can plan or build, such as "Can this library read HEIC files?"

- Its body has three headings: "Question", "What depends on the answer" and "Done when". "Done when" asks for a comment with the answer, the evidence and a recommendation.
- It has the `research` label. Each issue that depends on the answer is blocked by it.
- A builder answers it in a comment, without a pull request, and closes it. If the answer changes what a blocked issue asks for, the builder adds `needs-decision` to that issue, so the maintainer decides before it's built.

## Definition of ready

An issue can get the `ready` label when all of these are true:

- It asks for one change that fits in one pull request.
- "Why" says who needs the change and what for.
- Someone could check each "Done when" item by running or looking at something. Where quality matters, such as accuracy or speed, the item gives a number that a maintainer chose or approved.
- Nothing is left to decide, except a question that a research issue blocking it will answer. The issue has no "maybe", no "to be decided" and no "A or B".
- "What should change" says what's out of scope wherever a builder might do more.
- It's blocked by every issue whose change it needs first.
- It has one type label and no status label.

Two kinds of issue meet a shorter list. A research issue is ready when its question and what depends on the answer are clear, and it has its type label and no status label. A parent gets `ready` along with its sub-issues, and only its sub-issues need to meet the full list.

Every issue that gets `ready`, including research issues and parents, must be one that a maintainer opened, so that nobody else can edit it after approval. For an issue that someone else opened, open a new one in your own words, and close the original with `gh issue close <issue> --duplicate-of <new issue>`.

## Plan the next work

Planning makes the issues that a goal needs ready to build. Plan all of them before anyone builds, so that agents can build them in one run.

1. Agree on the goal with the maintainer: what a user can do afterwards that they can't do now.
2. Triage anything new, including open issues that need triage.
3. Choose the backlog issues that the goal needs, and leave out the rest. Add the issues the goal still lacks, including research issues for what someone has to find out, and break down any big issue you chose. Issues that you create while planning with the maintainer don't get `needs-triage`, because the maintainer reviews them in step 6.
4. Link each issue to the issues whose change it needs first, with `gh issue edit <issue> --add-blocked-by <other issue>`. Link only real dependencies, because a blocked issue waits until all its blockers are closed. Every blocker must be part of this plan, have the `ready` label already or be closed. Issues with no open blockers are built lowest number first, so if one change must come before another, link them.
5. Make every issue meet the definition of ready. Then have a fresh reader check each one. Start a new agent without your conversation, let it read the code, and give it the issue with this prompt: "You're about to build this issue. You can read the code, but you know nothing else. List what you'd have to guess that could change what you build." Fix what it lists, and ask the maintainer about anything that's their decision.
6. Ask the maintainer to review the issues.
7. Add the `ready` label to each issue the maintainer approved, with `gh issue edit <issue> --add-label ready`.
