---
paths:
  - "src/**/*.ts"
  - "src/**/*.tsx"
---

# Node.js / TypeScript Conventions

## Modules

- ES modules only: `import/export`, never `require()`
- Destructure imports: `import { Router } from 'express'`
- Barrel exports (`index.ts`) only at package boundaries, not every folder
- Path aliases via tsconfig paths: `@/lib`, `@/services`

## Error Handling

- Custom error classes extending `AppError` with status code and error code
- Express: async handler wrapper that catches and forwards to error middleware
- Never throw raw strings — always Error objects with context
- All Promise chains must have `.catch()` or be `await`ed in try/catch

## TypeScript

- `strict: true` in tsconfig — no exceptions
- No `any` — use `unknown` and narrow with type guards
- No `!` non-null assertion — check explicitly
- Prefer `interface` for object shapes, `type` for unions/intersections
- Return types on exported functions (inferred is OK for private)
