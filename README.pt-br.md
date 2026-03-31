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
  Templates, regras, skills, agentes, hooks e presets por stack.<br>
  Pare de reconstruir — comece a construir.
</p>

<p align="center">
  🇺🇸 <a href="./README.md">Read in English</a>
</p>

---

## ⚡ Início Rápido

```bash
# Instale uma vez (skill global)
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash

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
| ⚡ | **Skills** (5) | `/review` · `/fix-issue` · `/spec` · `/spec-build` · `/commit` |
| 🤖 | **Agents** (9) | `code-reviewer` · `security-auditor` · `debugger` · `test-writer` · `refactorer` · `doc-writer` · `orchestrator` · `api-developer` · `frontend-developer` |
| 🔒 | **Hooks** (4) | `validate-bash` · `auto-format` · `teammate-idle` · `task-completed` |
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

### One-liner *(recomendado)*

```bash
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash
```

### Download manual (sem git)

```bash
curl -sL https://github.com/brunobracaioli/claude-forge/archive/main.tar.gz | tar xz -C /tmp
mkdir -p ~/.claude/skills/claude-forge
cp -r /tmp/claude-forge-main/{SKILL.md,scripts,templates,stacks} ~/.claude/skills/claude-forge/
chmod +x ~/.claude/skills/claude-forge/scripts/*.sh
rm -rf /tmp/claude-forge-main
```

### Plugin Claude Code

```
/plugins install claude-forge
```

> **Nota:** O Claude Forge é instalado como skill somente leitura — nenhum repositório git é vinculado. Para atualizar, basta re-executar o instalador.

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
    ├── skills/                        ← Skills (formato canônico)
    │   ├── review/SKILL.md            ← /review
    │   ├── fix-issue/SKILL.md         ← /fix-issue <n>
    │   ├── spec/SKILL.md              ← /spec <feature>
    │   ├── spec-build/SKILL.md        ← /spec-build (Agent Teams)
    │   └── commit/SKILL.md            ← /commit
    │
    ├── agents/                        ← Subagentes + teammates do Agent Teams
    │   ├── orchestrator.md            ← Team lead para builds spec-driven
    │   ├── api-developer.md           ← Teammate backend/API
    │   ├── frontend-developer.md      ← Teammate frontend/UI
    │   ├── code-reviewer.md
    │   ├── security-auditor.md
    │   ├── debugger.md
    │   ├── test-writer.md
    │   ├── refactorer.md
    │   └── doc-writer.md
    │
    ├── skills/
    │   └── example-skill/SKILL.md     ← Template para criar seus skills
    │
    └── hooks/                         ← Automação por eventos
        ├── validate-bash.sh           ← Bloqueia rm -rf, exposição de secrets
        ├── auto-format.sh             ← Auto-format após edições
        ├── teammate-idle.sh           ← Mantém teammates ativos enquanto há tasks
        └── task-completed.sh          ← Quality gate antes de fechar tasks
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
| 5 | `.claude/skills/` | Adicione workflows específicos do projeto. |
| 6 | `.claude/agents/` `.claude/skills/` | Adicione conforme a complexidade cresce. |

<details>
<summary><strong>Criar novo skill</strong></summary>

```bash
mkdir -p .claude/skills/deploy
cat > .claude/skills/deploy/SKILL.md << 'EOF'
---
name: deploy
description: Deploy para staging ou produção
argument-hint: "[staging|production]"
disable-model-invocation: true
allowed-tools: Bash
---
Fazer deploy no ambiente $ARGUMENTS...
EOF
```

Cria `/deploy` automaticamente.

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

## 🚀 Build Spec-Driven (Agent Teams)

Vá do spec ao código funcional com um único comando. O Claude Forge inclui um workflow completo de **desenvolvimento spec-driven** usando Agent Teams.

### O fluxo

```
/spec <feature>          →  Entrevista → SPEC.md
/spec-build              →  SPEC.md → projeto funcional
```

### O que acontece quando você roda `/spec-build`

```
┌─────────────────┐
│   Orchestrator   │  Lê spec, cria contrato de API,
│   (team lead)    │  quebra trabalho em tasks com deps
└────────┬────────┘
         │
   ┌─────┼─────────────┬──────────────┐
   ▼     ▼             ▼              ▼
┌──────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ API  │ │ Frontend │ │  Tests   │ │  Review  │
│ Dev  │ │ Dev      │ │  Writer  │ │  & QA    │
└──────┘ └──────────┘ └──────────┘ └──────────┘
  Fase 1   Fase 1      Fase 2       Fase 3
```

1. **Orchestrator** lê o spec e cria `docs/api-contract.md` — o contrato compartilhado
2. **api-developer** + **frontend-developer** trabalham em paralelo (diretórios diferentes, mesmo contrato)
3. **test-writer** cobre o código implementado
4. **code-reviewer** + **security-auditor** validam tudo

### Ativando

Altere no `.claude/settings.json` (já vem scaffolded, só mude para `"1"`):

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

> Requer Claude Code v2.1.32+. Feature **experimental**.

### Permissões — plug-and-play

O settings vem pré-configurado para que agentes trabalhem autonomamente:

| Permitido (seguro, reversível) | Bloqueado (destrutivo, irreversível) |
|---|---|
| Read, Write, Edit, Glob, Grep | `rm -rf /`, `rm -rf ~`, `rm -rf .` |
| git add, commit, checkout, diff, log | `git push`, `git push --force`, `git reset --hard` |
| npm/pip/cargo run, test, install | `curl -d` (envio de dados), `wget --post` |
| mkdir, cp, mv, touch, chmod | Leitura de arquivos `.env` |

Ferramentas específicas do stack (pytest, npx, cargo, etc.) são auto-mergeadas quando você escolhe um stack.

### Usando agentes individualmente

Todos os 9 agentes também funcionam como subagentes standalone ou teammates manuais:

```
Spawn a teammate using the code-reviewer agent to review the auth module.
Spawn a teammate using the test-writer agent to cover the new endpoints.
Spawn a teammate using the security-auditor agent to audit the payment flow.
```

### Hooks do time

| Hook | O que faz |
|---|---|
| `teammate-idle.sh` | Mantém teammates ativos enquanto houver tasks pendentes |
| `task-completed.sh` | Quality gate — descomente para exigir testes/lint antes de fechar tasks |

### Boas práticas

- Comece com **3-5 teammates** — acima disso, overhead de coordenação supera os ganhos
- Mire em **5-6 tasks por teammate** para manter todos produtivos
- **Evite dois teammates editando o mesmo arquivo** — sem proteção contra conflitos de merge
- Use `/spec` primeiro para gerar um spec completo — melhor spec = melhor output
- Limpe via o lead: `Clean up the team`

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

## ❓ Solução de Problemas

<details>
<summary><strong>Agentes faltando após atualização</strong></summary>

Se você atualizar o Claude Forge e re-rodar `/claude-forge`, novos templates não aparecem porque o `safe_copy` nunca sobrescreve arquivos existentes. Para pegar novos agentes (ou qualquer template novo):

```bash
# Re-instale a skill (re-execute o instalador)
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash

# Remova o diretório de agents antigo para os novos templates serem copiados
rm -rf seu-projeto/.claude/agents/

# Re-rode dentro do Claude Code
/claude-forge flask-next
```

O mesmo vale para qualquer arquivo de template novo (rules, skills, hooks).

</details>

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Algumas ideias:

| Categoria | Exemplos |
|:---|:---|
| **Novos stacks** | Django, Go, Java/Spring, PHP/Laravel, .NET |
| **Novos skills** | deploy, changelog, migration, docs-update |
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