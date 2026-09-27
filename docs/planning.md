# Planning guide

This guide turns ideas into issues that an agent can build. An idea can come from anywhere: a sentence in a chat, a list of rough ideas or an old spec. The agent does the work in each step, and the owner makes the decisions. Nothing the owner or an agent brings in becomes an issue until the owner accepts it, and no issue joins a milestone until it's ready to build.

## How an idea becomes buildable

1. **Input.** The owner shares a message, a list or a file. It stays outside the repository.
2. **Triage.** The agent splits the input into single ideas, checks each one against the project and recommends what to do with it. The owner decides.
3. **Backlog.** Each accepted idea becomes one open issue without a milestone. A big idea stays one issue, with `needs-breakdown`.
4. **Planning.** When the owner plans a release, the agent picks the issues it needs, splits the big ones and rewrites each one until it meets the definition of ready. Then the issues join the milestone.
5. **Building.** A builder takes only issues that are ready.

## Triage new ideas

Triage is for ideas: anything the owner proposes, lists or wants judged. When the owner asks for a specific change that fits in one pull request, follow "Make a change" in AGENTS.md instead.

Follow these steps for any input:

1. Split the input into single ideas. One idea is one result that someone wants. Merge ideas that ask for the same result.
2. Check each idea:
   - Does it serve the goal in "What this project is" in AGENTS.md, and stay clear of what's out of scope there?
   - Does it respect the project's decisions there?
   - Does an open or closed issue already cover it? Search with `gh issue list --state all --search "<words>"`.
   - Can the project build it, and is it worth what it costs?
3. Give each idea one verdict, with the reason:
   - **Accept:** create an issue for it in the backlog.
   - **Accept, too big:** create one issue for it with `needs-breakdown`.
   - **Research first:** someone has to find something out before anyone can judge or build it, such as whether a library can do the job. Create the idea's issue and a research issue for the question, and mark the idea's issue as blocked by the research issue.
   - **Needs a decision:** only the owner can settle it, such as which of two directions to take. Ask the owner, and their answer turns it into another verdict. If they want to decide later, create its issue with `needs-decision`, so the idea isn't lost.
   - **Too vague:** it can't say what should change and why. Give it back to the owner with the question that's missing.
   - **Duplicate:** an issue already covers it. Add anything new to that issue as a comment. If that issue was closed as not planned, tell the owner, who decides whether to reopen it.
   - **Drop:** it's out of scope, goes against a decision, can't be built or isn't worth its cost. Create nothing.
4. Show the owner a table of the ideas, verdicts and reasons. Then ask the questions that only the owner can answer, one at a time, each with the answer you recommend.
5. Create issues only for what the owner accepts. Write each one under the three headings from AGENTS.md: "What should change", "Why" and "Done when". Give it its type label.

Your job in triage is to find the weak ideas, not to agree. Say so when you think an idea is weak, even when the owner seems to want it. A request like "Let's add this" for anything bigger than one pull request is still an idea, so give the verdict before you create anything.

### Adjust to the kind of input

- **An old spec:** start by listing the parts that are out of date, and the parts that contradict other parts of the spec, the code or AGENTS.md. Ask the owner about them first, because the answers change the verdicts.
- **A list of rough ideas:** expect many ideas to be too vague. Judge the rest.
- **One developed idea:** there's nothing to split, so ask a fresh critic and give the verdict.

### Ask a fresh critic

Get a second opinion on any idea that's big or that you're unsure about. The critic mustn't see the owner's enthusiasm, so start a new agent without your conversation. Give it the "What this project is" section from AGENTS.md, the idea in plain words, and this prompt:

"Give the strongest case for building this idea and the strongest case against it. List what's unclear. Then recommend one: build it, reshape it, or drop it. If you recommend reshaping it, say how."

Add its recommendation to the triage table.

## Triage issues that others open

Issues opened with a form have `needs-triage`. An agent adds `needs-triage` to every issue it opens on its own, and an issue without a type label needs triage too. Triage these before you plan each release, or sooner when the owner asks. Use the same checks and verdicts, and carry out what the owner decides:

