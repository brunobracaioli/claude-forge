# Test fixtures

Minimal directory trees used by `tests/bootstrap_test.bats` and CI to validate `auto_detect_stack()` in `scripts/bootstrap.sh`.

Each fixture contains only the marker files the detector keys off — nothing more.

| Fixture | Expected stack | Marker(s) |
|---|---|---|
| `next-app/` | `react` | `next.config.js` + `package.json` |
| `flask-next-app/` | `flask-next` | `next.config.js` + `requirements.txt` |
| `node-app/` | `node` | `package.json` only |
| `python-app/` | `python` | `pyproject.toml` |
| `rust-app/` | `rust` | `Cargo.toml` |
| `django-app/` | `django` | `manage.py` |
| `go-app/` | `go` | `go.mod` |
| `laravel-app/` | `laravel` | `artisan` |
| `generic-app/` | `generic` | no markers |
