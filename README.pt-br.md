<p align="center">
  <img src="docs/assets/banner.svg" alt="Claude Forge — Forge your .claude/ in one command" width="100%">
</p>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/licen%C3%A7a-MIT-blue.svg?style=flat-square" alt="Licença"></a>
  <img src="https://img.shields.io/badge/stacks-6-f59e0b.svg?style=flat-square" alt="Stacks">
  <img src="https://img.shields.io/badge/templates-40%20arquivos-8b5cf6.svg?style=flat-square" alt="Templates">
  <img src="https://img.shields.io/badge/claude--code-skill-10b981.svg?style=flat-square" alt="Claude Code Skill">
</p>

<p align="center">
  <strong>Um comando para criar a estrutura completa <code>.claude/</code> no Claude Code.</strong><br>
  Templates, regras, comandos, agentes, hooks e presets por stack.<br>
  Pare de reconstruir — comece a construir.
</p>

<p align="center">
  🇺🇸 <a href="./README.md">Read in English</a>
</p>

---

## ⚡ Início Rápido

```bash
# Instale uma vez (skill global)
git clone https://github.com/brunobracaioli/claude-forge.git ~/.claude/skills/claude-forge

# Use em qualquer projeto
cd seu-projeto
```

Dentro do Claude Code:

```
/claude-forge flask-next
```

Ou peça em linguagem natural:

> *"Monte a estrutura do projeto para começarmos"*

---

## 🎯 O Que Você Recebe

Um único comando cria **15+ arquivos** em 6 categorias:

| | Componente | O Que Inclui |
|---|---|---|
| 📄 | **CLAUDE.md** | Template do stack com marcadores `[CUSTOMIZE]`, menos de 200 linhas |
| 📏 | **Rules** (4+) | `code-style` · `testing` · `security` · `git-workflow` + regras do stack |
| ⚡ | **Commands** (4) | `/review` · `/fix-issue` · `/spec` · `/commit` |
| 🤖 | **Agents** (2) | `code-reviewer` · `security-auditor` — subagentes isolados |
| 🔒 | **Hooks** (2) | `validate-bash` bloqueia comandos destrutivos · `auto-format` roda seu formatter |
| ⚙️ | **Settings** | Permissões sensatas com hooks configurados |

---

## 🏗️ Stacks Suportados

Auto-detecção analisa os arquivos do projeto e escolhe o preset certo:

| Stack | Detectado Por | Regras Extras |
|:---|:---|:---|
| **flask-next** | `requirements.txt` + `next.config.*` | Convenções de API, padrões Flask |
| **node** | `package.json` | Convenções Node/TypeScript |
| **python** | `requirements.txt` / `pyproject.toml` | Convenções Python, type hints |
| **react** | `next.config.*` (sem arquivos Python) | Convenções React/Next.js, a11y |
| **rust** | `Cargo.toml` | Convenções Rust, error handling |
| **generic** | *(fallback)* | Apenas regras base |

