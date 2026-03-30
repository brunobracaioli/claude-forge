# 🚀 Claude Project Bootstrap

**One command to scaffold the complete `.claude/` directory for any project.**

Stop rebuilding your Claude Code configuration from scratch every time you start a new project. This skill creates a production-ready `.claude/` structure with templates, rules, commands, agents, hooks, and stack-specific presets — all customizable.

🇧🇷 [Leia em Português](./README.pt-br.md)

---

## ✨ What You Get

| Component | Files | Purpose |
|---|---|---|
| **CLAUDE.md** | 1 | Stack-specific template with `[CUSTOMIZE]` markers |
| **Rules** | 4+ | code-style, testing, security, git-workflow + stack rules |
| **Commands** | 4 | `/review`, `/fix-issue`, `/spec`, `/commit` |
| **Agents** | 2 | code-reviewer, security-auditor (isolated subagents) |
| **Hooks** | 2 | validate-bash (blocks destructive commands), auto-format |
| **Settings** | 1 | Sensible permissions + hook wiring |
| **Example Skill** | 1 | Template to create your own skills |

### Supported Stacks

| Stack | Detected by | Extra Rules |
|---|---|---|
| `flask-next` | `requirements.txt` + `next.config.*` | API conventions, Flask patterns |
| `node` | `package.json` | Node/TypeScript conventions |
| `python` | `requirements.txt` / `pyproject.toml` | Python conventions, type hints |
| `react` | `next.config.*` | React/Next.js conventions, a11y |
| `rust` | `Cargo.toml` | Rust conventions, error handling |
| `generic` | (fallback) | Base rules only |

---

## 📦 Installation

### Option A: Claude Code Plugin (Recommended)

```bash
/plugins install project-bootstrap
```

### Option B: Git Clone

```bash
git clone https://github.com/brunobracaioli/claude-forge.git ~/.claude/skills/project-bootstrap
chmod +x ~/.claude/skills/project-bootstrap/scripts/bootstrap.sh
```

### Option C: One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash
```

---

## 🛠️ Usage

### Inside Claude Code

```
/project-bootstrap flask-next
```

Or in natural language:

> "Bootstrap this project for Claude Code"
> "Set up the .claude directory"
> "Mount the project structure so we can start"

### Auto-Detection

```
/project-bootstrap auto
```

Claude scans your project files and picks the right stack automatically.

---

## 📂 Generated Structure

```
your-project/
├── CLAUDE.md                          # Team instructions (< 200 lines)
└── .claude/
    ├── settings.json                  # Permissions + hooks
    ├── .gitignore                     # Ignores personal files
    ├── rules/
    │   ├── code-style.md              # Code standards
    │   ├── testing.md                 # Test strategy
    │   ├── security.md                # Security rules
    │   ├── git-workflow.md            # Git flow + commits
    │   └── <stack>-conventions.md     # Stack-specific rules
    ├── commands/
    │   ├── review.md                  # /project:review
    │   ├── fix-issue.md               # /project:fix-issue <n>
    │   ├── spec.md                    # /project:spec <feature>
    │   └── commit.md                  # /project:commit
    ├── agents/
    │   ├── code-reviewer.md           # Isolated code review
    │   └── security-auditor.md        # Security audit
    ├── skills/
    │   └── example-skill/SKILL.md     # Template for new skills
    └── hooks/
        ├── validate-bash.sh           # Blocks rm -rf, secret exposure
        └── auto-format.sh             # Auto-format after edits
```

---

## 🎨 Customization

All files with `[CUSTOMIZE]` markers need project-specific adjustments.

### Priority Order

1. **CLAUDE.md** — Edit first. Most impactful file.
2. **settings.json** — Adjust allow/deny for your build tools.
3. **rules/** — Delete what doesn't apply, add what's missing.
4. **hooks/auto-format.sh** — Uncomment the formatter for your stack.
5. **commands/** — Add project-specific workflows.
6. **agents/** and **skills/** — Add as needed.

### Adding a New Command

```bash
# Creates /project:deploy
cat > .claude/commands/deploy.md << 'EOF'
---
description: Deploy to staging or production
argument-hint: [staging|production]
---
Deploy to $ARGUMENTS environment...
EOF
```

### Adding a New Skill

```bash
mkdir -p .claude/skills/my-skill
# Copy and edit the example template:
cp .claude/skills/example-skill/SKILL.md .claude/skills/my-skill/SKILL.md
```

### Adding a New Agent

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

---

## 🧠 Design Principles

These templates follow [official Anthropic best practices](https://code.claude.com/docs/en/best-practices):

1. **CLAUDE.md under 200 lines** — Overflow goes to `.claude/rules/`
2. **Progressive disclosure** — `@references` instead of inlining everything
3. **Deterministic safety** — Hooks block dangerous commands 100% of the time
4. **Git-friendly** — Team files committed, personal files gitignored
5. **Non-destructive** — Never overwrites existing files (safe to re-run)
6. **~150 instruction budget** — Claude Code's system prompt uses ~50 instructions. Your CLAUDE.md + rules share the remaining ~100-150 for reliable adherence.

---

## 🤝 Contributing

Contributions welcome! Some ideas:

- **New stacks**: Django, Go, Java/Spring, PHP/Laravel, .NET
- **New commands**: deploy, changelog, migration, docs-update
- **New agents**: performance-profiler, accessibility-auditor, api-designer
- **Translations**: Help translate templates to other languages

See [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for guidelines.

---

## 📚 References

- [Best Practices — Claude Code Docs](https://code.claude.com/docs/en/best-practices)
- [Using CLAUDE.md Files — Anthropic Blog](https://claude.com/blog/using-claude-md-files)
- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)

---

## 📄 License

MIT — See [LICENSE](./LICENSE)
