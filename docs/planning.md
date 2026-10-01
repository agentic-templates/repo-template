# Planning guide

This guide turns ideas into issues that an agent can build. An idea can come from any text that a maintainer shares or points to. The agent does the work in each step, and maintainers make the decisions.

Issues that anyone but a maintainer opens, and issues that agents open for problems they notice while working, wait for a maintainer to triage them. Every other issue comes from a decision a maintainer made, and no issue gets the `ready` label until a maintainer approves it.

## How an idea becomes buildable

1. **Input.** A maintainer shares or points to any text. The text itself isn't copied into the repository or into any issue.
2. **Triage.** The agent splits the input into single ideas, checks each one against the project and recommends what to do with it. The maintainer decides.
3. **Backlog.** Each accepted idea becomes one open issue without the `ready` label. A big idea stays one issue, with `needs-breakdown`.
4. **Planning.** When a maintainer plans the next work, the agent picks the issues that its goal needs, splits the big ones and rewrites each one until it meets the definition of ready. Once the maintainer approves them, they get the `ready` label.
5. **Building.** Build runs take only issues with the `ready` label.

## Triage new ideas

Triage is for ideas: anything a maintainer proposes or wants judged. "Make a change" in AGENTS.md says which requests skip triage.

Follow these steps for every idea, whatever form the input takes:

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

   When two verdicts fit, recommend the one that leaves less for the maintainer to decide. For example, if no reading of an idea would fit the project, recommend **Drop**, not **Too vague**.
4. Before you show the maintainer your verdicts, ask a fresh critic about each idea that's big or that you're unsure about, as "Ask a fresh critic" describes. Show the maintainer a table of the ideas, verdicts and reasons. Then ask the questions that only a maintainer can answer, one at a time, each with the answer you recommend. Finally, ask the maintainer to approve the verdicts.
5. Carry out only the verdicts the maintainer approved. Write each new issue in your own words. Issues are public or can become public, so leave out private details from the input, and link a public source instead of copying it. Write each issue under the three headings from AGENTS.md: "What should change", "Why" and "Done when". A research issue uses the headings in "Write a research issue". Give every new issue its type label.

Judge each idea on its merits. Don't agree with an idea because the maintainer seems to want it, and say plainly when you think one is weak.

If the maintainer's answers change the project's direction, open a pull request that updates "What this project is", as "Make a change" in AGENTS.md describes. Then, before you carry out any verdicts, redo the ones that the change affects.

### Ask a fresh critic

The critic mustn't see the maintainer's enthusiasm, so start a new agent without your conversation. Give it the "What this project is" section from AGENTS.md, the idea in plain words, and this prompt:

"Give the strongest case for building this idea and the strongest case against it. List what's unclear. Then recommend one: build it, revise it, or drop it. If you recommend revising it, say how. Say which concerns, if they were answered, would change your recommendation."

Add its recommendation and its main concerns to the triage table. The critic informs the maintainer's decision and doesn't make it. Only a maintainer revises an idea. Don't ask another critic about it until the maintainer has revised it.

## Triage issues that others open

Triage every issue that has `needs-triage` or no type label before you plan the next work, or sooner when the maintainer asks. Use the same checks and verdicts, and carry out what the maintainer decides:

- **Accept:** remove `needs-triage` and give the issue its type label, plus `needs-breakdown` if it's too big.
- **Research first:** give the issue its type label, and replace `needs-triage` with `needs-decision`. Create a research issue for the question, and mark this issue as blocked by it.
- **Needs a decision:** give the issue its type label, and replace `needs-triage` with `needs-decision`.
- **Too vague:** comment with the question that's missing, and leave `needs-triage`. If nobody answers within two weeks, comment that the issue is closing for lack of detail, and close it as not planned.
- **Duplicate:** close it with `gh issue close <issue> --duplicate-of <other issue>`.
- **A question about using the project:** answer it in a comment, and close the issue. If the docs should have answered it, also open a `bug` about the docs.
- **Drop:** comment why, then close it with `gh issue close <issue> --reason "not planned"`, so anyone who proposes the idea again finds the reason.

An issue from an account that isn't a maintainer's can never get `ready`, as "Definition of ready" describes. So if the verdict for such an issue is **Accept**, **Research first** or **Needs a decision**, carry out the verdict on a new issue instead of the original. Write the new issue in your own words under the three headings, and include what the maintainer decided or the question that's still open. Then close the original with `gh issue close <issue> --duplicate-of <new issue>`, and add a comment that points its author to the new issue. If they opened a pull request for the original, also ask them to change its `Closes` line to the new issue.

## Break down a big idea

- A big idea is one parent issue. Its "What should change" states the result the maintainer wants, and its "Done when" says how to tell that the result is reached.
- It waits in the backlog with `needs-breakdown`. Split it only when you make it ready to build, because the right sub-issues depend on what's in the code by then.
- Split it into sub-issues that each fit in one pull request and leave main working. Create each one with `gh issue create --parent <parent>`, then remove `needs-breakdown` from the parent.
- Give the parent the `ready` label along with its sub-issues. A build run skips the parent until all its sub-issues are closed, and then checks the parent's "Done when".

## Write a research issue

A research issue answers a question that someone has to find out before anyone can plan or build, such as "Can this library read HEIC files?"

- Its body has three headings: "Question", "What depends on the answer" and "Done when". "Done when" asks for a comment with the answer, the evidence and a recommendation.
- It has the `research` label. Each issue that depends on the answer is blocked by it.

## Definition of ready

An issue can get the `ready` label when all of these are true:

- It asks for one change that fits in one pull request.
- "Why" says who needs the change and what for.
- Someone could check each "Done when" item by running or looking at something. Where quality matters, such as accuracy or speed, the item gives a number that a maintainer chose or approved.
- Nothing is left to decide, except a question that a research issue blocking it will answer. The issue has no "maybe", no "to be decided" and no "A or B".
- "What should change" says what's out of scope wherever the agent building it might do more.
- It's blocked by every issue whose change it needs first.
- It has one type label and no status label.

Two kinds of issue meet a shorter list. A research issue is ready when its question and what depends on the answer are clear, and it has its type label and no status label. A parent gets `ready` along with its sub-issues, and only its sub-issues need to meet the full list.

Every issue that gets `ready`, including research issues and parents, must come from a maintainer's account, so that nobody else can edit it after approval. If an issue came from an account that isn't a maintainer's, replace it with a new one, as "Triage issues that others open" describes.

## Plan the next work

Planning makes the issues that a goal needs ready to build. Plan all of them before anyone builds, so that agents can build them in one run.

1. Agree on the goal with the maintainer: what a user can do afterwards that they can't do now.
2. Triage anything new, including open issues that need triage.
3. Choose the backlog issues that the goal needs, and leave out the rest. Add the issues the goal still lacks, including research issues for what someone has to find out, and break down any big issue you chose.
4. Link each issue to the issues whose change it needs first, with `gh issue edit <issue> --add-blocked-by <other issue>`. Link only real dependencies, because a blocked issue waits until all its blockers are closed. Every blocker must be part of this plan, have the `ready` label already or be closed. Issues with no open blockers are built lowest number first, so if one change must come before another, link them.
5. Make every issue meet the definition of ready. Then have a fresh reader check each one. Start a new agent without your conversation, let it read the code, and give it the issue with this prompt: "You're about to build this issue. You can read the code, but you know nothing else. List what you'd have to guess that could change what you build." Fix what it lists, and ask the maintainer about anything that's their decision.
6. Ask the maintainer to review the issues.
7. Add the `ready` label to each issue the maintainer approved, with `gh issue edit <issue> --add-label ready`.
