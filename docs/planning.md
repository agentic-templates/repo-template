# Planning guide

This guide turns ideas into issues that an agent can build. The agent does the work in each step, and maintainers make the decisions that only they can make, such as which ideas to drop and which issues get built.

## Labels

"Labels" in AGENTS.md says what each label means. These rules say how three of them are used:

- `needs-triage`: the issue forms add it. An agent adds it to every issue it opens on its own, for something it noticed. Issues a maintainer asks for don't get it, including the ones created at triage or while planning.
- `needs-decision`: when you add it, write the question in the issue. When the maintainer decides, write the decision into the issue's body, because the agent that builds it reads the body. Then remove the label.
- `ready`: an accepted issue without `ready` waits in the backlog, unless a maintainer asks an agent to work on it.

## How an idea becomes buildable

1. **Input.** A maintainer shares or points to any text. The text itself isn't copied into the repository or into any issue.
2. **Triage.** The agent splits the input into single ideas, checks each one against the project and gives it a verdict. It asks the maintainer to approve only the verdicts that need a maintainer, such as dropping an idea. Once the maintainer has answered, it carries out the verdicts.
3. **Backlog.** Each accepted idea becomes one open issue without the `ready` label. A big idea stays one issue, with `needs-breakdown`.
4. **Planning.** When a maintainer asks to plan the next work, the maintainer and the agent agree on a goal. The agent picks the issues that the goal needs, splits the big ones and rewrites each one until it meets the definition of ready. Once the maintainer approves them, they get the `ready` label.
5. **Building.** Build runs take only issues with the `ready` label.

## Triage new ideas

Triage is for ideas: anything a maintainer wants judged before deciding whether to build it. "Make a change" in AGENTS.md says which requests skip triage.

Follow these steps for every idea, whatever form the input takes:

1. Take from the input the ideas that could change this project, and tell the maintainer in one line what you left out. Split them into single ideas. One idea is one result that someone wants. Merge ideas that ask for the same result.
2. Check each idea:
   - Does it fit the direction in "What this project is" in AGENTS.md?
   - Does an open or closed issue already cover it? Search with `gh issue list --state all --search "<words>"`.
   - Can the project build it, and is it worth what it costs?
   - Does it rely on claims about the project, such as how the code works or what users need? Check those claims against the code and AGENTS.md. List the ones that are out of date or contradict something. Ask the maintainer about them right away, before step 3, because the answers can change the verdicts you recommend there.
3. Recommend one verdict for each idea, with the reason. Each verdict says what happens when it's carried out:
   - **Accept:** the idea becomes an issue in the backlog.
   - **Accept, too big:** the idea becomes one issue with `needs-breakdown`.
   - **Research first:** a maintainer can't decide whether to build the idea, or what to build, until an open question is answered. The idea becomes an issue with `needs-decision`, blocked by a new research issue for the question. The maintainer decides once the answer is in.
   - **Needs a decision:** only a maintainer can settle it, such as which of two approaches to take. Ask the maintainer in step 4, and replace this verdict with the one that their answer leads to. If they want to decide later, the idea becomes an issue with `needs-decision`, so it isn't lost.
   - **Too vague:** it doesn't say what should change, or you can't tell why anyone would want it. If you can guess the likely reason, propose it and ask the maintainer to confirm. Otherwise give the idea back, and say what it's missing.
   - **Duplicate:** an issue already covers it. Add anything new to that issue as a comment. If that issue was closed as not planned, tell the maintainer, who decides whether to reopen it.
   - **Drop:** it doesn't fit the project's direction, can't be built or isn't worth its cost. Nothing is created.

   When two verdicts fit, recommend the one that leaves less for the maintainer to decide. For example, if no reading of an idea would fit the project, recommend **Drop**, not **Too vague**.

   Four verdicts don't need the maintainer's approval: **Accept**, **Accept, too big**, **Research first** and **Duplicate**. You carry them out in step 5, once the maintainer has answered your questions. The ideas come from a maintainer, so accepting one does what they asked, and an accepted issue waits in the backlog until a maintainer approves it while planning. **Drop**, **Too vague** and **Needs a decision** wait for the maintainer.
4. Before you show the maintainer your verdicts, ask a fresh critic about each idea that's big or that you're unsure about, as "Ask a fresh critic" describes. If the critic recommends revising or dropping an idea whose verdict doesn't need approval, make its verdict **Needs a decision**, because a maintainer decides each idea that the critic argues against. Show the maintainer a table of the ideas, verdicts and reasons, and mark the verdicts that you'll carry out without asking. Then ask the questions that only a maintainer can answer, one at a time, each with the answer you recommend. Finally, ask the maintainer to approve the verdicts that the table doesn't mark.
5. Carry out the verdicts only after the maintainer has answered your questions, because an answer can change a verdict, such as one that changes the project's direction. Carry out the verdicts that the table marks, the verdicts the maintainer approved, and any verdict that an answer turned into one of the four, without asking again. The issues you open don't get `needs-triage`, because a maintainer asked for them. Write each new issue in your own words. Issues are public, so leave out private details from the input, and link a public source instead of copying it. Write each issue under the three headings from AGENTS.md: "What should change", "Why" and "Done when". A research issue uses the headings in "Write a research issue". Give every new issue its type label.

