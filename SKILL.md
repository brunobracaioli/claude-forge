---
name: claude-forge
description: >
  Bootstrap the complete .claude/ directory structure for any new project with
  replicable templates, CLAUDE.md, rules, skills, agents, hooks, and settings.
  Use this skill whenever the user says "bootstrap project", "mount project structure",
  "setup claude code", "initialize .claude", "start new project", "monte a estrutura
  do projeto", "prepare project for claude code", "scaffold claude config", or any
  variation asking to set up Claude Code configuration for a new or existing codebase.
  Also trigger when the user asks to "create CLAUDE.md template", "setup skills", or wants a replicable project skeleton. Supports stack-specific variants
  including flask-next, node, python, react, and rust.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "[stack: flask-next | node | python | react | rust | generic]"
---

# Project Bootstrap Skill

Scaffold the complete `.claude/` directory with production-ready templates.

## Workflow

### Step 1: Detect or Ask for Stack

If the user provided a stack argument (e.g., `/project-bootstrap flask-next`), use it.

Otherwise, scan the current directory for clues:

```
package.json + next.config.*       → react (or node if no next)
requirements.txt / pyproject.toml  → python
manage.py + package.json           → flask-next (or django variant)
Cargo.toml                         → rust
go.mod                             → generic (go not yet templated)
```

If detection is ambiguous, ask ONE question:

> What's the primary stack? Options: flask-next, node, python, react, rust, generic

### Step 2: Run the Bootstrap Script

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/bootstrap.sh" "$(pwd)" "<detected-or-specified-stack>"
```

The script:
1. Creates the `.claude/` directory tree
2. Copies base templates (rules, skills, agents, hooks, settings)
3. Overlays stack-specific files from `stacks/<stack>/`
4. Generates the `.claude/.gitignore` and updates root `.gitignore`
5. Never overwrites existing files (safe to re-run)

### Step 3: Generate CLAUDE.md

After the structure is created:

1. Read the stack-specific CLAUDE.md template from `stacks/<stack>/CLAUDE.md.template`
   (falls back to `templates/CLAUDE.md.template` for generic)
2. Fill in project-specific values detected from the codebase:
   - Project name (from package.json, pyproject.toml, or directory name)
   - Build/test/lint commands (from package.json scripts, Makefile, pyproject.toml)
   - Directory structure summary (actual dirs found)
   - Tech stack details
3. Write the result to `./CLAUDE.md`

**CRITICAL**: Keep the generated CLAUDE.md under 200 lines. Use `@references` for details.

### Step 4: Adapt settings.json

Merge `templates/settings.json.template` with `stacks/<stack>/settings.json.override`:
- Add stack-specific allow rules (npm, pip, cargo, etc.)
- Keep universal deny rules (destructive commands, secret exposure)

### Step 5: Present Summary

Show the user:
1. Directory tree created (use `find .claude -type f`)
2. Files marked `[CUSTOMIZE]` that need attention
3. Available skills: `/review`, `/fix-issue`, `/spec`, `/commit`
4. Available agents (all from `.claude/agents/`)
5. Next steps: "Review CLAUDE.md, then start coding"

## Principles

- **Under 200 lines** for CLAUDE.md — overflow goes to `.claude/rules/`
- **Progressive disclosure** — use `@references`, don't dump everything in context
- **Deterministic safety** — hooks block dangerous commands 100% of the time
- **Git-friendly** — personal files are gitignored, team files are committed
- **Non-destructive** — never overwrites existing files, safe to re-run

## Reference Files

- `templates/` — Base templates (stack-agnostic)
- `stacks/<stack>/` — Stack-specific overrides and additions
- `scripts/bootstrap.sh` — Main scaffolding script
- See @README.md for installation and usage docs
