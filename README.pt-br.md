<p align="center">
  <img src="docs/assets/banner.svg" alt="Claude Forge — Forge your .claude/ in one command" width="100%">
</p>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/licen%C3%A7a-MIT-blue.svg?style=flat-square" alt="Licenca"></a>
  <img src="https://img.shields.io/badge/stacks-6-f59e0b.svg?style=flat-square" alt="Stacks">
  <img src="https://img.shields.io/badge/presets-2-ef4444.svg?style=flat-square" alt="Presets">
  <img src="https://img.shields.io/badge/templates-60%2B%20arquivos-8b5cf6.svg?style=flat-square" alt="Templates">
  <img src="https://img.shields.io/badge/claude--code-skill-10b981.svg?style=flat-square" alt="Claude Code Skill">
</p>

<p align="center">
  <strong>Um comando para criar a estrutura completa <code>.claude/</code> no Claude Code.</strong><br>
  Templates, regras, skills, agentes, hooks, seguranca automatizada, presets de arquitetura e IaC.<br>
  Pare de reconstruir — comece a construir.
</p>

<p align="center">
  <a href="./README.md">Read in English</a>
</p>

---

## Inicio Rapido

```bash
# Instale uma vez (skill global)
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash

# Use em qualquer projeto
cd seu-projeto
```

Dentro do Claude Code:

```
/claude-forge react --preset mvp
```

Ou peca em linguagem natural:

> *"Monte a estrutura do projeto com preset de producao"*

---

## O Que Voce Recebe

Um unico comando cria **60+ arquivos** em 8 categorias:

| | Componente | O Que Inclui |
|---|---|---|
| 📄 | **CLAUDE.md** | Template do stack com marcadores `[CUSTOMIZE]`, menos de 200 linhas |
| 📏 | **Rules** (5+) | `code-style` . `testing` . `security` . `git-workflow` . `agent-creation` + regras do stack + preset |
| ⚡ | **Skills** (10) | `/review` . `/fix-issue` . `/spec` . `/spec-build` . `/commit` . `/checkpoint` . `/security-audit` . `/infra-audit` . `/pentest-recon` |
| 🤖 | **Agents** (15) | `code-reviewer` . `security-auditor` . `debugger` . `test-writer` . `refactorer` . `doc-writer` . `orchestrator` . `api-developer` . `frontend-developer` . `ux-designer` . `frontend-design` . `web-researcher` . `codebase-navigator` . `project-planner` . `spec-writer` |
| 🔒 | **Hooks** (7) | `validate-bash` . `secret-scan` . `sast-scan` . `dependency-check` . `auto-format` . `teammate-idle` . `task-completed` |
| ⚙️ | **Settings** | Permissoes sensatas com todos os hooks configurados |
| 🏗️ | **Presets** | `mvp` (monolito, Supabase+Vercel) ou `production` (Terraform, AWS, Docker, CI/CD) |
| 📦 | **IaC** | Modulos Terraform, Dockerfile, docker-compose, GitHub Actions (dependente do preset) |

---

## Stacks Suportados

Auto-deteccao analisa os arquivos do projeto e escolhe o preset certo:

| Stack | Detectado Por | Regras Extras |
|:---|:---|:---|
| **flask-next** | `requirements.txt` + `next.config.*` | Convencoes de API, padroes Flask |
| **node** | `package.json` | Convencoes Node/TypeScript |
| **python** | `requirements.txt` / `pyproject.toml` | Convencoes Python, type hints |
| **react** | `next.config.*` (sem arquivos Python) | Convencoes React/Next.js, a11y |
| **rust** | `Cargo.toml` | Convencoes Rust, error handling |
| **generic** | *(fallback)* | Apenas regras base |

