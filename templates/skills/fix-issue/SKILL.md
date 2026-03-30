---
name: fix-issue
description: Investigate and fix a GitHub issue by number.
argument-hint: <issue-number>
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

## Issue Details

!`gh issue view $ARGUMENTS --json title,body,labels,comments 2>/dev/null || echo "Could not fetch issue $ARGUMENTS. Ensure 'gh' CLI is installed and authenticated."`

## Investigation Steps

1. Read the issue description and comments carefully
2. Search the codebase for related files using Grep/Glob
3. Trace the root cause — don't just fix symptoms
4. Check if there's an existing test that should have caught this

## Implementation

1. Create a feature branch: `fix/$ARGUMENTS-<short-desc>`
2. Write or update a test that reproduces the bug
3. Implement the fix — minimal, focused change
4. Run the test suite to confirm no regressions
5. Summarize what was wrong and what you changed
