---
paths:
  - "**/*.py"
  - "**/urls.py"
  - "**/settings/*.py"
---

# Django Conventions

## Settings

- Split `settings/` into `base.py`, `dev.py`, `prod.py` (or use `django-environ`)
- Production flags that MUST be set:
  - `DEBUG = False`
  - `ALLOWED_HOSTS = [...]` (explicit)
  - `SECURE_SSL_REDIRECT = True`
  - `SESSION_COOKIE_SECURE = True`
  - `CSRF_COOKIE_SECURE = True`
  - `SECURE_HSTS_SECONDS >= 31536000`
  - `SECURE_CONTENT_TYPE_NOSNIFF = True`
  - `X_FRAME_OPTIONS = "DENY"`
- `SECRET_KEY`, database creds, third-party tokens from environment — never hardcoded

## Models & ORM

- One model per logical entity; keep `__str__` meaningful for admin
- Migrations are code — reviewed in PRs like any other change
- Never `makemigrations --merge` without understanding what's being merged
- Use `RunPython` sparingly and always provide `reverse_code`
- Audit queries with `django-debug-toolbar` in dev; resolve N+1 via `select_related` / `prefetch_related`
- `QuerySet.iterator()` for large exports to avoid memory blowups

## Views & Services

- Class-based views or function-based — pick one per project and stick to it
- Views are thin: parse input → call service → return response
- Services are plain functions (or classes with DI); they don't know about `request`
- Never query the ORM in views or serializers if avoidable

## Forms & Serializers

- Always list `fields` explicitly — `fields = "__all__"` is a mass-assignment foot-gun
- For DRF, pair `ModelSerializer` with explicit `fields` + custom `validate_*` methods
- Validate at the boundary (serializer / form); reject early, with clear messages

## Templates & Output

- Auto-escape always on; use `{{ value|safe }}` only after threat-modeling the input
- Reverse URLs by name, not hardcoded paths
- Static files served by CDN / object storage in prod — never Django in prod

## Testing

- pytest-django with a PostgreSQL test database (not SQLite — migrations diverge)
- Factories (factory_boy) over fixtures
- One integration test per happy-path view; unit tests for services
- Transactional DB isolation per test (default in pytest-django)

## Security

- Middleware order matters: `SecurityMiddleware` first, then `SessionMiddleware`, then `CsrfViewMiddleware`
- Permissions/authorization checked at the view layer AND at the service layer (defense in depth)
- Avoid `raw()` / `extra()` — use parameterized ORM queries; if you must, use `params=[...]`
- File upload validation: content-type, magic-byte sniffing, size limits, safe storage