> **Adicionar um stack e um PR.** Django, Go, Java/Spring, PHP/Laravel, .NET — [contribuicoes sao bem-vindas](#-contribuindo).

---

## Presets de Arquitetura

Presets sao ortogonais aos stacks — stack = tecnologia, preset = arquitetura. Combine livremente: `react + mvp` ou `python + production`.

| Preset | Arquitetura | Infra | O Que Gera |
|:---|:---|:---|:---|
| **mvp** | Monolito, iteracao rapida | Supabase + Vercel + Upstash | `docker-compose.yml`, GitHub Actions CI |
| **production** | Multi-servico, domain-driven | AWS/GCP + Terraform | `terraform/` (VPC+RDS+ECS), `Dockerfile`, `docker-compose.yml`, CI+Deploy pipelines |
| **none** | *(padrao)* | Sem opiniao de infra | Apenas estrutura `.claude/` |

```
/claude-forge node --preset production
```

### Preset MVP
- Unidade unica de deploy, sem microservicos
- Supabase para auth/DB/storage, Vercel para hosting, Upstash para Redis
- Sem Terraform, sem Docker em producao — infra gerenciada pela plataforma
- Docker Compose para dev local (Postgres + Redis)

### Preset Production
- Boundaries domain-driven com contratos de API claros
- Modulos Terraform: VPC (subnets publicas/privadas, NAT), RDS Postgres (encriptado, Secrets Manager, multi-AZ), ECS Fargate (ALB, ECR com scan-on-push, circuit breaker rollback)
- Dockerfile multi-stage (non-root, healthcheck)
- Docker Compose com LocalStack para emulacao AWS
- GitHub Actions: CI (lint + test + Trivy SAST + scan de imagem Docker) + Deploy (ECR push + ECS rolling deploy)

---

## Hooks de Seguranca

Tres hooks de seguranca rodam automaticamente em todo projeto scaffolded — **ativos por padrao**, sem configuracao:

| Hook | Trigger | Acao |
|:---|:---|:---|
| **secret-scan** | Antes do `git commit` | **Bloqueia** commits com secrets hardcoded. Usa gitleaks se instalado, senao regex (AWS keys, GitHub tokens, private keys, JWTs, connection strings) |
| **sast-scan** | Apos Edit/Write | **Alerta** sobre SQL injection, command injection, eval(), IPs hardcoded, TLS desabilitado, CORS wildcard, debug mode, crypto fraca |
| **dependency-check** | Apos Edit/Write em arquivos de pacote | **Alerta** sobre versoes wildcard, deps git, deps sem pin. Roda `npm audit`/`pip-audit`/`cargo audit` se disponivel |

Mais os hooks de seguranca existentes:

| Hook | Trigger | Acao |
|:---|:---|:---|
| **validate-bash** | Antes de qualquer Bash | Bloqueia comandos destrutivos (rm -rf), exposicao de secrets, exfiltracao |
| **auto-format** | Apos Edit/Write | Roda formatter do stack em arquivos modificados |
| **teammate-idle** | Evento idle do Agent Teams | Mantem teammates ativos enquanto ha tasks |
| **task-completed** | Evento task do Agent Teams | Quality gate antes de fechar tasks |

---

## Instalacao

Escolha uma opcao:

### One-liner *(recomendado)*

```bash
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash
```

### Download manual (sem git)

```bash
curl -sL https://github.com/brunobracaioli/claude-forge/archive/main.tar.gz | tar xz -C /tmp
mkdir -p ~/.claude/skills/claude-forge
cp -r /tmp/claude-forge-main/{SKILL.md,scripts,templates,stacks,presets} ~/.claude/skills/claude-forge/
chmod +x ~/.claude/skills/claude-forge/scripts/*.sh
rm -rf /tmp/claude-forge-main
```

### Plugin Claude Code

```
/plugins install claude-forge
```

> **Nota:** O Claude Forge e instalado como skill somente leitura — nenhum repositorio git e vinculado. Para atualizar, basta re-executar o instalador.

---

## Estrutura Gerada

```
seu-projeto/
├── CLAUDE.md                          <- Instrucoes do time (< 200 linhas)
├── docker-compose.yml                 <- Dev local (dependente do preset)
├── Dockerfile                         <- Build multi-stage (preset production)
├── terraform/                         <- Modulos IaC (preset production)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/{vpc,database,compute}
├── .github/workflows/                 <- Pipelines CI/CD (dependente do preset)
│   ├── ci.yml
│   └── deploy.yml                     <- (apenas preset production)
│
└── .claude/
    ├── settings.json                  <- Permissoes + hooks
    ├── .gitignore                     <- Ignora arquivos pessoais
    ├── checkpoints/                   <- Snapshots de continuidade de sessao
    │
    ├── rules/                         <- Instrucoes modulares
    │   ├── code-style.md
    │   ├── testing.md
    │   ├── security.md
    │   ├── git-workflow.md
    │   ├── agent-creation.md
    │   ├── architecture.md            <- (dependente do preset)
    │   └── <stack>-conventions.md
    │
    ├── skills/                        <- Slash commands (10 total)
    │   ├── review/SKILL.md            <- /review
    │   ├── fix-issue/SKILL.md         <- /fix-issue <n>
    │   ├── spec/SKILL.md              <- /spec <feature>
    │   ├── spec-build/SKILL.md        <- /spec-build (Agent Teams)
    │   ├── commit/SKILL.md            <- /commit
    │   ├── checkpoint/SKILL.md        <- /checkpoint
    │   ├── security-audit/SKILL.md    <- /security-audit
    │   ├── infra-audit/SKILL.md       <- /infra-audit
    │   ├── pentest-recon/SKILL.md     <- /pentest-recon
    │   └── example-skill/SKILL.md
    │
    ├── agents/                        <- 15 agentes
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
    └── hooks/                         <- 7 hooks por evento
        ├── validate-bash.sh
        ├── secret-scan.sh
        ├── sast-scan.sh
        ├── dependency-check.sh
        ├── auto-format.sh
        ├── teammate-idle.sh
        └── task-completed.sh
```

---

## Customizacao

Todos os arquivos gerados com marcadores `[CUSTOMIZE]` precisam de ajuste.

**Edite nesta ordem** — maior impacto primeiro:

| Prioridade | Arquivo | Por que |
|:---:|:---|:---|
| 1 | `CLAUDE.md` | Claude le isso toda sessao. Acerte de primeira. |
| 2 | `.claude/settings.json` | Ajuste allow/deny para suas ferramentas. |
| 3 | `.claude/rules/` | Delete o que nao se aplica, adicione o que falta. |
| 4 | `.claude/hooks/auto-format.sh` | Descomente o formatter do seu stack. |
| 5 | `terraform/variables.tf` | Preencha valores do projeto (preset production). |
| 6 | `.claude/skills/` | Adicione workflows especificos do projeto. |

<details>
<summary><strong>Criar novo skill</strong></summary>

```bash
mkdir -p .claude/skills/deploy
cat > .claude/skills/deploy/SKILL.md << 'EOF'
---
name: deploy
description: Deploy para staging ou producao
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
<summary><strong>Criar novo agent</strong></summary>

```bash
cat > .claude/agents/db-explorer.md << 'EOF'
---
name: db-explorer
description: Explorar schema e dados do banco
model: haiku
tools: Read, Bash(psql *)
---
Voce e um especialista em banco de dados...
EOF
```

Agentes rodam em context windows isoladas — nao poluem sua sessao principal.

</details>

---

## Build Spec-Driven (Agent Teams)

Va do spec ao codigo funcional com um unico comando. O Claude Forge inclui um workflow completo de **desenvolvimento spec-driven** usando Agent Teams.

### O fluxo

```
/spec <feature>          ->  Entrevista -> SPEC.md
/spec-build              ->  SPEC.md -> projeto funcional (com validacao de seguranca + checkpoint)
```

### O que acontece quando voce roda `/spec-build`

```
┌─────────────────┐
│   Orchestrator   │  Le spec, cria contrato de API,
│   (team lead)    │  quebra trabalho em tasks com deps
└────────┬────────┘
         │
   ┌─────┼─────────────┬──────────────┬──────────────┐
   ▼     ▼             ▼              ▼              ▼
┌──────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ API  │ │ Frontend │ │  Tests   │ │ Security │ │  Review  │
│ Dev  │ │ Dev      │ │  Writer  │ │ Auditor  │ │  & QA    │
└──────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
  Fase 1   Fase 1      Fase 2       Fase 3       Fase 3
```

1. **Orchestrator** le o spec e cria `docs/api-contract.md` — o contrato compartilhado
2. **api-developer** + **frontend-developer** trabalham em paralelo (diretorios diferentes, mesmo contrato)
3. **test-writer** cobre o codigo implementado
4. **security-auditor** valida OWASP + **code-reviewer** verifica qualidade
5. **Checkpoint automatico** — se testes passam e sem issues criticas, cria snapshot taggeado

### Ativando

Altere no `.claude/settings.json` (ja vem scaffolded, so mude para `"1"`):

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Permissoes — plug-and-play

O settings vem pre-configurado para que agentes trabalhem autonomamente:

| Permitido (seguro, reversivel) | Bloqueado (destrutivo, irreversivel) |
|---|---|
| Read, Write, Edit, Glob, Grep | `rm -rf /`, `rm -rf ~`, `rm -rf .` |
| git add, commit, checkout, diff, log | `git push`, `git push --force`, `git reset --hard` |
| npm/pip/cargo run, test, install | `curl -d` (envio de dados), `wget --post` |
| mkdir, cp, mv, touch, chmod | Leitura de arquivos `.env` |
| terraform plan/validate/fmt (production) | `terraform apply/destroy`, `docker push` |

Ferramentas especificas do stack (pytest, npx, cargo, etc.) sao auto-mergeadas quando voce escolhe um stack.
Ferramentas do preset (terraform, docker, trivy, etc.) sao auto-mergeadas quando voce escolhe um preset.

### Usando agentes individualmente

Todos os 15 agentes tambem funcionam como subagentes standalone ou teammates manuais:

```
Spawn a teammate using the code-reviewer agent to review the auth module.
Spawn a teammate using the test-writer agent to cover the new endpoints.
Spawn a teammate using the security-auditor agent to audit the payment flow.
Spawn a teammate using the ux-designer agent to review the onboarding flow.
Spawn a teammate using the web-researcher agent to find the best auth library for Next.js.
Spawn a teammate using the codebase-navigator agent to map the auth module dependencies.
Spawn a teammate using the project-planner agent to plan the payments feature.
```

### Hooks do time

| Hook | O que faz |
|---|---|
| `teammate-idle.sh` | Mantem teammates ativos enquanto houver tasks pendentes |
| `task-completed.sh` | Quality gate — descomente para exigir testes/lint antes de fechar tasks |

### Boas praticas

- Comece com **3-5 teammates** — acima disso, overhead de coordenacao supera os ganhos
- Mire em **5-6 tasks por teammate** para manter todos produtivos
- **Evite dois teammates editando o mesmo arquivo** — sem protecao contra conflitos de merge
- Use `/spec` primeiro para gerar um spec completo — melhor spec = melhor output
- Limpe via o lead: `Clean up the team`

---

## Skills de Seguranca

Tres skills dedicados para auditoria completa:

| Skill | O que faz |
|:---|:---|
| `/security-audit` | Review estruturado OWASP Top 10 — injection, broken auth, misconfigurations, deps vulneraveis. Usa gitleaks, semgrep, bandit se disponiveis. |
| `/infra-audit` | Review de Terraform, Docker, CI/CD — IAM wildcards, S3 publico, actions sem pin, encriptacao faltando. |
| `/pentest-recon` | Mapeamento passivo de superficie de ataque a partir do codigo — endpoints, fluxos de auth, vetores de input, fluxos de dados. Apenas para testes de seguranca autorizados. |

---

## Checkpoints de Desenvolvimento

```
/checkpoint auth-complete
```

Cria um snapshot verificado do seu projeto:

1. **Roda testes** — falha rapido se testes nao passam (nao cria checkpoint em estado quebrado)
2. **Commita** estado limpo com mensagem `checkpoint: <label>`
3. **Tageia** com `checkpoint/<data>/<label>` (annotated git tag)
4. **Salva contexto** em `.claude/checkpoints/<tag>.md` — resumo do estado, mudancas recentes, foco atual, proximos passos

Comece sua proxima sessao lendo o arquivo de checkpoint — recuperacao instantanea de contexto.

---

## Principios de Design

Estes templates seguem as [melhores praticas oficiais da Anthropic](https://code.claude.com/docs/en/best-practices):

| Principio | Por que |
|:---|:---|
| **CLAUDE.md abaixo de 200 linhas** | Arquivos maiores degradam a aderencia as instrucoes. Excedente vai pra `rules/`. |
| **Progressive disclosure** | `@references` carregam sob demanda — nao encha o contexto. |
| **Seguranca por padrao** | Hooks bloqueiam secrets e flagam vulnerabilidades automaticamente. Sem opt-in. |
| **Seguranca deterministica** | Hooks bloqueiam comandos perigosos 100% das vezes. CLAUDE.md fica em ~70%. |
| **Git-friendly** | Arquivos do time commitados. Pessoais (`.local.md`, `.local.json`) no gitignore. |
| **Nao-destrutivo** | Nunca sobrescreve arquivos existentes. Seguro re-executar em qualquer projeto. |
| **Budget de ~150 instrucoes** | O system prompt do Claude Code usa ~50. Sua config divide o resto. |

---

## Solucao de Problemas

<details>
<summary><strong>Agentes/skills faltando apos atualizacao</strong></summary>

Se voce atualizar o Claude Forge e re-rodar `/claude-forge`, novos templates nao aparecem porque o `safe_copy` nunca sobrescreve arquivos existentes. Para pegar novos agentes (ou qualquer template novo):

```bash
# Re-instale a skill (re-execute o instalador)
curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash

# Remova os diretorios antigos para os novos templates serem copiados
rm -rf seu-projeto/.claude/agents/
rm -rf seu-projeto/.claude/hooks/
rm -rf seu-projeto/.claude/skills/

# Re-rode dentro do Claude Code
/claude-forge react --preset mvp
```

O mesmo vale para qualquer arquivo de template novo (rules, skills, hooks).

</details>

---

## Contribuindo

Contribuicoes sao bem-vindas! Algumas ideias:

| Categoria | Exemplos |
|:---|:---|
| **Novos stacks** | Django, Go, Java/Spring, PHP/Laravel, .NET |
| **Novos presets** | serverless, microservices-k8s, edge-first |
| **Novos skills** | deploy, changelog, migration, docs-update |
| **Novos agents** | performance-profiler, accessibility-auditor, api-designer |
| **Novos security hooks** | license-check, container-scan, SBOM generation |
| **Traducoes** | Ajude a traduzir templates para outros idiomas |

Veja [CONTRIBUTING.md](./docs/CONTRIBUTING.md) para as diretrizes.

---

## Referencias

- [Best Practices — Claude Code Docs](https://code.claude.com/docs/en/best-practices)
- [Using CLAUDE.md Files — Anthropic Blog](https://claude.com/blog/using-claude-md-files)
- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)

---

<p align="center">
  <sub>Feito com ⚡ por <a href="https://github.com/brunobracaioli">@brunobracaioli</a></sub><br>
  <sub>Licenca MIT</sub>
</p>
