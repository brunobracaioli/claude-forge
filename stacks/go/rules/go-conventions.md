---
paths:
  - "**/*.go"
  - "go.mod"
  - "go.sum"
---

# Go Conventions

## Project Layout

- `cmd/<binary>/main.go` — thin entrypoint, wires dependencies, starts server
- `internal/` — everything that isn't a reusable library; Go enforces non-importability
- `pkg/` — only when you genuinely ship a reusable package (rare)
- One package per directory; package name matches directory name

## Errors

- Wrap with context: `fmt.Errorf("reading config: %w", err)` — never bare return
- `errors.Is` / `errors.As` for type checks; `sentinel` errors are package-level vars named `ErrXxx`
- `panic` only for genuinely unrecoverable programming bugs (constructor invariant violations)
- HTTP handlers never `panic` to clients — recover middleware must convert to 500s
- Service-layer errors are domain-typed; transport layer translates to HTTP codes

## Concurrency

- Goroutines must have a clear lifecycle — tie to `context.Context` cancellation
- Channels are for synchronization, not data pipelines across module boundaries
- `sync.Mutex` over channels for simple shared-state protection
- `go test -race` is mandatory in CI
- Every long-lived goroutine needs a way to shut down gracefully

## Interfaces

- Define interfaces at the consumer site, not beside the implementation
- Small interfaces (1–3 methods) — `io.Reader`, not `FullDatabase`
- Accept interfaces (flexibility), return concrete structs (discoverability)

## Logging

- `log/slog` (stdlib, structured) over `fmt.Println` or third-party loggers
- Key-value attributes, not interpolated strings
- Never log secrets; sanitize request IDs, user inputs, headers
- One logger per scope with bound context (request ID, tenant, user)

## HTTP

- `context.Context` threaded from `r.Context()` through services to storage
- Timeouts on every outgoing HTTP call and database query
- Parse and validate request bodies at the boundary; reject early
- Set `ReadTimeout`, `WriteTimeout`, `IdleTimeout` on `http.Server`

## Testing

- Table-driven tests for anything with variants
- `t.Parallel()` where safe; combined with `-race` catches state leaks
- Integration tests under `_test.go` with `//go:build integration`
- Use `testcontainers-go` or docker-compose for DB tests — not SQLite mocks

## Security

- `crypto/rand` for randomness — NEVER `math/rand` for anything security-sensitive
- `database/sql` with parameterized queries; no string concatenation
- `html/template` auto-escapes — don't pipe through `template.HTML` without review
- Dependencies pinned in `go.sum`; review `go mod tidy` diffs carefully
