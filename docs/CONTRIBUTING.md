# Contributing to Claude Project Bootstrap

Thanks for considering a contribution! Here's how to help.

## Adding a New Stack

1. Create a directory under `stacks/<stack-name>/`
2. Add these files:
   - `CLAUDE.md.template` — Stack-specific CLAUDE.md (keep under 60 lines, the base adds the rest)
   - `settings.json.override` — Additional allow/deny permissions for the stack's tools
   - `rules/<stack>-conventions.md` — Stack-specific coding conventions
3. Update `scripts/bootstrap.sh` to detect the stack (add pattern to `auto_detect_stack`)
4. Update both README files with the new stack in the table
5. Test: run the bootstrap in a real project with that stack

## Adding a New Skill (Slash Command)

1. Create a directory in `templates/skills/<name>/` with a `SKILL.md` inside
2. Use `$ARGUMENTS` for user input, `${CLAUDE_SKILL_DIR}` for skill-relative paths
3. Use `!`backtick`` syntax for dynamic shell output
4. Include YAML frontmatter with `name`, `description`, and optionally `argument-hint`
5. Add `disable-model-invocation: true` for skills with side effects (commits, deploys)
6. Add `allowed-tools` to restrict available tools

## Adding a New Agent

See `.claude/rules/agent-creation.md` for the complete field reference, design principles, and anti-patterns.

1. Create `.md` file in `templates/agents/`
2. Include frontmatter: `name`, `description`, `model`, `tools`, `maxTurns`, `memory`
3. Keep the persona focused — one job per agent
4. Restrict tools to minimum needed (read-only agents shouldn't have Write)
5. Define an explicit output format (severity, file:line, code snippets)
6. Add `memory: project` for agents that benefit from cross-session learning

## Adding a New Rule

1. Create `.md` file in `templates/rules/`
2. Add `paths:` frontmatter if it should only load for certain files
3. Keep it concise — rules eat into the ~150 instruction budget

## Guidelines

- Keep CLAUDE.md templates under 60 lines (base template adds ~20 more)
- Every `[CUSTOMIZE]` marker should have a clear hint of what to put there
- Test with both `/project-bootstrap <stack>` and natural language invocation
- Templates must work for brand new projects AND existing codebases
- Never overwrite existing files — `safe_copy` in bootstrap.sh enforces this

## Pull Request Process

1. Fork the repo
2. Create a feature branch: `feat/add-go-stack`
3. Make your changes
4. Test in a real project
5. Submit PR with a clear description of what you added/changed

## Code of Conduct

Be respectful, constructive, and welcoming. We're all here to make developer tools better.
