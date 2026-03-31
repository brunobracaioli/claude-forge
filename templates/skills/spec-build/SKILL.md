---
name: spec-build
description: >
  Spec-driven project build using Agent Teams. Reads a SPEC.md file (or receives
  a feature description), creates a shared API contract, then spawns a multi-agent
  team to implement backend and frontend in parallel. Use when the user says
  "build from spec", "implement the spec", "spec-build", "build this project",
  "monte o projeto a partir do spec", or wants to go from specification to
  working code using parallel agents.
argument-hint: "[path-to-spec.md]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
---

## Spec-Driven Build — Orchestration Flow

### Step 1 — Locate and validate the spec

Find the spec file. Check in order:
1. `$ARGUMENTS` if a path was provided
2. `SPEC.md` in the project root
3. `docs/SPEC.md`

If no spec file is found, tell the user:
> No spec file found. Run `/spec <feature>` first to generate one, then run `/spec-build` again.

Read the spec completely. Verify it contains at minimum:
- Functional requirements
- API contracts or data model
- Technical design (stack, architecture)

If the spec is too vague to implement, ask the user to run `/spec` first.

### Step 2 — Pre-flight checks

Before spawning any agent, verify the environment:

```bash
# Check Agent Teams is enabled
echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
```

If Agent Teams is not enabled (`!= "1"`), tell the user:
> Agent Teams is not enabled. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to `"1"` in `.claude/settings.json`, then try again.

Check the project has been bootstrapped (`.claude/agents/` exists with agent files). If not, suggest running `/claude-forge` first.

### Step 3 — Create the shared API contract

Extract all API contracts from the spec and write them to a contract file that both backend and frontend will use as their source of truth.

Write to `docs/api-contract.md` with this structure:

```markdown
# API Contract
> Auto-generated from SPEC.md — single source of truth for backend and frontend.

## Base URL
[from spec or convention]

## Authentication
[auth mechanism, header format, token flow]

## Endpoints

### [GROUP NAME]

#### [METHOD] /path
- **Description**: what it does
- **Auth**: required/optional
- **Request body**: { schema }
- **Response 200**: { schema }
- **Response 4xx/5xx**: { error schema }

## Shared Types
[TypeScript interfaces or JSON schemas for shared entities]

## Error Format
[standard error response shape]
```

### Step 4 — Spawn the orchestrator

Spawn a teammate using the **orchestrator** agent type:

```
Spawn a teammate using the orchestrator agent to build the project from the spec.

Context:
- Spec file: [path to SPEC.md]
- API contract: docs/api-contract.md
- Stack: [detected or from spec]
- Priority: implement API endpoints and UI components in parallel, then integrate, then test and review.
```

The orchestrator will:
1. Read the spec and contract
2. Create a task list with dependencies
3. Spawn backend (api-developer) and frontend (frontend-developer) teammates
4. Coordinate phases: implementation → integration → testing → review
5. Report results

### Step 5 — Monitor and report

While the orchestrator works, monitor the overall progress. When complete, present the user with:

```
## Build Complete

**Spec**: [file]
**Contract**: docs/api-contract.md
**Tasks**: [X] completed, [Y] total
**Files created**: [count]

### What was built
- [list of endpoints implemented]
- [list of pages/components implemented]

### What needs manual attention
- [CUSTOMIZE] markers to fill in
- Environment variables to configure (.env.example)
- Database setup/migration commands to run

### Next steps
1. Review the generated code
2. Run tests: [command]
3. Start the dev server: [command]
```
