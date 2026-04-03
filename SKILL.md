---
name: claude-forge
description: >
  Bootstrap the complete .claude/ directory structure for any new project with
  replicable templates, CLAUDE.md, rules, skills, agents, hooks, and settings.
  Use this skill whenever the user says "bootstrap project", "mount project structure",
  "setup claude code", "initialize .claude", "start new project", "monte a estrutura
  do projeto", "prepare project for claude code", "scaffold claude config", or any
  variation asking to set up Claude Code configuration for a new or existing codebase.
  Also trigger when the user asks to "create CLAUDE.md template", "setup skills", or
  wants a replicable project skeleton. Supports stack-specific variants including
  flask-next, node, python, react, and rust. Supports architecture presets: mvp
  (monolith, Supabase+Vercel) or production (multi-service, Terraform, AWS/GCP).
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "[stack] [--preset mvp|production]"
---

# Claude Forge — Project Bootstrap

Scaffold a complete `.claude/` directory with production-ready templates, security hooks, IaC, and architecture rules.

## What Gets Generated

### Core Structure
- **CLAUDE.md** — project-specific instructions (stack-tailored, < 200 lines)
- **settings.json** — permissions (allow/deny) + hooks configuration
- **rules/** — code-style, testing, security, git-workflow, agent-creation + stack/preset rules

### Skills (slash commands)
| Skill | Description |
|-------|-------------|
| `/commit` | Conventional commit with auto-generated message |
| `/fix-issue` | Fix a GitHub issue by number |
| `/review` | Code review current branch |
| `/spec` | Interview → detailed SPEC.md |
| `/spec-build` | Build from spec using Agent Teams (parallel backend+frontend) |
| `/checkpoint` | Save verified snapshot (tests + git tag + context for session continuity) |
| `/security-audit` | OWASP Top 10 structured security review |
| `/infra-audit` | Terraform, Docker, CI/CD configuration review |
| `/pentest-recon` | Passive attack surface mapping from codebase |

### Agents (12 total)
code-reviewer, debugger, test-writer, refactorer, doc-writer, security-auditor, orchestrator, api-developer, frontend-developer, ux-designer, frontend-design

### Hooks (7 total)
| Hook | Trigger | Action |
|------|---------|--------|
| validate-bash | PreToolUse (Bash) | Blocks destructive/exfiltration commands |
| secret-scan | PreToolUse (git commit) | Blocks commits with hardcoded secrets |
| auto-format | PostToolUse (Edit/Write) | Runs stack formatter on modified files |
| sast-scan | PostToolUse (Edit/Write) | Flags injection, eval, weak crypto, disabled TLS |
| dependency-check | PostToolUse (Edit/Write) | Warns on insecure deps in package files |
| teammate-idle | TeammateIdle | Notifies when agent team member is idle |
| task-completed | TaskCompleted | Post-task notifications |

### Architecture Presets (orthogonal to stacks)
| Preset | What it adds |
|--------|-------------|
| **mvp** | Monolith rules, docker-compose (Postgres+Redis), GitHub Actions CI |
| **production** | Multi-service rules, Terraform (VPC+RDS+ECS Fargate), Dockerfile (multi-stage), docker-compose (Postgres+Redis+LocalStack), GitHub Actions CI+Deploy pipeline |

## Workflow

### Step 1: Detect or Ask for Stack

If the user provided a stack argument (e.g., `/claude-forge react`), use it.

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

### Step 2: Detect or Ask for Preset

If the user specified `--preset mvp` or `--preset production`, use it.

Otherwise, ask ONE question:

> Do you want an architecture preset? Options: mvp (monolith, Supabase+Vercel), production (multi-service, Terraform, AWS/GCP), or none (skip)

### Step 3: Run the Bootstrap Script

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/bootstrap.sh" "$(pwd)" "<stack>" "<preset>"
```

The script:
1. Creates the `.claude/` directory tree (rules, agents, hooks, skills, checkpoints)
2. Copies base templates (rules, skills, agents, hooks, settings)
3. Overlays stack-specific files from `stacks/<stack>/`
4. Applies architecture preset from `presets/<preset>/` (rules, settings, IaC templates)
5. Appends preset architecture snippet to CLAUDE.md
6. Generates the `.claude/.gitignore` and updates root `.gitignore`
7. Never overwrites existing files (safe to re-run)

### Step 4: Generate CLAUDE.md

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

### Step 5: Adapt settings.json

Merge permissions from multiple sources:
- `templates/settings.json.template` — base permissions + security hooks
- `stacks/<stack>/settings.json.override` — stack-specific tools (npm, pip, cargo)
- `presets/<preset>/settings.json.override` — preset-specific tools (terraform, docker)

### Step 6: Present Summary

Show the user:
1. Directory tree created
2. Files marked `[CUSTOMIZE]` that need attention
3. Available skills (all 9)
4. Available agents (all from `.claude/agents/`)
5. Security hooks active by default
6. IaC files generated (if preset selected)
7. Recommended workflow:
   - `/spec <feature>` → write spec via interview
   - `/spec-build` → implement from spec with Agent Teams
   - `/checkpoint` → save verified snapshot
   - `/security-audit` → OWASP review before release

## Principles

- **Under 200 lines** for CLAUDE.md — overflow goes to `.claude/rules/`
- **Progressive disclosure** — use `@references`, don't dump everything in context
- **Security by default** — hooks block secrets and flag vulnerabilities automatically
- **Deterministic safety** — hooks block dangerous commands 100% of the time
- **Git-friendly** — personal files are gitignored, team files are committed
- **Non-destructive** — never overwrites existing files, safe to re-run
- **Stack + Preset** — orthogonal dimensions: stack = technology, preset = architecture

## Reference Files

- `templates/` — Base templates (stack-agnostic)
- `stacks/<stack>/` — Stack-specific overrides and additions
- `presets/<preset>/` — Architecture presets (rules, IaC, settings)
- `scripts/bootstrap.sh` — Main scaffolding script
- See @README.md for installation and usage docs
