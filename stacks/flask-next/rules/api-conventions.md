---
paths:
  - "backend/app/routes/**/*.py"
  - "backend/app/services/**/*.py"
  - "frontend/src/lib/api*"
---

# API Conventions

## Backend (Flask)

- Every route is in a Blueprint, one blueprint per domain
- Route pattern: validate → service call → format response
- Response shape: `{"data": ..., "error": null, "meta": {...}}`
- Error shape: `{"data": null, "error": {"code": "...", "message": "..."}, "meta": null}`
- Use Pydantic or Marshmallow schemas for request validation
- HTTP status: 200 (ok), 201 (created), 400 (validation), 401 (auth), 403 (forbidden), 404 (not found), 500 (server)
- Pagination: cursor-based `{"cursor": "...", "limit": 20}`
- Never return Python tracebacks to the client

## Frontend (Next.js)

- API client lives in `frontend/src/lib/api.ts`
- Use typed response wrappers matching backend shape
- Handle loading, error, and empty states in every component
- Server components fetch directly; client components use SWR or React Query

## Cross-cutting

- Backend CORS must whitelist the frontend origin
- Auth tokens in HTTP-only cookies (not localStorage)
- All dates in ISO 8601 UTC
