<p align="center">
  <img src="docs/assets/banner.svg" alt="Claude Forge — Forge your .claude/ in one command" width="100%">
</p>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <img src="https://img.shields.io/badge/stacks-6-f59e0b.svg?style=flat-square" alt="Stacks">
  <img src="https://img.shields.io/badge/templates-40%20files-8b5cf6.svg?style=flat-square" alt="Templates">
  <img src="https://img.shields.io/badge/claude--code-skill-10b981.svg?style=flat-square" alt="Claude Code Skill">
</p>

<p align="center">
  <strong>One command to scaffold the complete <code>.claude/</code> directory for Claude Code.</strong><br>
  Templates, rules, skills, agents, hooks, and stack-specific presets.<br>
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
/claude-forge flask-next
```

Or just ask naturally:

> *"Set up the .claude directory for this project"*

---

## 🎯 What You Get

A single command creates **15+ files** across 6 categories:

| | Component | What's Inside |
|---|---|---|
| 📄 | **CLAUDE.md** | Stack-specific template with `[CUSTOMIZE]` markers, under 200 lines |
| 📏 | **Rules** (4+) | `code-style` · `testing` · `security` · `git-workflow` + stack-specific |
| ⚡ | **Skills** (5) | `/review` · `/fix-issue` · `/spec` · `/spec-build` · `/commit` |
| 🤖 | **Agents** (9) | `code-reviewer` · `security-auditor` · `debugger` · `test-writer` · `refactorer` · `doc-writer` · `orchestrator` · `api-developer` · `frontend-developer` |
| 🔒 | **Hooks** (4) | `validate-bash` · `auto-format` · `teammate-idle` · `task-completed` |
| ⚙️ | **Settings** | Sensible permissions with hook wiring out-of-the-box |

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
cp -r /tmp/claude-forge-main/{SKILL.md,scripts,templates,stacks} ~/.claude/skills/claude-forge/
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
└── .claude/
    ├── settings.json                  ← Permissions + hooks
    ├── .gitignore                     ← Ignores personal files
    │
    ├── rules/                         ← Modular instructions
    │   ├── code-style.md
    │   ├── testing.md
    │   ├── security.md
    │   ├── git-workflow.md
    │   └── <stack>-conventions.md     ← Stack-specific rules
    │
    ├── skills/                        ← Slash commands (canonical format)
    │   ├── review/SKILL.md            ← /review
    │   ├── fix-issue/SKILL.md         ← /fix-issue <n>
    │   ├── spec/SKILL.md              ← /spec <feature>
    │   ├── spec-build/SKILL.md        ← /spec-build (Agent Teams)
    │   └── commit/SKILL.md            ← /commit
    │
    ├── agents/                        ← Subagents + Team Agent teammates
    │   ├── orchestrator.md            ← Team lead for spec-driven builds
    │   ├── api-developer.md           ← Backend/API teammate
    │   ├── frontend-developer.md      ← Frontend/UI teammate
    │   ├── code-reviewer.md
    │   ├── security-auditor.md
    │   ├── debugger.md
    │   ├── test-writer.md
    │   ├── refactorer.md
    │   └── doc-writer.md
    │
    ├── skills/
    │   └── example-skill/SKILL.md     ← Template for your own skills
    │
    └── hooks/                         ← Event-driven automation
        ├── validate-bash.sh           ← Blocks rm -rf, secret exposure
        ├── auto-format.sh             ← Auto-format after edits
        ├── teammate-idle.sh           ← Keeps teammates working while tasks remain
        └── task-completed.sh          ← Quality gate before closing tasks
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
| 5 | `.claude/skills/` | Add project-specific workflows. |
| 6 | `.claude/agents/` `.claude/skills/` | Add as complexity grows. |

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
<summary><strong>Adding a new skill</strong></summary>

```bash
mkdir -p .claude/skills/my-skill
cp .claude/skills/example-skill/SKILL.md .claude/skills/my-skill/SKILL.md
# Edit SKILL.md with your instructions
```

Skills auto-invoke based on the `description` field in frontmatter.

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
/spec-build              →  SPEC.md → working project
```

