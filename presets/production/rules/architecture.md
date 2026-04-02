---
description: Architecture rules for Production preset — multi-service, IaC, cloud-native, security-hardened
globs: ["**/*"]
---

# Production Architecture Rules

## Core Principle
Build for reliability, scalability, and auditability. Every infrastructure decision must be codified, reviewable, and reproducible.

## Structure
- **Domain-driven boundaries.** Each bounded context is a deployable unit (service or module). Clear API contracts between domains.
- **Vertical slices per domain.** Within each service: handler → service → repository → entity. No cross-domain database queries.
- **API Gateway pattern.** Single entry point for external traffic. Internal services communicate via well-defined APIs (REST or gRPC).
- **Event-driven where appropriate.** Use message queues (SQS, Pub/Sub, RabbitMQ) for async operations. Don't force sync calls where eventual consistency is acceptable.

## Infrastructure
- **Infrastructure as Code (mandatory).** All infra in `terraform/` or equivalent. No manual console changes. Terraform state in remote backend (S3+DynamoDB or GCS).
- **Docker for all services.** Multi-stage builds, non-root users, distroless/alpine base images. `docker-compose.yml` for local dev parity.
- **CI/CD pipeline.** GitHub Actions or equivalent. Stages: lint → type-check → test → SAST → build → deploy. No deploy without green pipeline.
- **Environment parity.** Dev, staging, and production use the same infra definitions with different variable files. No environment-specific code paths.

## Cloud Resources (AWS/GCP)
- **Compute**: ECS Fargate, Cloud Run, or EKS. No long-running EC2 unless required.
- **Database**: RDS/Cloud SQL (Postgres) with automated backups, point-in-time recovery. Read replicas for read-heavy workloads.
- **Auth**: Cognito, Auth0, or Keycloak. Custom auth only when managed solutions can't meet requirements.
- **Secrets**: AWS Secrets Manager / GCP Secret Manager. Never environment variables in CI/CD logs.
- **CDN**: CloudFront / Cloud CDN for static assets and API caching.
- **Monitoring**: CloudWatch/Cloud Monitoring + Grafana. Structured logging (JSON). Alerts on error rates, latency p99, resource utilization.

## Security
- **Network isolation.** VPC with private subnets for services, public subnets only for load balancers.
- **Least privilege IAM.** Each service has its own IAM role with minimal permissions. No shared credentials.
- **Encryption everywhere.** TLS in transit, AES-256 at rest. No exceptions.
- **Dependency scanning in CI.** Snyk, Trivy, or Grype on every build. Block deploys with critical CVEs.
- **WAF on public endpoints.** AWS WAF or Cloud Armor with OWASP Core Rule Set.

## What NOT To Do
- Don't deploy without IaC. If it's not in Terraform, it doesn't exist.
- Don't share databases between services. Each service owns its data.
- Don't use shared IAM roles or wildcard permissions.
- Don't skip staging. Every change goes through staging before production.
- Don't store secrets in code, env files committed to git, or CI/CD variables without encryption.

## Observability
- Structured JSON logging on all services.
- Distributed tracing (OpenTelemetry) across service boundaries.
- Health check endpoints (`/health`, `/ready`) on every service.
- Runbooks for critical alerts in `docs/runbooks/`.
