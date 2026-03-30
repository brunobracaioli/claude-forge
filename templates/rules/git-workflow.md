# Git Workflow

## Branches

[CUSTOMIZE] Define your branching model.

- `main` — production-ready, protected
- `develop` — integration branch (if applicable)
- Feature branches: `feature/<short-description>`
- Bugfix branches: `fix/<short-description>`
- Hotfix branches: `hotfix/<short-description>`

## Commits

- Use conventional commits: `type(scope): description`
  - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`, `perf`
- Keep commits atomic — one logical change per commit
- Never commit directly to `main`
- Never commit generated files, build artifacts, or `.env`

## Before Pushing

1. Run linter
2. Run tests (at minimum, tests for changed files)
3. Review your own diff: `git diff --stat` then `git diff`
4. Ensure no secrets, debug logs, or TODO hacks in the diff

## When Compacting

When context is compacted (/compact), preserve:
- Full list of files modified in this session
- Current branch name and recent commit hashes
- Failing test names and error messages
- Any pending decisions or blockers