Judge each idea on its merits. Don't agree with an idea because the maintainer seems to want it, and say plainly when you think one is weak.

If the maintainer's answers change the project's direction, open a pull request that updates "What this project is", as "Make a change" in AGENTS.md describes. Then, before you carry out any verdicts, redo the ones that the change affects.

### Ask a fresh critic

The critic mustn't see the maintainer's enthusiasm, so start a new agent without your conversation. Give it the "What this project is" section from AGENTS.md, the idea in plain words, and this prompt:

"Give the strongest case for building this idea and the strongest case against it. List what's unclear. Then recommend one: build it, revise it, or drop it. If you recommend revising it, say how. Say which concerns, if they were answered, would change your recommendation."

Add its recommendation and its main concerns to the triage table. The critic's recommendation informs the verdict and doesn't make it. Only a maintainer revises an idea. Don't ask another critic about it until the maintainer has revised it.

## Triage issues that others open

Before you plan the next work, triage every issue that has `needs-triage` or has no type label. Triage them sooner when the maintainer asks. Check each issue as step 2 of "Triage new ideas" describes, and recommend one of the verdicts below. Then carry out what the maintainer decides:

- **Accept:** remove `needs-triage` and give the issue its type label, plus `needs-breakdown` if it's too big.
- **Research first:** give the issue its type label, and replace `needs-triage` with `needs-decision`. Create a research issue for the question, and mark this issue as blocked by it.
- **Needs a decision:** give the issue its type label, and replace `needs-triage` with `needs-decision`.
- **Too vague:** comment with a question that asks for the missing detail, and leave `needs-triage`. If nobody answers within two weeks, comment that the issue is closing for lack of detail, and close it as not planned.
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

A research issue answers a question that someone has to find out before anyone can plan or build, such as "Can this library read Excel files?"

- Its body has three headings: "Question", "What depends on the answer" and "Done when". "Done when" asks for a comment with the answer, the evidence and a recommendation.
- It has the `research` label. Each issue that depends on the answer is blocked by it.

## Definition of ready

Every issue that gets the `ready` label, including research issues and parents, must come from a maintainer's account. On GitHub, the author of an issue can edit it at any time, so an issue from anyone else could change after its approval. An agent works under its maintainer's GitHub account, so the issues it opens come from a maintainer's account. If an issue came from an account that isn't a maintainer's, replace it with a new one, as "Triage issues that others open" describes.

An issue from a maintainer's account can get `ready` when all of these are true:

- It asks for one change that fits in one pull request.
- "Why" says who needs the change and what for.
- Someone could check each "Done when" item by running or looking at something. Where quality matters, such as accuracy or speed, the item gives a number that a maintainer chose or approved.
- Nothing is left to decide, except a question about how to build it that a research issue blocking it will answer. If the answer could change what the issue asks for, the issue isn't ready, and it keeps `needs-decision` until a maintainer decides. The issue has no "maybe", no "to be decided" and no "A or B".
- "What should change" says what's out of scope, if the agent that builds the issue might otherwise do more than the issue asks for.
- It's blocked by every issue whose change it needs first.
- It has one type label and no status label.

Two kinds of issue meet a shorter list. A research issue is ready when its question and what depends on the answer are clear, and it has its type label and no status label. A parent is ready when someone could check each of its "Done when" items, it has its type label and no status label, and each of its sub-issues is ready.

## Plan the next work

Planning takes the issues that a goal needs and gets each one ready to build. Plan all of them before anyone builds, so that agents can build them in one run.

1. Agree on the goal with the maintainer: what a user can do afterwards that they can't do now.
2. Triage anything new, including open issues that need triage.
3. Choose the backlog issues that the goal needs, and leave out the rest. Add the issues the goal still lacks, including research issues for what someone has to find out, and break down any big issue you chose.
4. Link each issue to the issues whose change it needs first, with `gh issue edit <issue> --add-blocked-by <other issue>`. Link only real dependencies, because a blocked issue waits until all its blockers are closed. Every blocker must be part of this plan, have the `ready` label already or be closed. A build run can build several issues at once, so only a link makes sure that one change comes before another.
5. Make every issue meet the definition of ready. Then have a fresh reader check each one. Start a new agent without your conversation, let it read the code, and give it the issue with this prompt: "You're about to build this issue. You can read the code, but you know nothing else. List what you'd have to guess that could change what you build." Fix what it lists, and ask the maintainer about anything that's their decision.
6. Ask the maintainer to review the issues.
7. Add the `ready` label to each issue the maintainer approved, with `gh issue edit <issue> --add-label ready`.
