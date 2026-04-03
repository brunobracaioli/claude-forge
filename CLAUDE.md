# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Claude Forge is a Claude Code skill/plugin that scaffolds a complete `.claude/` directory for any project. It generates CLAUDE.md, rules, skills (slash commands), agents, hooks, and settings from templates — with stack-specific presets, security hooks, IaC generation, and architecture rules.

## Key Commands

```bash
# Install as global skill (no git repo linked)
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash

# Run bootstrap on a target project
bash scripts/bootstrap.sh <project_root> <stack> <preset>
# Stacks: flask-next | node | python | react | rust | generic | auto
# Presets: mvp | production | none (default: none)
```

## Architecture

The skill is invoked via `/claude-forge <stack> [--preset mvp|production]` or natural language. The workflow:

1. **SKILL.md** defines the trigger phrases and orchestration steps
2. **scripts/bootstrap.sh** does the actual file scaffolding (safe_copy never overwrites)
3. **templates/** contains stack-agnostic base files (rules, skills, agents, hooks, settings)
4. **stacks/<stack>/** contains stack-specific overrides (CLAUDE.md.template, settings.json.override, extra rules)
5. **presets/<preset>/** contains architecture presets (rules, CLAUDE.md snippet, IaC templates, settings override)
6. Settings merging requires `jq` — stack and preset permissions are merged into the base settings.json

## Project Structure

```
scripts/bootstrap.sh       # Main scaffolding script (auto-detect, safe_copy, merge)
templates/                 # Base templates copied to every project
  CLAUDE.md.template       # Generic CLAUDE.md with [CUSTOMIZE] markers
  settings.json.template   # Base permissions (allow/deny) + all hooks wired
  rules/                   # code-style, testing, security, git-workflow, agent-creation
  skills/                  # Slash commands (10 skills)
    commit/SKILL.md        # /commit — conventional commit
    fix-issue/SKILL.md     # /fix-issue — GitHub issue fix
    review/SKILL.md        # /review — code review
    spec/SKILL.md          # /spec — feature spec interview
    spec-build/SKILL.md    # /spec-build — build from spec (Agent Teams + security + checkpoint)
    checkpoint/SKILL.md    # /checkpoint — dev snapshot (tests + tag + context)
    security-audit/SKILL.md # /security-audit — OWASP Top 10 review
    infra-audit/SKILL.md   # /infra-audit — Terraform/Docker/CI review
    pentest-recon/SKILL.md # /pentest-recon — passive attack surface mapping
    example-skill/SKILL.md # Skeleton for user-defined skills
  agents/                  # 13 agents: code-reviewer, debugger, test-writer, refactorer,
                           #   doc-writer, security-auditor, orchestrator, api-developer,
                           #   frontend-developer, ux-designer, frontend-design, web-researcher
  hooks/                   # 7 hooks: validate-bash, auto-format, teammate-idle,
                           #   task-completed, secret-scan, sast-scan, dependency-check
presets/                   # Architecture presets (orthogonal to stacks)
  mvp/                     # Monolith, Supabase+Vercel+Upstash
    rules/architecture.md  # MVP architecture rules
    CLAUDE.md.snippet      # Appended to project CLAUDE.md
    templates/             # docker-compose.yml, .github/workflows/ci.yml
  production/              # Multi-service, Terraform, AWS/GCP
    rules/architecture.md  # Production architecture rules
    CLAUDE.md.snippet      # Appended to project CLAUDE.md
    settings.json.override # Terraform/Docker permissions
    templates/             # terraform/ (VPC+RDS+ECS modules), Dockerfile,
                           #   docker-compose.yml, .github/workflows/{ci,deploy}.yml
stacks/<stack>/            # Stack-specific overlays
  CLAUDE.md.template       # Stack-tailored CLAUDE.md (< 60 lines)
  settings.json.override   # Additional allow/deny rules merged via jq
  rules/                   # Stack-specific convention rules
plugin.json                # Claude Code plugin manifest
SKILL.md                   # Skill definition with trigger phrases and workflow
install.sh                 # One-liner installer (clone or copy to ~/.claude/skills/)
```

## Conventions

- CLAUDE.md templates must stay under 60 lines (base adds ~20 more); total output under 200 lines
- All generated files use `[CUSTOMIZE]` markers where project-specific values are needed
- `safe_copy` in bootstrap.sh ensures existing files are never overwritten (non-destructive re-runs)
- Stack detection logic lives in `auto_detect_stack()` in bootstrap.sh
- New stacks: create `stacks/<name>/` with CLAUDE.md.template, settings.json.override, and rules/<name>-conventions.md, then add detection pattern to `auto_detect_stack()`
- Presets are orthogonal to stacks: stack = technology, preset = architecture. Both are applied during bootstrap (stack first, then preset overlay)
- New presets: create `presets/<name>/` with rules/architecture.md, CLAUDE.md.snippet, and optionally settings.json.override + templates/
- Security hooks are always active — secret-scan blocks commits, sast-scan and dependency-check warn on writes
- Spec-build flow: `/spec` → `/spec-build` → `/checkpoint` — includes security validation before checkpoint