- **Accept:** remove `needs-triage` and give the issue its type label, plus `needs-breakdown` if it's too big. If the author didn't use the three headings, rewrite the body under them, using only what the author wrote and what the owner decided.
- **Research first** or **Needs a decision:** handle it as in "Triage new ideas", and remove `needs-triage`.
- **Too vague:** comment with the question that's missing, and leave `needs-triage`. If nobody answers before the next triage, close the issue as not planned.
- **Duplicate:** close it with `gh issue close <issue> --duplicate-of <other issue>`.
- **Drop:** comment why, then close it with `gh issue close <issue> --reason "not planned"`, so anyone who proposes the idea again finds the reason.

## Break down a big idea

- A big idea is one parent issue. Its "What should change" states the result the owner wants, and its "Done when" says how to tell that the result is reached.
- It waits in the backlog with `needs-breakdown`. Split it when a release plans it, not earlier, because the releases before it change what the pieces should be.
- Split it into sub-issues that each fit in one pull request and leave main working. Create each one with `gh issue create --parent <parent>`, then remove `needs-breakdown` from the parent.
- Add the parent to the milestone with its sub-issues. Builders skip a parent while it has open sub-issues, and close it once they're all closed.

## Write a research issue

A research issue answers a question that someone has to find out before anyone can plan or build, such as "Can this library read HEIC files?"

- Its body has three headings: "Question", "What depends on the answer" and "Done when". "Done when" asks for a comment with the answer, the evidence and a recommendation.
- It has the `research` label. Each issue that depends on the answer is blocked by it.
- A builder answers it in a comment, without a pull request. If the answer changes what the blocked issues ask for, the builder adds `needs-decision` to the research issue, so the owner decides before anything that depends on it is built.

## Definition of ready

An issue can join a milestone when all of these are true:

- It asks for one change that fits in one pull request.
- "Why" says who needs the change and what for.
- Someone could check each "Done when" item by running or looking at something. Where quality matters, such as accuracy or speed, the item gives a number that the owner chose or approved.
- Nothing is left to decide, except a question that a research issue blocking it will answer. The issue has no "maybe", no "to be decided" and no "A or B".
- "What should change" says what's out of scope wherever a builder might do more.
- It respects the project's decisions in AGENTS.md.
- It's blocked by every issue whose change it needs first.
- It has one type label and no status label.

A research issue is ready when its question and what depends on the answer are clear.

## Plan a release

A release is a milestone of ready issues. Plan the whole release before anyone builds it, so that an agent can build it in one run.

1. Agree on the goal with the owner: what a user can do after the release that they can't do now.
2. Triage anything new, including open issues that need triage.
3. Choose the version, such as `v0.2.0`. It also names the milestone, and the commands below show it as `<version>`. A first release is `v0.1.0`. After that, raise the patch number for a release with only fixes, the minor number for new features, and the major number for a change that breaks existing use. Before version 1.0, a breaking change raises the minor number instead.
4. Choose the backlog issues that the goal needs, and leave out the rest. Add research issues for what someone has to find out, and break down any big issue you chose. Issues that you create here with the owner don't need triage, because the owner reviews them in step 8.
5. Make every issue meet the definition of ready. Then have a fresh reader check each one. Start a new agent without your conversation, let it read the code, and give it the issue with this prompt: "You're about to build this issue. You can read the code, but you know nothing else. List everything you'd have to guess." Fix what it lists, and ask the owner about anything that's their decision.
6. Create the milestone, then add each issue to it. `gh` fills in `{owner}` and `{repo}`:
   `gh api repos/{owner}/{repo}/milestones -f title=<version> -f description="<goal>"`
   `gh issue edit <issue> --milestone <version>`
7. Link each issue to the issues whose change it needs first, with `gh issue edit <issue> --add-blocked-by <other issue>`. Link only real dependencies, because a blocked issue waits until all its blockers are closed. Every blocker must be in the milestone or already closed. Among issues with no open blockers, a builder takes the lowest number first, so only the links decide the order.
8. Ask the owner to review the milestone before anyone builds it.
