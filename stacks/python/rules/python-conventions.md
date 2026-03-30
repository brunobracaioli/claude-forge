---
paths:
  - "**/*.py"
---

# Python Conventions

## Type Hints

- Required on all function signatures (params + return type)
- Use `from __future__ import annotations` for forward references
- Prefer `X | None` over `Optional[X]` (Python 3.10+)
- Use `TypeVar` and `Generic` for reusable typed abstractions
- No `# type: ignore` without a comment explaining why

## Structure

- One class per file for models and schemas
- Services are stateless functions, not classes (unless DI requires it)
- Imports: stdlib → third-party → local, separated by blank lines
- Relative imports within a package, absolute imports across packages

## Error Handling

- Never bare `except:` — always `except SpecificException`
- Custom exceptions inherit from a project base exception
- Include context in exception messages: what failed, with what input
- Use `logging.exception()` in catch blocks (captures traceback)

## Testing

- pytest with fixtures in `conftest.py`
- Parametrize tests for multiple input scenarios
- Factories for test data (factory_boy or manual)
- Mock external services at the adapter boundary
