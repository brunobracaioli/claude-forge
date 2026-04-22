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
  django, flask-next, go, laravel, node, python, react, and rust. Supports
  architecture presets: mvp (monolith, Supabase+Vercel), production-aws
  (multi-service, Terraform, AWS: VPC + RDS + ECS Fargate), or production-gcp
  (multi-service, Terraform, GCP: VPC + Cloud SQL + Cloud Run, WIF-based CI/CD).
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "[stack] [--preset mvp|production-aws|production-gcp] [--tier core|full] [--update]"
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

### Agents (tiered — 5 core by default, 15 total)

**Core tier** (installed by default, satisfies the "start with 3-5 teammates" guideline):
code-reviewer, debugger, test-writer, security-auditor, orchestrator

**Extended tier** (install with `--tier full`):
api-developer, codebase-navigator, doc-writer, frontend-design, frontend-developer, project-planner, refactorer, spec-writer, ux-designer, web-researcher

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
| **production-aws** | Multi-service rules, Terraform (VPC + RDS + ECS Fargate), multi-stage Dockerfile, docker-compose (Postgres+Redis+LocalStack), GitHub Actions CI + ECR/ECS deploy pipeline |
| **production-gcp** | Multi-service rules, Terraform (VPC + Cloud SQL + Cloud Run, WIF-ready), multi-stage Dockerfile, docker-compose (Postgres+Redis), GitHub Actions CI + Cloud Run deploy via Workload Identity Federation (no JSON keys) |
| **production** | Deprecated alias for `production-aws` — will be removed in v2.0 |

## Workflow

### Step 1: Detect or Ask for Stack

If the user provided a stack argument (e.g., `/claude-forge react`), use it.

Otherwise, scan the current directory for clues:

```
artisan                                      → laravel
manage.py                                    → django
go.mod                                       → go
next.config.* + requirements.txt/pyproject  → flask-next
next.config.*                                → react
package.json                                 → node
Cargo.toml                                   → rust
requirements.txt / pyproject.toml / setup.py → python
(nothing matches)                            → generic
```

If detection is ambiguous, ask ONE question:

> What's the primary stack? Options: django, flask-next, go, laravel, node, python, react, rust, generic

### Step 2: Detect or Ask for Preset

If the user specified `--preset <name>`, use it.

Otherwise, ask ONE question:

> Do you want an architecture preset? Options: mvp (monolith, Supabase+Vercel), production-aws (Terraform + ECS Fargate + RDS), production-gcp (Terraform + Cloud Run + Cloud SQL, WIF-based CI), or none (skip)

### Step 3: Run the Bootstrap Script

```bash
# First install (default core agent tier):
bash "${CLAUDE_SKILL_DIR}/scripts/bootstrap.sh" "$(pwd)" "<stack>" "<preset>"

# Install all 15 agents:
bash "${CLAUDE_SKILL_DIR}/scripts/bootstrap.sh" "$(pwd)" "<stack>" "<preset>" --tier full

# Re-run after claude-forge update to refresh unmodified templates:
bash "${CLAUDE_SKILL_DIR}/scripts/bootstrap.sh" "$(pwd)" "<stack>" "<preset>" --update
```

The script:
1. Creates the `.claude/` directory tree (rules, agents, hooks, skills, checkpoints)
2. Copies base templates (rules, skills, agents, hooks, settings)
3. Overlays stack-specific files from `stacks/<stack>/`
4. Applies architecture preset from `presets/<preset>/` (rules, settings, IaC templates)
5. Appends preset architecture snippet to CLAUDE.md
6. Generates the `.claude/.gitignore` and updates root `.gitignore`
7. Never overwrites existing files unless `--update` is passed AND the file hash matches the shipped version
8. In `--update` mode, files modified locally are preserved and the new version is written as `<file>.new` alongside

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
- **Non-destructive by default** — never overwrites existing files; `--update` refreshes only unmodified templates (hash-matched against `manifest.json`) and writes new versions as `.new` sidecars otherwise
- **Stack + Preset** — orthogonal dimensions: stack = technology, preset = architecture

## Reference Files

- `templates/` — Base templates (stack-agnostic)
- `stacks/<stack>/` — Stack-specific overrides and additions
- `presets/<preset>/` — Architecture presets (rules, IaC, settings)
- `scripts/bootstrap.sh` — Main scaffolding script
- See @README.md for installation and usage docs
