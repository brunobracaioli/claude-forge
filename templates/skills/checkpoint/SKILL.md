---
name: checkpoint
description: >
  Create a development checkpoint: run tests, commit clean state, tag with version,
  and save context summary for session continuity. Use when you want to mark a stable
  point in development before switching context, ending a session, or starting a risky change.
  Trigger phrases: "checkpoint", "save progress", "mark stable", "create checkpoint",
  "snapshot", "save state", "forge checkpoint".
argument-hint: "[optional: checkpoint label, e.g. 'auth-complete']"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Development Checkpoint

Create a verified, tagged snapshot of the current project state.

## Workflow

### Step 1: Run Tests

Run the project's test suite to verify current state is stable:

```bash
# Auto-detect test command from project files
# Check in order: package.json scripts.test, Makefile test, pytest, cargo test
```

Detection priority:
1. `package.json` → `npm test`
2. `Makefile` with `test` target → `make test`
3. `pyproject.toml` or `pytest.ini` or `tests/` dir → `pytest`
4. `Cargo.toml` → `cargo test`

If tests fail, STOP and report. Do not create a checkpoint on failing tests.
If no test runner is detected, warn the user and ask whether to proceed without tests.

### Step 2: Stage and Commit

If there are uncommitted changes:

1. Stage all relevant files (exclude .env, secrets, build artifacts, node_modules)
2. Create a commit with message: `checkpoint: <label or auto-summary>`
3. If the user provided $ARGUMENTS, use it as the label

If the working tree is clean, skip this step.

### Step 3: Create Git Tag

Generate a tag name based on the current state:

```
Format: checkpoint/<date>/<label-or-sequence>
Example: checkpoint/2025-03-31/auth-complete
Example: checkpoint/2025-03-31/003
```

- Use $ARGUMENTS as label if provided
- Otherwise, auto-increment sequence number for the day
- Create an annotated tag with a summary message

```bash
git tag -a "checkpoint/<date>/<label>" -m "Checkpoint: <summary of current state>"
```

### Step 4: Save Context Summary

Write a context file to `.claude/checkpoints/<tag-name>.md` with:

```markdown
# Checkpoint: <label>
Date: <ISO timestamp>
Tag: <git tag>
Commit: <short hash>
Branch: <current branch>

## State Summary
<2-3 sentence description of what's been accomplished since last checkpoint or session start>

## Recent Changes
<git log --oneline of last 5-10 commits since previous checkpoint tag>

## Current Focus
<what the developer was working on — inferred from recent commits and staged changes>

## Next Steps
<what logically comes next — inferred from TODOs, open issues, or conversation context>

## Test Status
<pass/fail count from test run, or "no tests detected">
```

### Step 5: Report

Show the user:
1. Test results (pass/fail)
2. Commit hash and message
3. Tag name
4. Context file path
5. How to restore: `git checkout <tag>` or `git stash && git checkout <tag>`
6. How to resume: "Start next session by reading `.claude/checkpoints/<tag>.md`"

## Principles

- **Never checkpoint on failing tests.** A checkpoint means "this state is known-good."
- **Non-destructive.** Don't reset, amend, or force-push anything.
- **Session continuity.** The context file is the bridge between sessions — write it for a future Claude that has zero context.
- **Lightweight.** Don't over-engineer. A tag + context file is enough.
