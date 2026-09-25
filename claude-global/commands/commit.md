---
description: Commit the working tree as one or more conventional commits
argument-hint: [what the change is, if it needs saying]
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(git branch:*)
---

## State

Branch: !`git branch --show-current`

Status:
!`git status --short`

Shape of the change:
!`git diff HEAD --stat`

Recent subjects, for format and tone:
!`git log --oneline -15`

## Task

Commit what is in the working tree. $ARGUMENTS

Read the full diff before writing anything — `git diff HEAD` for tracked
changes, and `git diff --no-index /dev/null <file>` for new ones. The subject
line comes from what the change *does*, which the diff shows and the file
names usually do not.

**One commit per idea.** If the tree holds several unrelated changes, make
several commits and stage each one with explicit paths. Do not hyphenate two
subjects together to avoid splitting.

**Conventional commits**: `type(scope): subject`, imperative, no trailing
period. `feat` and `fix` for behaviour, `docs`, `refactor`, `test`, `chore`
otherwise. Scope is optional and names the area, not the file.

**The body explains why**, in prose, wrapped at 72 columns. What the diff
already shows does not need restating; what it cannot show — the constraint
behind the approach, the option rejected, the bug this avoids — does. Omit
the body when there is genuinely nothing to add.

Before staging, check the diff for anything that should never be committed:
credentials, tokens, keys, `.env` contents, internal hostnames. Stop and say
so rather than committing it.

Do not push, and do not add files the change does not need.