### What happens when you run `/spec-build`

```
┌─────────────────┐
│   Orchestrator   │  Reads spec, creates API contract,
│   (team lead)    │  breaks work into tasks with deps
└────────┬────────┘
         │
   ┌─────┼─────────────┬──────────────┐
   ▼     ▼             ▼              ▼
┌──────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ API  │ │ Frontend │ │  Tests   │ │  Review  │
│ Dev  │ │ Dev      │ │  Writer  │ │  & QA    │
└──────┘ └──────────┘ └──────────┘ └──────────┘
  Phase 1   Phase 1     Phase 2      Phase 3
```

1. **Orchestrator** reads the spec and creates `docs/api-contract.md` — the shared contract
2. **api-developer** + **frontend-developer** work in parallel (different directories, same contract)
3. **test-writer** covers the implemented code
4. **code-reviewer** + **security-auditor** validate everything

### Enabling

Set in `.claude/settings.json` (already scaffolded, just flip to `"1"`):

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

> Requires Claude Code v2.1.32+. Feature is **experimental**.

### Permissions — plug-and-play

Settings come pre-configured so agents can work autonomously:

| Allowed (safe, reversible) | Blocked (destructive, irreversible) |
|---|---|
| Read, Write, Edit, Glob, Grep | `rm -rf /`, `rm -rf ~`, `rm -rf .` |
| git add, commit, checkout, diff, log | `git push`, `git push --force`, `git reset --hard` |
| npm/pip/cargo run, test, install | `curl -d` (outbound data), `wget --post` |
| mkdir, cp, mv, touch, chmod | Reading `.env` files |

Stack-specific tools (pytest, npx, cargo, etc.) are auto-merged when you pick a stack.

### Using agents individually

All 9 agents also work as standalone subagents or manual teammates:

```
Spawn a teammate using the code-reviewer agent to review the auth module.
Spawn a teammate using the test-writer agent to cover the new endpoints.
Spawn a teammate using the security-auditor agent to audit the payment flow.
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

## 🧠 Design Principles

These templates follow [official Anthropic best practices](https://code.claude.com/docs/en/best-practices):

| Principle | Why |
|:---|:---|
| **CLAUDE.md under 200 lines** | Longer files degrade instruction adherence. Overflow goes to `rules/`. |
| **Progressive disclosure** | `@references` load on demand — don't dump everything into context. |
| **Deterministic safety** | Hooks block dangerous commands 100% of the time. CLAUDE.md is ~70%. |
| **Git-friendly** | Team files committed. Personal files (`.local.md`, `.local.json`) gitignored. |
| **Non-destructive** | Never overwrites existing files. Safe to re-run on any project. |
| **~150 instruction budget** | Claude Code's system prompt uses ~50 instructions. Your config shares the rest. |

---

## ❓ Troubleshooting

<details>
<summary><strong>Missing agents after update</strong></summary>

If you update Claude Forge and re-run `/claude-forge`, new templates won't appear because `safe_copy` never overwrites existing files. To pick up new agents (or any new templates):

```bash
# Re-install the skill (re-run the installer)
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash

# Remove the old agents directory so the new templates are copied
rm -rf your-project/.claude/agents/

# Re-run inside Claude Code
/claude-forge flask-next
```

The same applies to any new template files (rules, skills, hooks).

</details>

---

## 🤝 Contributing

Contributions welcome! Some ideas:

| Category | Examples |
|:---|:---|
| **New stacks** | Django, Go, Java/Spring, PHP/Laravel, .NET |
| **New skills** | deploy, changelog, migration, docs-update |
| **New agents** | performance-profiler, accessibility-auditor, api-designer |
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