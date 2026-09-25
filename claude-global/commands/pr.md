---
description: Open a pull request for the current branch
argument-hint: [extra context for the description]
allowed-tools: Bash(git:*), Bash(gh:*)
---

## State

Branch: !`git branch --show-current`

Commits not on the default branch:
!`git log --oneline "$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)"..HEAD 2>/dev/null || git log --oneline -10`

Uncommitted work still in the tree:
!`git status --short`

## Task

Open a pull request for this branch. $ARGUMENTS

Stop and ask first if any of these are true, rather than deciding alone:

- The working tree is dirty — those changes would be left out.
- The branch is the default branch, so there is nothing to open a PR from.
- `gh auth status` reports no authenticated host.

Push the branch with `-u` if it has no upstream, then `gh pr create`.

Write the description from the commits, not from the diff: a short paragraph
on what changes and why, then bullets only where they earn their place. Call
out anything a reviewer would otherwise have to discover — a behaviour change,
a migration, a dependency added, a decision that could reasonably have gone
the other way. If the change is user-visible and no documentation moved with
it, say so in the PR rather than quietly leaving it.

Title follows the same conventional-commit format as the commits.

Report the PR URL when it exists.
