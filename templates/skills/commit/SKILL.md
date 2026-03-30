---
name: commit
description: Stage changes, generate a conventional commit message, and commit.
argument-hint: "[optional: override commit message]"
disable-model-invocation: true
allowed-tools: Read, Bash
---

## Current Changes

!`git status --short`

## Diff Summary

!`git diff --stat`

## Detailed Changes

!`git diff`

Based on the changes above:

1. Stage all modified/added files (excluding .env, secrets, build artifacts)
2. Generate a conventional commit message: `type(scope): description`
   - `feat` for new features
   - `fix` for bug fixes
   - `refactor` for code restructuring
   - `docs` for documentation
   - `test` for test additions/changes
   - `chore` for maintenance tasks
   - `ci` for CI/CD changes
3. If the user provided a message via $ARGUMENTS, use that instead
4. Show the commit message and ask for confirmation before committing
5. Do NOT push — let the user decide when to push
