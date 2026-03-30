# 🚀 Claude Project Bootstrap

**Um comando para criar a estrutura completa `.claude/` em qualquer projeto.**

Pare de reconstruir a configuração do Claude Code do zero toda vez que iniciar um projeto novo. Este skill cria uma estrutura `.claude/` pronta para produção com templates, regras, comandos, agentes, hooks e presets específicos por stack — tudo customizável.

🇺🇸 [Read in English](./README.md)

---

## ✨ O Que Você Recebe

| Componente | Arquivos | Função |
|---|---|---|
| **CLAUDE.md** | 1 | Template específico do stack com marcadores `[CUSTOMIZE]` |
| **Rules** | 4+ | code-style, testing, security, git-workflow + regras do stack |
| **Commands** | 4 | `/review`, `/fix-issue`, `/spec`, `/commit` |
| **Agents** | 2 | code-reviewer, security-auditor (subagentes isolados) |
| **Hooks** | 2 | validate-bash (bloqueia comandos destrutivos), auto-format |
| **Settings** | 1 | Permissões sensatas + hooks configurados |
| **Skill exemplo** | 1 | Template para criar seus próprios skills |

### Stacks Suportados

| Stack | Detectado por | Regras Extras |
|---|---|---|
| `flask-next` | `requirements.txt` + `next.config.*` | Convenções de API, padrões Flask |
| `node` | `package.json` | Convenções Node/TypeScript |
| `python` | `requirements.txt` / `pyproject.toml` | Convenções Python, type hints |
| `react` | `next.config.*` | Convenções React/Next.js, a11y |
| `rust` | `Cargo.toml` | Convenções Rust, error handling |
| `generic` | (fallback) | Apenas regras base |

---

## 📦 Instalação

### Opção A: Plugin Claude Code (Recomendado)

```bash
/plugins install project-bootstrap
```

### Opção B: Git Clone

```bash
git clone https://github.com/brunobracaioli/claude-forge.git ~/.claude/skills/project-bootstrap
chmod +x ~/.claude/skills/project-bootstrap/scripts/bootstrap.sh
```

### Opção C: One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash
```

---

## 🛠️ Uso

### Dentro do Claude Code

```
/project-bootstrap flask-next
```

Ou em linguagem natural:

> "Monte a estrutura do projeto para começarmos"
> "Bootstrap este projeto pro Claude Code"
> "Configure o diretório .claude"

### Auto-detecção

```
/project-bootstrap auto
```

O Claude analisa os arquivos do projeto e escolhe o stack automaticamente.

---

## 📂 Estrutura Gerada

```
seu-projeto/
├── CLAUDE.md                          # Instruções do time (< 200 linhas)
└── .claude/
    ├── settings.json                  # Permissões + hooks
    ├── .gitignore                     # Ignora arquivos pessoais
    ├── rules/
    │   ├── code-style.md              # Padrões de código
    │   ├── testing.md                 # Estratégia de testes
    │   ├── security.md                # Regras de segurança
    │   ├── git-workflow.md            # Fluxo git + commits
    │   └── <stack>-conventions.md     # Regras específicas do stack
    ├── commands/
    │   ├── review.md                  # /project:review
    │   ├── fix-issue.md               # /project:fix-issue <n>
    │   ├── spec.md                    # /project:spec <feature>
    │   └── commit.md                  # /project:commit
    ├── agents/
    │   ├── code-reviewer.md           # Code review isolado
    │   └── security-auditor.md        # Auditoria de segurança
    ├── skills/
    │   └── example-skill/SKILL.md     # Template para novos skills
    └── hooks/
        ├── validate-bash.sh           # Bloqueia rm -rf, exposição de secrets
        └── auto-format.sh             # Auto-format após edições
```

---

## 🎨 Customização

Todos os arquivos com marcadores `[CUSTOMIZE]` precisam de ajuste para o projeto.

### Ordem de Prioridade

1. **CLAUDE.md** — Edite primeiro. Arquivo mais impactante.
2. **settings.json** — Ajuste allow/deny para suas ferramentas de build.
3. **rules/** — Delete o que não se aplica, adicione o que falta.
4. **hooks/auto-format.sh** — Descomente o formatter do seu stack.
5. **commands/** — Adicione workflows específicos do projeto.
6. **agents/** e **skills/** — Adicione conforme necessidade.

### Criar Novo Command

```bash
# Cria /project:deploy
cat > .claude/commands/deploy.md << 'EOF'
---
description: Deploy para staging ou produção
argument-hint: [staging|production]
---
Fazer deploy no ambiente $ARGUMENTS...
EOF
```

### Criar Novo Skill

```bash
mkdir -p .claude/skills/meu-skill
cp .claude/skills/example-skill/SKILL.md .claude/skills/meu-skill/SKILL.md
# Edite o SKILL.md com as instruções do seu skill
```

### Criar Novo Agent

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

---

## 🧠 Princípios de Design

Estes templates seguem as [melhores práticas oficiais da Anthropic](https://code.claude.com/docs/en/best-practices):

1. **CLAUDE.md abaixo de 200 linhas** — Excedente vai para `.claude/rules/`
2. **Progressive disclosure** — `@references` em vez de colocar tudo inline
3. **Segurança determinística** — Hooks bloqueiam comandos perigosos 100% das vezes
4. **Git-friendly** — Arquivos do time commitados, pessoais no gitignore
5. **Não-destrutivo** — Nunca sobrescreve arquivos existentes (seguro re-executar)
6. **Budget de ~150 instruções** — O system prompt do Claude Code usa ~50 instruções. Seu CLAUDE.md + rules compartilham as ~100-150 restantes.

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Algumas ideias:

- **Novos stacks**: Django, Go, Java/Spring, PHP/Laravel, .NET
- **Novos commands**: deploy, changelog, migration, docs-update
- **Novos agents**: performance-profiler, accessibility-auditor, api-designer
- **Traduções**: Ajude a traduzir templates para outros idiomas

Veja [CONTRIBUTING.md](./docs/CONTRIBUTING.md) para as diretrizes.

---

## 📚 Referências

- [Best Practices — Claude Code Docs](https://code.claude.com/docs/en/best-practices)
- [Using CLAUDE.md Files — Anthropic Blog](https://claude.com/blog/using-claude-md-files)
- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)

---

## 📄 Licença

MIT — Veja [LICENSE](./LICENSE)
