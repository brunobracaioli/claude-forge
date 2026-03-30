---
# [CUSTOMIZE] Scope to test files
# paths:
#   - "tests/**/*"
#   - "**/*.test.*"
#   - "**/*.spec.*"
---

# Testing

## Strategy

[CUSTOMIZE] Define your test approach.

- Unit tests for business logic and utilities
- Integration tests for API endpoints and database operations
- Prefer testing behavior, not implementation details

## Commands

```bash
[CUSTOMIZE]
# Run all tests:
# Run single test:
# Run with coverage:
# Reset test DB:
```

## Conventions

- Test files mirror source structure: `src/services/foo.ts` → `tests/services/foo.test.ts`
- Test names describe behavior: `should return 404 when user not found`
- Each test is independent — no shared mutable state between tests
- Use factories/fixtures for test data, not hardcoded objects
- Never mock what you don't own — wrap external deps in adapters, mock the adapter

## Before Committing

- Run the relevant test file after each change, not the full suite
- Full suite runs in CI — locally, focus on the files you changed
