---
name: infra-audit
description: >
  Audit infrastructure configuration for security and best practices. Reviews Terraform,
  Docker, CI/CD pipelines, and cloud config for misconfigurations, overly permissive
  permissions, and missing security controls.
  Trigger phrases: "infra audit", "terraform review", "docker audit", "infrastructure review",
  "forge infra-audit", "check infra", "audit infrastructure".
argument-hint: "[optional: specific path — terraform/, Dockerfile, .github/workflows/]"
allowed-tools: Read, Bash, Glob, Grep
---

# Infrastructure Security Audit

Review all infrastructure-as-code for security misconfigurations and best practices.

## Workflow

### Step 1: Discover IaC Files

```
Scan for:
- terraform/**/*.tf
- Dockerfile, docker-compose*.yml
- .github/workflows/*.yml, .gitlab-ci.yml, Jenkinsfile
- kubernetes/*.yaml, k8s/*.yaml, helm/**
- serverless.yml, vercel.json, netlify.toml
- ansible/**/*.yml, pulumi/**
```

If $ARGUMENTS is provided, audit only that path.

### Step 2: Terraform Audit

For each .tf file found:

**State & Backend**
- Remote backend configured (not local state)?
- State encryption enabled?
- State locking configured (DynamoDB/GCS)?

**IAM & Permissions**
- No wildcard (*) in IAM policy actions or resources
- No inline policies (use managed or customer policies)
- Each service has its own role (no shared roles)
- No `AdministratorAccess` or `PowerUser` attached

**Network**
- No security groups with 0.0.0.0/0 on non-HTTP ports
- Private subnets for databases and internal services
- VPC flow logs enabled
- No public IPs on internal services

**Data**
- Encryption at rest on all storage (S3, RDS, EBS, DynamoDB)
- Encryption in transit (TLS)
- No public S3 buckets unless explicitly intended
- Backup and point-in-time recovery enabled on databases
- Secrets in AWS Secrets Manager/SSM, not in variables

**Compute**
- ECR image scanning enabled
- ECS tasks with non-root users
- Container health checks defined
- CloudWatch/monitoring enabled

### Step 3: Docker Audit

For each Dockerfile:

- Multi-stage build (no dev deps in final image)?
- Non-root USER directive?
- Specific base image tags (no :latest)?
- No secrets in build args or COPY
- HEALTHCHECK defined?
- .dockerignore exists and excludes .env, .git, node_modules?

For docker-compose files:
- No hardcoded passwords (use env_file or secrets)
- Volumes don't mount sensitive host paths
- No privileged mode unless required
- Resource limits defined for production

### Step 4: CI/CD Pipeline Audit

For each workflow/pipeline:

- No secrets hardcoded in workflow files
- Secrets passed via GitHub Secrets / CI variables
- Actions/images pinned to specific versions (no @latest)
- GITHUB_TOKEN has minimal permissions (not write-all)
- No artifact uploads containing secrets
- Deployment requires approval for production
- OIDC preferred over long-lived access keys

### Step 5: Report

```
## Infrastructure Audit Report
Date: <timestamp>
Scope: <path or "all IaC">

### IaC Files Found
- Terraform: X files
- Docker: X files
- CI/CD: X workflows
- Other: ...

### Critical
- [CATEGORY] <finding> — file:line
  Risk: <what could happen>
  Fix: <specific remediation>

### High
...

### Medium
...

### Best Practice Recommendations
- <actionable suggestion>
```
