---
paths:
  - ".claude/agents/**"
---

# Agent / Subagent Creation Reference

When creating or modifying a subagent definition, follow this reference.

## File Format

Subagent files are Markdown with YAML frontmatter in `.claude/agents/<name>.md`.
The frontmatter is configuration; the markdown body becomes the subagent's system prompt.

## Required Fields

| Field | Type | Notes |
|---|---|---|
| `name` | string | Lowercase letters and hyphens only. Must be unique. |
| `description` | string | How Claude decides when to delegate. Be specific about trigger phrases. Include "Use proactively" to encourage auto-delegation. |

## Optional Fields

| Field | Default | Values |
|---|---|---|
| `model` | `inherit` | `sonnet`, `opus`, `haiku`, `inherit`, or full model ID |
| `tools` | Inherits all | Comma-separated allowlist: `Read, Grep, Glob, Bash` |
| `disallowedTools` | None | Denylist applied before `tools`. Deny always wins. |
| `maxTurns` | Unlimited | Integer. Cap agentic turns to prevent runaway. |
| `permissionMode` | `default` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `memory` | Disabled | `user` (global), `project` (versioned), `local` (gitignored) |
| `background` | `false` | `true` to always run as background task |
| `effort` | Inherits | `low`, `medium`, `high`, `max` |
| `isolation` | None | `worktree` — runs in temporary isolated git worktree |
| `skills` | None | List of skill names to preload into subagent context |
| `mcpServers` | None | MCP servers (inline definition or reference by name) |
| `hooks` | None | Lifecycle hooks scoped to this subagent only |
| `initialPrompt` | None | Auto-submitted first turn when used as main agent via `--agent` |

## Design Principles

1. **One job per agent.** Each subagent should excel at one specific task.
2. **Minimum tools.** Grant only the permissions necessary. Read-only agents should NOT have Write or Edit.
3. **Descriptive triggers.** Claude uses the `description` field to decide delegation — front-load the key use case and trigger phrases.
4. **Structured output.** Define an explicit output format (severity levels, file:line references, code snippets).
5. **No nesting.** Subagents cannot spawn other subagents. Chain from the main conversation if needed.
6. **Memory for learning.** Use `memory: project` for agents that benefit from cross-session knowledge (reviewers, auditors).
7. **Guard rails.** Use `maxTurns` to prevent runaway. Use `permissionMode: plan` for exploration-only agents.

## When to Use Subagents vs. Skills

| Use subagents when | Use skills when |
|---|---|
| Task produces verbose output (logs, test runs) | You want a reusable prompt/workflow |
| You need tool restrictions or isolation | Task should run in the main conversation context |
| Work is self-contained and returns a summary | Task needs back-and-forth with the user |
| You want parallel independent investigations | Latency matters (subagents start fresh) |

## Tool Syntax

```yaml
# Allowlist — only these tools available
tools: Read, Grep, Glob

# Denylist — inherit all except these
disallowedTools: Write, Edit

# Restrict which subagents can be spawned (only for --agent main thread)
tools: Agent(worker, researcher), Read, Bash

# Bash with pattern restriction
tools: Read, Bash(grep *), Bash(find *)
```

## Memory Setup

```yaml
# Project-scoped (recommended) — stored in .claude/agent-memory/<name>/
memory: project

# User-scoped — stored in ~/.claude/agent-memory/<name>/
memory: user

# Local (gitignored) — stored in .claude/agent-memory-local/<name>/
memory: local
```

When memory is enabled, include instructions in the body:
- "Check your memory for relevant patterns before starting"
- "After completing, save key learnings to memory"

## Hooks in Subagents

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

## Anti-Patterns

- **Too many tools.** Don't give a reviewer Write/Edit access — it blurs the role.
- **Vague description.** "Helps with code" won't trigger delegation. Be specific: "Use when the user says 'review', 'check my code', or after completing a feature."
- **Giant system prompt.** Keep the body focused. Move reference docs to skills with `skills:` field.
- **No output format.** Without a defined format, subagent output is inconsistent and hard to act on.
- **Missing maxTurns.** Unbounded agents can loop indefinitely on ambiguous tasks.
- **Using bypassPermissions casually.** Reserve for trusted, well-tested agents only.

## Template

```markdown
---
name: [CUSTOMIZE]
description: >
  [CUSTOMIZE] What this agent does. Include trigger phrases.
  Use when the user says "...", "...", or when [scenario].
model: sonnet
tools: [CUSTOMIZE] Minimum needed tools
maxTurns: [CUSTOMIZE] 15-25 typical
memory: project
---

You are a [CUSTOMIZE role] specializing in [CUSTOMIZE domain].

## When Invoked

1. [CUSTOMIZE] First action
2. [CUSTOMIZE] Analysis step
3. [CUSTOMIZE] Output step

## Output Format

For each finding:
- **[SEVERITY]** — `file:line` — description
- Code snippet showing the issue
- Concrete fix recommendation

End with a summary and actionable next steps.
```
