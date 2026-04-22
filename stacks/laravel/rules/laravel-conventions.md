---
paths:
  - "**/*.php"
  - "routes/*.php"
  - "config/*.php"
---

# Laravel Conventions

## Controllers & Routing

- Controllers are thin: inject `FormRequest`, call service/action, return response
- One action per controller (`__invoke`) for complex flows — easier to test, trivial to route
- Route groups for middleware (auth, throttle); never per-route duplication
- API resource responses via `JsonResource` classes — not ad-hoc arrays

## Validation & FormRequests

- `FormRequest` classes own both `rules()` and `authorize()`
- Validation rules include type checks (`integer`, `uuid`), size limits, format constraints
- Never trust `$request->all()` — reach for `$request->validated()` after validation
- Custom rule objects for complex invariants; don't bloat `rules()` with closures

## Eloquent & Database

- `$fillable` explicitly listed on every model — never `$guarded = []` (mass-assignment foot-gun)
- `$casts` for dates, enums, JSON columns — don't mutate in accessors
- N+1 hunted with `->with(...)` and DB telemetry (Debugbar, Telescope, or log `DB::listen`)
- Migrations are code: review in PRs; `php artisan migrate:status` in CI
- Every table has `created_at`/`updated_at` unless there's a reason not to
- Deletes: soft-delete (`SoftDeletes` trait) for business records; hard-delete for PII on request

## Services & Actions

- Business logic in `app/Services/` (stateful service) or `app/Actions/` (single-purpose invokable)
- Transactions explicit: `DB::transaction(fn() => ...)` around multi-write operations
- Events/Listeners for side effects (notifications, audit logs) — queued, idempotent
- Domain exceptions typed; converted to HTTP responses in `app/Exceptions/Handler.php`

## Jobs & Queues

- Every job is idempotent — retry = safe re-execution
- `$tries` and `$backoff` configured; dead-letter queue for poison messages
- Never store full payloads in jobs — pass IDs, reload inside the job
- Unique job constraints (`ShouldBeUnique`) for jobs that must not duplicate

## Security

- Authorization at both the controller (via `$this->authorize(...)`) and the policy level
- CSRF middleware on web routes; Sanctum token auth on API routes
- XSS protection: Blade auto-escapes; `{!! !!}` only for pre-sanitized HTML
- `config:cache` / `route:cache` / `view:cache` on every production deploy
- Secrets via env → config; no `env()` outside `config/*.php`
- Dependency audit: `composer audit` regularly; pin versions in `composer.json`

## Testing

- Pest (or PHPUnit) Feature tests for every controller + policy combination
- `RefreshDatabase` or `DatabaseTransactions` for isolation
- Factories with states (`User::factory()->admin()->create()`) — not hand-rolled fixtures
- HTTP-level assertions: `assertOk`, `assertJsonStructure`, `assertDatabaseHas`
