# Changelog

All notable changes to **claude-forge** are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-04-22

### Added
- **Django stack** (`stacks/django/`) — auto-detects via `manage.py`. CLAUDE.md covers migrations-in-CI, service-layer pattern, mass-assignment guards, `SECURE_*` production headers; `django-conventions.md` enforces explicit serializer `fields`, `select_related`/`prefetch_related` discipline, middleware ordering.
- **Go stack** (`stacks/go/`) — auto-detects via `go.mod`. CLAUDE.md covers `internal/` layout, `-race` in CI, error wrapping, context propagation; `go-conventions.md` codifies interface-at-consumer, `log/slog`, goroutine lifecycle management.
- **Laravel stack** (`stacks/laravel/`) — auto-detects via `artisan`. CLAUDE.md covers FormRequest → Service, `$fillable` discipline, `config:cache`/`route:cache` in deploy, idempotent jobs; `laravel-conventions.md` enforces policies-at-both-layers, Pest + `RefreshDatabase`, Cloud-Armor-equivalent WAF discipline.
- **`production-gcp` preset** — Terraform (VPC + Cloud NAT + Serverless VPC Access connector, Cloud SQL Postgres with private IP + PITR + IAM auth, Cloud Run with per-service SA and Secret Manager integration), multi-stage Dockerfile respecting `$PORT`, docker-compose (Postgres + Redis), GitHub Actions CI (lint + test + gitleaks + Trivy FS + `terraform validate`) and Deploy workflow using **Workload Identity Federation** — no long-lived JSON service-account keys.
- Auto-detection markers: `manage.py` → `django`, `go.mod` → `go`, `artisan` → `laravel`. Framework-specific markers take precedence over generic language markers (so a Django repo with `requirements.txt` correctly resolves to `django`, not `python`).
- New test fixtures: `django-app/`, `go-app/`, `laravel-app/`.
- CI matrix expanded to 2 × 9 × 4 = **72 cells** (OS × stack × preset), plus a dedicated `legacy-alias` job verifying `--preset production` still routes to `production-aws` with deprecation warning.

### Changed
- **Renamed `presets/production/` → `presets/production-aws/`** to make room for `production-gcp` and future cloud-specific siblings. The `aws` suffix makes the cloud explicit in the preset name.
- **`production` (without suffix) is now a deprecated alias** for `production-aws`. It still works and emits a deprecation warning. The alias will be removed in v2.0.
- `bootstrap.sh` validates the new `VALID_STACKS` (`django`, `go`, `laravel` added) and `VALID_PRESETS` (`production-aws`, `production-gcp` added).
- Summary output differentiates AWS vs. GCP infrastructure callouts at the end of bootstrap.
- Documentation (`README.md`, `SKILL.md`) reflects the 9 stacks / 3 presets / deprecation note.

### Architectural decisions
- **Cloud split over `--cloud=` flag.** Terraform backends (S3+DynamoDB vs. GCS), primitives (ECS Fargate vs. Cloud Run), and IAM models (AWS IAM vs. GCP service accounts + WIF) differ deeply enough that parametrizing one `production` preset would force a thick abstraction without real reuse. Separate presets keep each module honest.
- **Framework-first detection.** The detector now checks framework markers (`manage.py`, `artisan`, `go.mod`) before generic language markers — a Django repo is a Django repo, not a "python with extras."

## [1.1.0] - internal milestone, rolled into v1.2.0

> Not published as a standalone tag. The foundation work below shipped as part of the v1.2.0 release.

### Added
- `VERSION` file as single source of truth for semver.
- `CHANGELOG.md` (this file).
- `install.sh` accepts `--ref <tag>` flag and `CLAUDE_FORGE_REF` env var to pin install to a specific release (e.g. `CLAUDE_FORGE_REF=v1.1.0`).
- `bootstrap.sh --update` flag with non-destructive hash-matching update mode. Files unchanged from shipped templates are updated in-place; modified files are preserved and the new version is written alongside as `<file>.new`.
- `bootstrap.sh --tier core|full` flag. Default is `core` (5 universal agents: `code-reviewer`, `debugger`, `test-writer`, `security-auditor`, `orchestrator`). `--tier full` installs all 15 agents.
- `templates/agents/TIERS.json` — manifest mapping agents to tiers.
- `scripts/gen_manifest.sh` — generates `manifest.json` with sha256 per shipped file (consumed by `--update`).
- `.github/workflows/ci.yml` — matrix CI (ubuntu + macos × 6 stacks × 3 presets) running bootstrap, JSON validation, CLAUDE.md line-count check, hook executable assertion, `terraform validate` on production preset, plus `shellcheck` and `bats` unit tests.
- `.github/workflows/release.yml` — on tag push, validates CHANGELOG entry, generates manifest, creates GitHub Release.
- `tests/bootstrap_test.bats` — unit tests for `auto_detect_stack`, `safe_copy`, settings jq merge, and tier gating.
- `tests/fixtures/` — minimal stack marker trees for auto-detect regression tests.

### Changed
- Default agent install count reduced from 15 to 5 (opt-in to full via `--tier full`). Resolves contradiction with the README's "start with 3-5 teammates" guidance.
- Install documentation now recommends pinned installs via `CLAUDE_FORGE_REF=v1.1.0` over the rolling `main` install.
- `scripts/bootstrap.sh` — `safe_copy` now accepts an update mode that reads `manifest.json` for hash-based collision resolution.

### Fixed
- Documented update UX: users no longer need `rm -rf .claude/agents/` to pick up new templates; they run `--update` instead.

### Deprecated
- The rolling `curl | bash` install against `main` remains functional but is no longer the recommended path. Pin to a tag.

### Security
- Install flow now supports reproducible installs via tag pinning — eliminates the class of supply-chain risk where a compromised `main` silently propagates to all users.

## [1.0.0] - 2025-XX-XX

### Added
- Initial public release.
- Orthogonal stack × preset architecture.
- Stacks: `flask-next`, `node`, `python`, `react`, `rust`, `generic`.
- Presets: `mvp` (monolith + Supabase/Vercel), `production` (multi-service + Terraform + AWS), `none`.
- 10 skills: `/commit`, `/fix-issue`, `/review`, `/spec`, `/spec-build`, `/checkpoint`, `/security-audit`, `/infra-audit`, `/pentest-recon`, `/example-skill`.
- 15 agents scaffolded by default.
- 7 hooks: `validate-bash`, `secret-scan`, `sast-scan`, `dependency-check`, `auto-format`, `teammate-idle`, `task-completed`.
- Security-by-default: `secret-scan`, `sast-scan`, `dependency-check` active with no opt-in required.
- Bilingual documentation (PT-BR / EN).

[Unreleased]: https://github.com/brunobracaioli/claude-forge/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/brunobracaioli/claude-forge/compare/v1.0.0...v1.2.0
[1.0.0]: https://github.com/brunobracaioli/claude-forge/releases/tag/v1.0.0
