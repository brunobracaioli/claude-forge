---
paths:
  - "backend/**/*.py"
---

# Flask Conventions

## Structure

- Application factory pattern: `create_app()` in `app/__init__.py`
- Blueprints in `app/routes/`, one per domain
- Business logic in `app/services/`, never in routes
- Models in `app/models/`, SQLAlchemy declarative base
- Schemas in `app/schemas/`, for validation and serialization

## Database

- Always use SQLAlchemy ORM, never raw SQL
- Alembic for migrations — auto-generate then review before applying
- Use `db.session` context manager, never manual commit/rollback
- Soft delete preferred: `deleted_at` timestamp, not actual DELETE

## Patterns

- Dependency injection via Flask `g` or function parameters
- Use `@app.errorhandler` for global error handling
- Configuration via environment variables, loaded in `config.py`
- Type hints on all function signatures
- Docstrings on public service functions

## Testing

- pytest + pytest-flask
- Fixtures for app, client, db session, and authenticated user
- Each test function gets a fresh transaction (rollback after)
