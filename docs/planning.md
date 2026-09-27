# Planning guide

This guide turns ideas into issues that an agent can build. An idea can come from anywhere: a sentence in a chat, a list of rough ideas or an old spec. It becomes an issue only when the owner accepts it in triage, and it joins a milestone only when it's ready to build. The agent does the work in each step, and the owner makes the decisions.

## How an idea becomes buildable

1. **Input.** The owner shares a message, a list or a file. It stays outside the repository.
2. **Triage.** The agent splits the input into single ideas, checks each one against the project and recommends what to do with it. The owner decides.
3. **Backlog.** Each accepted idea becomes one open issue without a milestone. A big idea stays one issue, with `needs-breakdown`.
4. **Ready.** When an issue is planned into a milestone, it's split if it's big and rewritten until it meets the definition of ready.
5. **Built.** A builder takes only issues that are ready.

## Triage new ideas

Follow these steps for any input:

1. Split the input into single ideas. One idea is one result that someone wants. Merge ideas that ask for the same result.
2. Check each idea:
   - Does it serve the goal in "What this project is" in AGENTS.md, and stay clear of what's out of scope there?
   - Does it keep the project's decisions?
   - Does an open or closed issue already cover it? Search with `gh issue list --state all --search "<words>"`.
   - Can the project build it, and is it worth what it costs?
3. Give each idea one verdict, with the reason:
   - **Accept:** it becomes an issue in the backlog.
   - **Accept, too big:** it becomes one issue with `needs-breakdown`.
   - **Research first:** an open question decides whether or how to build it, so it becomes a research issue.
   - **Needs a decision:** the owner has to choose something before anyone can judge it.
   - **Duplicate:** an issue already covers it. Add anything new to that issue.
   - **Drop:** it's out of scope, breaks a decision, can't be built or isn't worth its cost. Nothing is created.
4. Show the owner a table of the ideas, verdicts and reasons. Then ask the open questions one at a time, each with the answer you recommend.
5. Create issues only for the ideas the owner accepts, each with its type label. Nothing becomes an issue without the owner's yes.

Your job in triage is to find the weak ideas, not to agree. Say so when you think an idea is weak, even when the owner seems to want it.

### Adjust to the kind of input

- **An old spec:** before the verdicts, list the parts that are out of date or that contradict each other, the code or AGENTS.md. The owner decides those parts, so don't guess.
- **A list of rough ideas:** many are too vague to judge. An idea that can't say what should change and why goes back to the owner's notes for now.
- **One developed idea:** there's nothing to split, so ask a fresh critic and give the verdict.

### Ask a fresh critic

Get a second opinion on any idea that's big or that you're unsure about. The critic mustn't see the owner's enthusiasm, so start a new agent with no other context. Give it the "What this project is" section from AGENTS.md, the idea, and this prompt:

"Give the strongest case for building this idea and the strongest case against it. List what's unclear. Then recommend one: build it, reshape it, or drop it. If you recommend reshaping it, say how."

Add its recommendation to the triage table.

## Triage issues that others open

Issues opened with a form have `needs-triage`, and so do issues that agents open on their own. An issue without a type label needs triage too. Triage them before you plan each release, with the same checks and verdicts, and carry out what the owner decides:

- **Accept:** remove `needs-triage` and give the issue one type label. If the author didn't use the three headings, rewrite the body under them.
- **Duplicate:** close it with `gh issue close <issue> --duplicate-of <other issue>`.
- **Drop:** comment why, then close it with `gh issue close <issue> --reason "not planned"`, so anyone who proposes the idea again finds the reason.

## Break down a big idea

- A big idea is one parent issue. Its "What should change" states the result the owner wants, and its "Done when" says how to tell that the result is reached.
- It waits in the backlog with `needs-breakdown`. Split it when it's planned into a milestone, not earlier, because earlier releases change what the pieces should be.
- Split it into sub-issues that each fit in one pull request and leave main working. Create each one with `gh issue create --parent <parent>`, then remove `needs-breakdown` from the parent.
- Builders don't build a parent. It closes when all its sub-issues are closed.

## Write a research issue

A research issue answers a question that has to be settled before anyone can plan or build, such as "Can this library read HEIC files?"

- Its body has three headings: "Question", "What depends on the answer" and "Done when". "Done when" asks for a comment with the answer, the evidence and a recommendation.
- It has the `research` label. Each issue that depends on the answer is blocked by it.
- A builder answers it as "Build a milestone" in AGENTS.md describes, without a pull request.

## Definition of ready

An issue can join a milestone when all of these are true:

- It asks for one change that fits in one pull request.
- "Why" says who needs the change and what for.
- Someone could check each "Done when" item by running or looking at something. Where quality matters, such as accuracy or speed, the item gives a number.
- Nothing is left to decide. The issue has no "maybe", no "to be decided" and no "A or B".
- It says what's out of scope wherever a builder might do more.
- It keeps the project's decisions in AGENTS.md.
- It's blocked by every issue whose change it needs first.
- It has one type label and no status label.

## Plan a release

A release is a milestone of ready issues. Plan the whole release before anyone builds it, so that an agent can build it in one run.

1. Agree on the goal with the owner: what a user can do after the release that they can't do now.
2. Triage anything new, including open issues that have `needs-triage`.
3. Choose the version, such as `v0.2.0`. It also names the milestone, and the commands below show it as `<version>`. Raise the patch number for a release with only fixes, the minor number for new features, and the major number for a change that breaks existing use. Before version 1.0, a breaking change raises the minor number instead.
4. Choose the backlog issues that the goal needs, and leave out the rest. Add research issues for open questions, and break down any big issue you chose.
5. Make every issue meet the definition of ready. Then have a fresh reader check each one. Give a new agent only the issue and this prompt: "You're about to build this with nothing else to go on. List everything you'd have to guess." Fix what it lists.
6. Create the milestone, then add each issue to it. `gh` fills in `{owner}` and `{repo}`:
   `gh api repos/{owner}/{repo}/milestones -f title=<version> -f description="<goal>"`
   `gh issue edit <issue> --milestone <version>`
7. Set the order with blocked-by links: `gh issue edit <issue> --add-blocked-by <other issue>`. A builder takes any issue whose blockers are all closed, lowest number first. Issue numbers don't set the order, because an older backlog issue has a lower number than a new one it depends on.
8. Ask the owner to review the milestone before anyone builds it.
