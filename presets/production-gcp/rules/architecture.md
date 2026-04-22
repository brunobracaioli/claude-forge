---
description: Architecture rules for Production-GCP preset — Cloud Run, Cloud SQL, Terraform, WIF-based CI/CD
globs: ["**/*"]
---

# GCP Production Architecture Rules

## Core Principle

Build for reliability, scalability, and auditability. Every infrastructure decision codified in Terraform, reviewable, and reproducible. No console clicks.

## Structure

- **Domain-driven boundaries.** Each bounded context is a deployable unit (Cloud Run service or module). Clear API contracts between domains.
- **Vertical slices per domain.** Within each service: handler → service → repository → entity. No cross-domain database queries.
- **API Gateway pattern.** Single entry point via Cloud Load Balancer or API Gateway. Internal services communicate via authenticated HTTPS or Pub/Sub.
- **Event-driven where appropriate.** Pub/Sub for async work, Cloud Tasks for scheduled or delayed execution.

## Infrastructure (Terraform)

- **IaC mandatory.** All infra in `terraform/`. No manual `gcloud` changes to resources.
- **State backend**: GCS bucket with object versioning ON, uniform bucket-level access, customer-managed encryption (CMEK) where required.
- **Per-environment projects**: `proj-dev`, `proj-stg`, `proj-prd`. Never share projects across environments.
- **Terraform remote backend per environment**; no shared state across envs.
- **Module structure**: `modules/vpc`, `modules/database`, `modules/compute` — parametrized by env.

## Compute (Cloud Run)

- Stateless containers. Scale to zero acceptable; cold-start tolerance enforced in SLOs.
- **Concurrency** tuned per service; default 80, measured against tail latency.
- **CPU allocation**: request-time (default) unless the workload needs background processing; then `cpu_idle = false`.
- **Min instances** ≥ 1 for latency-sensitive services; 0 for batch/cron.
- **Ingress**: `internal-and-cloud-load-balancing` unless genuinely public.
- **Timeouts**: explicit per request; default 300s max, set lower when appropriate.
- **Health checks**: `/health` (liveness) + `/ready` (readiness). Both return JSON with version + uptime.

## Database (Cloud SQL)

- Postgres 15+ with **automated daily backups** and **point-in-time recovery** (PITR) enabled.
- **Private IP only** — Cloud SQL connected via VPC peering; never public IP in production.
- **IAM authentication** for service accounts; password auth only for break-glass.
- **Connections via Cloud SQL Auth Proxy** or Private Service Connect from Cloud Run.
- **High availability** (regional) for production; zonal acceptable for dev.
- **Read replicas** for read-heavy workloads.

## Identity & Access

- **One service account per Cloud Run service.** No shared SAs across services.
- **Workload Identity Federation** for CI/CD from GitHub Actions — NEVER download JSON service account keys.
- **Permissions granted at the lowest scope** (service account → role → specific resource). No project-level `roles/editor` or `roles/owner`.
- **VPC Service Controls** around sensitive data perimeters (Cloud SQL, Secret Manager, GCS buckets with PII).

## Secrets

- **Secret Manager** for all runtime secrets. `roles/secretmanager.secretAccessor` granted to each consuming SA on the specific secret.
- **Never in env vars committed to CI/CD logs**; use `secret_manager_key_ref` in Cloud Run revision spec.
- **Rotation**: automated where the secret supports it; documented runbook where manual.

## Networking

- **Custom VPC** per environment — no `default` network in production.
- **Cloud NAT** for egress from Cloud Run to external services.
- **Serverless VPC Access connector** for Cloud Run → Cloud SQL private IP.
- **Cloud Armor** with OWASP Core Rule Set on all public load balancers.

## CI/CD

- **Cloud Build** or GitHub Actions + `google-github-actions/auth` via WIF.
- **Deploy stages**: lint → type-check → test → SAST (gitleaks, Trivy) → build image → push Artifact Registry → deploy Cloud Run.
- **Artifact Registry with vulnerability scanning on**; block deploys with critical CVEs.
- **No deploy without green pipeline.** Environment promotion: dev → staging → production, never skip.

## Observability

- Structured **JSON logs** on every service; `severity` + `trace` fields populated.
- **Cloud Logging → Cloud Monitoring** for metrics.
- **OpenTelemetry** traces exported to Cloud Trace.
- **SLOs** defined for latency p99 and error rate; alerts tied to burn rate.
- **Runbooks** for every paging alert in `docs/runbooks/`.

## What NOT To Do

- Don't use default VPC or default service accounts for production workloads.
- Don't download service account JSON keys for CI — always WIF.
- Don't share databases across services. Each service owns its data.
- Don't grant `roles/editor` or `roles/owner` at project level to any SA.
- Don't store secrets in env vars committed to git.
- Don't skip staging. Every change goes through staging before production.