> **Adicionar um stack é um PR.** Django, Go, Java/Spring, PHP/Laravel, .NET — [contribuições são bem-vindas](#-contribuindo).

---

## 📦 Instalação

Escolha uma opção:

### Git Clone *(recomendado)*

```bash
git clone https://github.com/brunobracaioli/claude-forge.git ~/.claude/skills/claude-forge
chmod +x ~/.claude/skills/claude-forge/scripts/bootstrap.sh
```

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash
```

### Plugin Claude Code

```
/plugins install claude-forge
```

---

## 📂 Estrutura Gerada

```
seu-projeto/
├── CLAUDE.md                          ← Instruções do time (< 200 linhas)
└── .claude/
    ├── settings.json                  ← Permissões + hooks
    ├── .gitignore                     ← Ignora arquivos pessoais
    │
    ├── rules/                         ← Instruções modulares
    │   ├── code-style.md
    │   ├── testing.md
    │   ├── security.md
    │   ├── git-workflow.md
    │   └── <stack>-conventions.md     ← Regras específicas do stack
    │
    ├── commands/                      ← Slash commands manuais
    │   ├── review.md                  ← /project:review
    │   ├── fix-issue.md               ← /project:fix-issue <n>
    │   ├── spec.md                    ← /project:spec <feature>
    │   └── commit.md                  ← /project:commit
    │
    ├── agents/                        ← Subagentes isolados
    │   ├── code-reviewer.md
    │   └── security-auditor.md
    │
    ├── skills/
    │   └── example-skill/SKILL.md     ← Template para criar seus skills
    │
    └── hooks/                         ← Automação por eventos
        ├── validate-bash.sh           ← Bloqueia rm -rf, exposição de secrets
        └── auto-format.sh             ← Auto-format após edições
```

---

## 🎨 Customização

Todos os arquivos gerados com marcadores `[CUSTOMIZE]` precisam de ajuste.

**Edite nesta ordem** — maior impacto primeiro:

| Prioridade | Arquivo | Por quê |
|:---:|:---|:---|
| 1 | `CLAUDE.md` | Claude lê isso toda sessão. Acerte de primeira. |
| 2 | `.claude/settings.json` | Ajuste allow/deny para suas ferramentas. |
| 3 | `.claude/rules/` | Delete o que não se aplica, adicione o que falta. |
| 4 | `.claude/hooks/auto-format.sh` | Descomente o formatter do seu stack. |
| 5 | `.claude/commands/` | Adicione workflows específicos do projeto. |
| 6 | `.claude/agents/` `.claude/skills/` | Adicione conforme a complexidade cresce. |

<details>
<summary><strong>Criar novo command</strong></summary>

```bash
cat > .claude/commands/deploy.md << 'EOF'
---
description: Deploy para staging ou produção
argument-hint: [staging|production]
---
Fazer deploy no ambiente $ARGUMENTS...
EOF
```

Cria `/project:deploy` automaticamente.

</details>

<details>
<summary><strong>Criar novo skill</strong></summary>

```bash
mkdir -p .claude/skills/meu-skill
cp .claude/skills/example-skill/SKILL.md .claude/skills/meu-skill/SKILL.md
# Edite o SKILL.md com suas instruções
```

Skills são auto-invocados baseado no campo `description` do frontmatter.

</details>

<details>
<summary><strong>Criar novo agent</strong></summary>

```bash
cat > .claude/agents/db-explorer.md << 'EOF'
---
name: db-explorer
description: Explorar schema e dados do banco
model: haiku
tools: Read, Bash(psql *)
---
Você é um especialista em banco de dados...
EOF
```

Agentes rodam em context windows isoladas — não poluem sua sessão principal.

</details>

---

## 🧠 Princípios de Design

Estes templates seguem as [melhores práticas oficiais da Anthropic](https://code.claude.com/docs/en/best-practices):

| Princípio | Por quê |
|:---|:---|
| **CLAUDE.md abaixo de 200 linhas** | Arquivos maiores degradam a aderência às instruções. Excedente vai pra `rules/`. |
| **Progressive disclosure** | `@references` carregam sob demanda — não encha o contexto. |
| **Segurança determinística** | Hooks bloqueiam comandos perigosos 100% das vezes. CLAUDE.md fica em ~70%. |
| **Git-friendly** | Arquivos do time commitados. Pessoais (`.local.md`, `.local.json`) no gitignore. |
| **Não-destrutivo** | Nunca sobrescreve arquivos existentes. Seguro re-executar em qualquer projeto. |
| **Budget de ~150 instruções** | O system prompt do Claude Code usa ~50. Sua config divide o resto. |

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Algumas ideias:

| Categoria | Exemplos |
|:---|:---|
| **Novos stacks** | Django, Go, Java/Spring, PHP/Laravel, .NET |
| **Novos commands** | deploy, changelog, migration, docs-update |
| **Novos agents** | performance-profiler, accessibility-auditor, api-designer |
| **Traduções** | Ajude a traduzir templates para outros idiomas |

Veja [CONTRIBUTING.md](./docs/CONTRIBUTING.md) para as diretrizes.

---

## 📚 Referências

- [Best Practices — Claude Code Docs](https://code.claude.com/docs/en/best-practices)
- [Using CLAUDE.md Files — Anthropic Blog](https://claude.com/blog/using-claude-md-files)
- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)

---

<p align="center">
  <sub>Feito com ⚡ por <a href="https://github.com/brunobracaioli">@brunobracaioli</a></sub><br>
  <sub>Licença MIT</sub>
</p>