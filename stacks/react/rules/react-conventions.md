---
paths:
  - "src/**/*.tsx"
  - "src/**/*.ts"
  - "src/components/**/*"
---

# React / Next.js Conventions

## Components

- Functional components only with named exports
- Props interface co-located above the component in the same file
- Prefer composition over prop drilling: Context, compound components
- Server components by default — add `'use client'` only for interactivity
- Every component handles three states: loading, error, empty

## Hooks

- Custom hooks in `src/hooks/`, prefixed with `use`
- Extract logic from components when: reused 2+ times, complex state, side effects
- Never call hooks conditionally or inside loops
- Use `useCallback` / `useMemo` only when there's a measured perf issue

## Data Fetching

- Server components: fetch directly with `async/await`
- Client components: React Query / SWR for cache + revalidation
- API client in `src/lib/api.ts` — typed request/response wrappers
- Error boundaries at route/feature level, not per-component

## Styling

- Tailwind utility classes for layout and spacing
- Component variants via `cva` (class-variance-authority) or similar
- No inline `style={{}}` except for truly dynamic values (e.g., CSS custom props)
- Responsive: mobile-first with Tailwind breakpoints (`sm:`, `md:`, `lg:`)

## Accessibility

- Semantic HTML: `<button>` not `<div onClick>`, `<nav>`, `<main>`, `<section>`
- ARIA labels on interactive elements without visible text
- Keyboard navigation: focusable, Enter/Space to activate, Escape to close
- Color contrast: WCAG AA minimum (4.5:1 for text)
