<p align="center">
  <img src="docs/assets/banner.svg" alt="Claude Forge — Forge your .claude/ in one command" width="100%">
</p>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <img src="https://img.shields.io/badge/stacks-6-f59e0b.svg?style=flat-square" alt="Stacks">
  <img src="https://img.shields.io/badge/presets-2-ef4444.svg?style=flat-square" alt="Presets">
  <img src="https://img.shields.io/badge/templates-60%2B%20files-8b5cf6.svg?style=flat-square" alt="Templates">
  <img src="https://img.shields.io/badge/claude--code-skill-10b981.svg?style=flat-square" alt="Claude Code Skill">
</p>

<p align="center">
  <strong>One command to scaffold the complete <code>.claude/</code> directory for Claude Code.</strong><br>
  Templates, rules, skills, agents, hooks, security scanning, architecture presets, and IaC.<br>
  Stop rebuilding — start building.
</p>

<p align="center">
  🇧🇷 <a href="./README.pt-br.md">Leia em Português</a>
</p>

---

## ⚡ Quick Start

```bash
# Install once (global skill)
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash

# Use in any project
cd your-project
```

Then inside Claude Code:

```
/claude-forge react --preset mvp
```

Or just ask naturally:

> *"Set up the .claude directory for this project with production preset"*

---

## 🎯 What You Get

A single command creates **60+ files** across 8 categories:

| | Component | What's Inside |
|---|---|---|
| 📄 | **CLAUDE.md** | Stack-specific template with `[CUSTOMIZE]` markers, under 200 lines |
| 📏 | **Rules** (5+) | `code-style` · `testing` · `security` · `git-workflow` · `agent-creation` + stack + preset rules |
| ⚡ | **Skills** (10) | `/review` · `/fix-issue` · `/spec` · `/spec-build` · `/commit` · `/checkpoint` · `/security-audit` · `/infra-audit` · `/pentest-recon` |
| 🤖 | **Agents** (15) | `code-reviewer` · `security-auditor` · `debugger` · `test-writer` · `refactorer` · `doc-writer` · `orchestrator` · `api-developer` · `frontend-developer` · `ux-designer` · `frontend-design` · `web-researcher` · `codebase-navigator` · `project-planner` · `spec-writer` |
| 🔒 | **Hooks** (7) | `validate-bash` · `secret-scan` · `sast-scan` · `dependency-check` · `auto-format` · `teammate-idle` · `task-completed` |
| ⚙️ | **Settings** | Sensible permissions with all hooks wired out-of-the-box |
| 🏗️ | **Presets** | `mvp` (monolith, Supabase+Vercel) or `production` (Terraform, AWS, Docker, CI/CD) |
| 📦 | **IaC** | Terraform modules, Dockerfile, docker-compose, GitHub Actions (preset-dependent) |

---

## 🏗️ Supported Stacks

Auto-detection scans your project files and picks the right preset:

| Stack | Detected By | Extra Rules |
|:---|:---|:---|
| **flask-next** | `requirements.txt` + `next.config.*` | API conventions, Flask patterns |
| **node** | `package.json` | Node/TypeScript conventions |
| **python** | `requirements.txt` / `pyproject.toml` | Python conventions, type hints |
| **react** | `next.config.*` (no Python files) | React/Next.js conventions, a11y |
| **rust** | `Cargo.toml` | Rust conventions, error handling |
| **generic** | *(fallback)* | Base rules only |

