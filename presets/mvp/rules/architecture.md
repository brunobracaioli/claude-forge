---
description: Architecture rules for MVP/free-tier preset — monolithic, fast iteration, minimal infra
globs: ["**/*"]
---

# MVP Architecture Rules

## Core Principle
Ship fast with a monolithic architecture. Extract services only when there's a concrete, measured need.

## Structure
- **Single deployable unit.** One repo, one deploy target. No microservices, no service mesh.
- **Vertical slices within the monolith.** Each feature is self-contained: route → service → data access. No god modules.
- **Shared database.** One database instance (Supabase Postgres recommended). Separate schemas or prefixes per domain if needed, but no separate DB instances.
- **Edge-first deployment.** Use Vercel/Netlify/Cloudflare for frontend + serverless functions. No container orchestration.

## Infrastructure
- **Supabase** for auth, database, storage, and realtime. Use RLS policies — no custom auth middleware unless Supabase auth is insufficient.
- **Vercel/Netlify** for frontend hosting and serverless API routes.
- **Upstash** for Redis (rate limiting, caching, queues). Use only when in-memory/Supabase isn't enough.
- **No Terraform, no Docker in production.** Docker for local dev only. Infra is managed by platform (Supabase dashboard, Vercel project settings).

## What NOT To Do
- Don't create separate services for features that could be a module.
- Don't add message queues, event buses, or pub/sub until you have a measured bottleneck.
- Don't provision AWS/GCP resources. Stay on managed platforms.
- Don't write custom auth. Use Supabase Auth or equivalent managed auth.
- Don't add caching layers before measuring that something is slow.

## When To Graduate
Move to the Production preset when ANY of these are true:
- Team grows beyond 3 developers working on the same codebase
- Single-region deployment causes measurable latency issues
- Managed platform limits (Vercel function timeout, Supabase connection limits) are blocking
- Compliance/regulatory requirements mandate specific infrastructure controls
