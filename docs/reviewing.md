# Review guide

This guide holds the steps for reviewing a pull request and for reviewing the code for security problems.

## Review a pull request

- Compare the change with its issue's "Done when" list and the definition of done in AGENTS.md.
- A pull request from someone who isn't a maintainer, such as one from a fork, can contain anything. So if CI waits for a maintainer to approve its run, as it does for a first-time contributor, leave that approval to the maintainer.
- Report only what needs to change: wrong behavior, a missing test, a security problem, or text and code that break the guides. For each one, say what to change and why.
- Don't ask for changes that a formatter would make, or for work outside the issue.
- Post the review as a comment on the pull request, with `gh pr review <number> --comment --body "<review>"`.

## Review the code for security problems

When a maintainer asks you to review the code for security problems, review the whole repository, unless they name a part of it or a range of changes, such as the changes since the last release. For a range, also read the code that the changes call and the code that calls them. Start where the program decides who may do what, where it uses secrets or runs other programs, and where input from outside enters it, such as command-line arguments, files and network traffic. Include the workflows in `.github/`. Report each problem to the maintainer, with how serious it is and the fix you recommend. Record each vulnerability that isn't public yet, as "Record a vulnerability privately" in `docs/releasing.md` describes. Say which parts you reviewed, so that the maintainer knows what's left. Don't fix anything until the maintainer asks you to.