> **Adding a stack is a PR away.** Django, Go, Java/Spring, PHP/Laravel, .NET — [contributions welcome](#-contributing).

---

## 🏛️ Architecture Presets

Presets are orthogonal to stacks — stack = technology, preset = architecture. Combine freely: `react + mvp` or `python + production`.

| Preset | Architecture | Infra | What Gets Generated |
|:---|:---|:---|:---|
| **mvp** | Monolith, fast iteration | Supabase + Vercel + Upstash | `docker-compose.yml`, GitHub Actions CI |
| **production** | Multi-service, domain-driven | AWS/GCP + Terraform | `terraform/` (VPC+RDS+ECS), `Dockerfile`, `docker-compose.yml`, CI+Deploy pipelines |
| **none** | *(default)* | No infra opinion | Only `.claude/` structure |

```
/claude-forge node --preset production
```

### MVP Preset
- Single deployable unit, no microservices
- Supabase for auth/DB/storage, Vercel for hosting, Upstash for Redis
- No Terraform, no Docker in production — platform-managed infra
- Docker Compose for local dev (Postgres + Redis)

### Production Preset
- Domain-driven boundaries with clear API contracts
- Terraform modules: VPC (public/private subnets, NAT), RDS Postgres (encrypted, Secrets Manager, multi-AZ), ECS Fargate (ALB, ECR with scan-on-push, circuit breaker rollback)
- Multi-stage Dockerfile (non-root, healthcheck)
- Docker Compose with LocalStack for AWS emulation
- GitHub Actions: CI (lint + test + Trivy SAST + Docker image scan) + Deploy (ECR push + ECS rolling deploy)

---

## 🔒 Security Hooks

Three security hooks run automatically on every scaffolded project — **active by default**, no configuration needed:

| Hook | Trigger | Action |
|:---|:---|:---|
| **secret-scan** | Before `git commit` | **Blocks** commits with hardcoded secrets. Uses gitleaks if installed, falls back to regex (AWS keys, GitHub tokens, private keys, JWTs, connection strings) |
| **sast-scan** | After Edit/Write | **Warns** about SQL injection, command injection, eval(), hardcoded IPs, disabled TLS, CORS wildcards, debug mode, weak crypto |
| **dependency-check** | After Edit/Write on package files | **Warns** about wildcard versions, git deps, unpinned deps. Runs `npm audit`/`pip-audit`/`cargo audit` if available |

Plus the existing safety hooks:

| Hook | Trigger | Action |
|:---|:---|:---|
| **validate-bash** | Before any Bash command | Blocks destructive commands (rm -rf), secret exposure, network exfiltration |
| **auto-format** | After Edit/Write | Runs stack formatter on modified files |
| **teammate-idle** | Agent Teams idle event | Keeps teammates working while tasks remain |
| **task-completed** | Agent Teams task event | Quality gate before closing tasks |

---

## 📦 Installation

Choose one:

### One-liner *(recommended)*

```bash
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash
```

### Manual download (no git required)

```bash
curl -sL https://github.com/brunobracaioli/claude-forge/archive/main.tar.gz | tar xz -C /tmp
mkdir -p ~/.claude/skills/claude-forge
cp -r /tmp/claude-forge-main/{SKILL.md,scripts,templates,stacks,presets} ~/.claude/skills/claude-forge/
chmod +x ~/.claude/skills/claude-forge/scripts/*.sh
rm -rf /tmp/claude-forge-main
```

### Claude Code Plugin

```
/plugins install claude-forge
```

> **Note:** Claude Forge is installed as a read-only skill — no git repository is linked. To update, simply re-run the installer.

---

## 📂 Generated Structure

```
your-project/
├── CLAUDE.md                          ← Team instructions (< 200 lines)
├── docker-compose.yml                 ← Local dev (preset-dependent)
├── Dockerfile                         ← Multi-stage build (production preset)
├── terraform/                         ← IaC modules (production preset)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/{vpc,database,compute}
├── .github/workflows/                 ← CI/CD pipelines (preset-dependent)
│   ├── ci.yml
│   └── deploy.yml                     ← (production preset only)
│
└── .claude/
    ├── settings.json                  ← Permissions + hooks
    ├── .gitignore                     ← Ignores personal files
    ├── checkpoints/                   ← Session continuity snapshots
    │
    ├── rules/                         ← Modular instructions
    │   ├── code-style.md
    │   ├── testing.md
    │   ├── security.md
    │   ├── git-workflow.md
    │   ├── agent-creation.md
    │   ├── architecture.md            ← (preset-dependent)
    │   └── <stack>-conventions.md     ← Stack-specific rules
    │
    ├── skills/                        ← Slash commands (10 total)
    │   ├── review/SKILL.md            ← /review
    │   ├── fix-issue/SKILL.md         ← /fix-issue <n>
    │   ├── spec/SKILL.md              ← /spec <feature>
    │   ├── spec-build/SKILL.md        ← /spec-build (Agent Teams)
    │   ├── commit/SKILL.md            ← /commit
    │   ├── checkpoint/SKILL.md        ← /checkpoint
    │   ├── security-audit/SKILL.md    ← /security-audit
    │   ├── infra-audit/SKILL.md       ← /infra-audit
    │   ├── pentest-recon/SKILL.md     ← /pentest-recon
    │   └── example-skill/SKILL.md     ← Template for your own
    │
    ├── agents/                        ← 15 agents
    │   ├── orchestrator.md
    │   ├── api-developer.md
    │   ├── frontend-developer.md
    │   ├── ux-designer.md
    │   ├── frontend-design.md
    │   ├── code-reviewer.md
    │   ├── security-auditor.md
    │   ├── debugger.md
    │   ├── test-writer.md
    │   ├── refactorer.md
    │   ├── doc-writer.md
    │   ├── web-researcher.md
    │   ├── codebase-navigator.md
    │   ├── project-planner.md
    │   └── spec-writer.md
    │
    └── hooks/                         ← 7 event-driven hooks
        ├── validate-bash.sh
        ├── secret-scan.sh
        ├── sast-scan.sh
        ├── dependency-check.sh
        ├── auto-format.sh
        ├── teammate-idle.sh
        └── task-completed.sh
```

---

## 🎨 Customization

All generated files with `[CUSTOMIZE]` markers need project-specific adjustments.

**Edit in this order** — highest impact first:

| Priority | File | Why |
|:---:|:---|:---|
| 1 | `CLAUDE.md` | Claude reads this every session. Get it right. |
| 2 | `.claude/settings.json` | Adjust allow/deny for your build tools. |
| 3 | `.claude/rules/` | Delete what doesn't apply, add what's missing. |
| 4 | `.claude/hooks/auto-format.sh` | Uncomment the formatter for your stack. |
| 5 | `terraform/variables.tf` | Fill in project-specific values (production preset). |
| 6 | `.claude/skills/` | Add project-specific workflows. |

<details>
<summary><strong>Adding a new skill</strong></summary>

```bash
mkdir -p .claude/skills/deploy
cat > .claude/skills/deploy/SKILL.md << 'EOF'
---
name: deploy
description: Deploy to staging or production
argument-hint: "[staging|production]"
disable-model-invocation: true
allowed-tools: Bash
---
Deploy to $ARGUMENTS environment...
EOF
```

This creates `/deploy` automatically.

</details>

<details>
<summary><strong>Adding a new agent</strong></summary>

```bash
cat > .claude/agents/db-explorer.md << 'EOF'
---
name: db-explorer
description: Explore database schema and data
model: haiku
tools: Read, Bash(psql *)
---
You are a database expert...
EOF
```

Agents run in isolated context windows — they won't pollute your main session.

</details>

---

## 🚀 Spec-Driven Build (Agent Teams)

Go from spec to working code with a single command. Claude Forge includes a complete **spec-driven development** workflow powered by Agent Teams.

### The flow

```
/spec <feature>          →  Interview → SPEC.md
/spec-build              →  SPEC.md → working project (with security validation + checkpoint)
```

### What happens when you run `/spec-build`

```
┌─────────────────┐
│   Orchestrator   │  Reads spec, creates API contract,
│   (team lead)    │  breaks work into tasks with deps
└────────┬────────┘
         │
   ┌─────┼─────────────┬──────────────┬──────────────┐
   ▼     ▼             ▼              ▼              ▼
┌──────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ API  │ │ Frontend │ │  Tests   │ │ Security │ │  Review  │
│ Dev  │ │ Dev      │ │  Writer  │ │ Auditor  │ │  & QA    │
└──────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
  Phase 1   Phase 1     Phase 2      Phase 3      Phase 3
```

1. **Orchestrator** reads the spec and creates `docs/api-contract.md` — the shared contract
2. **api-developer** + **frontend-developer** work in parallel (different directories, same contract)
3. **test-writer** covers the implemented code
4. **security-auditor** validates for OWASP issues + **code-reviewer** checks quality
5. **Automatic checkpoint** — if tests pass and no critical security issues, creates a tagged snapshot

### Enabling

Set in `.claude/settings.json` (already scaffolded, just flip to `"1"`):

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Permissions — plug-and-play

Settings come pre-configured so agents can work autonomously:

| Allowed (safe, reversible) | Blocked (destructive, irreversible) |
|---|---|
| Read, Write, Edit, Glob, Grep | `rm -rf /`, `rm -rf ~`, `rm -rf .` |
| git add, commit, checkout, diff, log | `git push`, `git push --force`, `git reset --hard` |
| npm/pip/cargo run, test, install | `curl -d` (outbound data), `wget --post` |
| mkdir, cp, mv, touch, chmod | Reading `.env` files |
| terraform plan/validate/fmt (production) | `terraform apply/destroy`, `docker push` |

Stack-specific tools (pytest, npx, cargo, etc.) are auto-merged when you pick a stack.
Preset-specific tools (terraform, docker, trivy, etc.) are auto-merged when you pick a preset.

### Using agents individually

All 15 agents also work as standalone subagents or manual teammates:

```
Spawn a teammate using the code-reviewer agent to review the auth module.
Spawn a teammate using the test-writer agent to cover the new endpoints.
Spawn a teammate using the security-auditor agent to audit the payment flow.
Spawn a teammate using the ux-designer agent to review the onboarding flow.
Spawn a teammate using the web-researcher agent to find the best auth library for Next.js.
Spawn a teammate using the codebase-navigator agent to map the auth module dependencies.
Spawn a teammate using the project-planner agent to plan the payments feature.
```

### Team hooks

| Hook | What it does |
|---|---|
| `teammate-idle.sh` | Keeps teammates working while pending tasks remain |
| `task-completed.sh` | Quality gate — uncomment to require tests/lint before closing tasks |

### Best practices

- Start with **3-5 teammates** — beyond that, coordination overhead outweighs gains
- Aim for **5-6 tasks per teammate** to keep everyone productive
- **Avoid two teammates editing the same file** — no merge conflict protection
- Use `/spec` first to generate a thorough spec — better spec = better output
- Clean up via the lead: `Clean up the team`

---

## 🛡️ Security Skills

Three dedicated security skills for thorough auditing:

| Skill | What it does |
|:---|:---|
| `/security-audit` | OWASP Top 10 structured review — injection, broken auth, misconfigurations, vulnerable deps. Uses gitleaks, semgrep, bandit if available. |
| `/infra-audit` | Reviews Terraform, Docker, CI/CD for misconfigurations — IAM wildcards, public S3, unpinned actions, missing encryption. |
| `/pentest-recon` | Passive attack surface mapping from codebase — endpoints, auth flows, input vectors, data flows. For authorized security testing only. |

---

## 🏁 Development Checkpoints

```
/checkpoint auth-complete
```

Creates a verified snapshot of your project:

1. **Runs tests** — fails fast if tests don't pass (no checkpoint on broken state)
2. **Commits** clean state with `checkpoint: <label>` message
3. **Tags** with `checkpoint/<date>/<label>` (annotated git tag)
4. **Saves context** to `.claude/checkpoints/<tag>.md` — state summary, recent changes, current focus, next steps

Start your next session by reading the checkpoint file — instant context recovery.

---

## 🧠 Design Principles

These templates follow [official Anthropic best practices](https://code.claude.com/docs/en/best-practices):

| Principle | Why |
|:---|:---|
| **CLAUDE.md under 200 lines** | Longer files degrade instruction adherence. Overflow goes to `rules/`. |
| **Progressive disclosure** | `@references` load on demand — don't dump everything into context. |
| **Security by default** | Hooks block secrets and flag vulnerabilities automatically. No opt-in needed. |
| **Deterministic safety** | Hooks block dangerous commands 100% of the time. CLAUDE.md is ~70%. |
| **Git-friendly** | Team files committed. Personal files (`.local.md`, `.local.json`) gitignored. |
| **Non-destructive** | Never overwrites existing files. Safe to re-run on any project. |
| **~150 instruction budget** | Claude Code's system prompt uses ~50 instructions. Your config shares the rest. |

---

## ❓ Troubleshooting

<details>
<summary><strong>Missing agents/skills after update</strong></summary>

If you update Claude Forge and re-run `/claude-forge`, new templates won't appear because `safe_copy` never overwrites existing files. To pick up new agents (or any new templates):

```bash
# Re-install the skill (re-run the installer)
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash

# Remove the old directories so the new templates are copied
rm -rf your-project/.claude/agents/
rm -rf your-project/.claude/hooks/
rm -rf your-project/.claude/skills/

# Re-run inside Claude Code
/claude-forge react --preset mvp
```

The same applies to any new template files (rules, skills, hooks).

</details>

---

## 🤝 Contributing

Contributions welcome! Some ideas:

| Category | Examples |
|:---|:---|
| **New stacks** | Django, Go, Java/Spring, PHP/Laravel, .NET |
| **New presets** | serverless, microservices-k8s, edge-first |
| **New skills** | deploy, changelog, migration, docs-update |
| **New agents** | performance-profiler, accessibility-auditor, api-designer |
| **New security hooks** | license-check, container-scan, SBOM generation |
| **Translations** | Help translate templates to other languages |

See [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for guidelines.

---

## 📚 References

- [Best Practices — Claude Code Docs](https://code.claude.com/docs/en/best-practices)
- [Using CLAUDE.md Files — Anthropic Blog](https://claude.com/blog/using-claude-md-files)
- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)

---

<p align="center">
  <sub>Built with ⚡ by <a href="https://github.com/brunobracaioli">@brunobracaioli</a></sub><br>
  <sub>MIT License</sub>
</p>
