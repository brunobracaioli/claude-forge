---
name: review
description: Review current branch diff against main for issues before merging.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash
---

## Changed Files

!`git diff --name-only main...HEAD 2>/dev/null || git diff --name-only HEAD~5`

## Full Diff

!`git diff main...HEAD 2>/dev/null || git diff HEAD~5`

Review every changed file for:

1. **Bugs**: logic errors, off-by-one, null/undefined access, race conditions
2. **Security**: SQL injection, secret exposure, missing auth checks, unsanitized input
3. **Tests**: missing coverage for new code, untested edge cases
4. **Performance**: N+1 queries, unnecessary loops, missing indexes, large payloads
5. **Error handling**: swallowed errors, generic catches, missing fallbacks
6. **Style**: naming, readability, dead code, consistency with codebase patterns

For each issue found:
- Classify as **BLOCKER** (must fix) or **SUGGESTION** (nice to have)
- Show the exact file and line
- Provide a concrete fix, not just a description
