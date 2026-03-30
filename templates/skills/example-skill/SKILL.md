---
name: example-skill
description: >
  [CUSTOMIZE] Describe what this skill does and WHEN Claude should auto-invoke it.
  Be specific about trigger phrases. Example: "Generate database migration files.
  Use when the user says 'create migration', 'add column', 'change schema',
  'migrate', or asks to modify the database structure."
# allowed-tools: Read, Write, Edit, Bash, Grep, Glob
# argument-hint: "[description of expected arguments]"
# context: fork          # Run in isolated subagent (keeps main context clean)
# agent: Explore         # Use built-in Explore agent (read-only)
# model: sonnet          # Override model for this skill
# user-invocable: false  # Only Claude can trigger, not the user
---

# [CUSTOMIZE] Skill Name

## When to Use

[CUSTOMIZE] Describe the scenario in plain language.

## Steps

1. [CUSTOMIZE] First step — what to do
2. [CUSTOMIZE] Second step — what to do
3. [CUSTOMIZE] Third step — what to do

## Supporting Files

Reference additional files with @syntax:
- Detailed config: @config-reference.md
- API docs: @api-reference.md

## Notes

- [CUSTOMIZE] Any gotchas or important context
- Skills support `!`backtick`` to inject shell output into the prompt
- Use `$ARGUMENTS` to capture user input after the skill name
- Use `${CLAUDE_SKILL_DIR}` to reference files relative to the skill directory
