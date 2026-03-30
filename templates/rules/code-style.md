---
# [CUSTOMIZE] Remove or adjust paths for your project
# paths:
#   - "src/**/*"
#   - "app/**/*"
---

# Code Style

[CUSTOMIZE] Add only rules that Claude would violate without being told.
Linter/formatter rules belong in their config files, not here.

## General

- Prefer small, focused functions (< 30 lines)
- Fail early — validate inputs at the top, return/throw immediately
- No magic numbers — use named constants
- No commented-out code — delete it, git has history

## Naming

- Variables/functions: `camelCase` (JS/TS) or `snake_case` (Python)
- Classes/types: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Files: `kebab-case` (JS/TS) or `snake_case` (Python)
- Boolean variables: prefix with `is_`, `has_`, `should_`, `can_`

## Error Handling

- Never swallow errors silently
- Always include context in error messages (what failed, with what input)
- Use typed/custom errors, not generic Error/Exception
- Log errors with structured data, not string interpolation
