---
name: security-audit
description: >
  Run a comprehensive OWASP-based security audit on the codebase. Checks for injection,
  broken auth, sensitive data exposure, misconfigurations, and known vulnerable dependencies.
  Trigger phrases: "security audit", "owasp check", "security review", "vuln scan",
  "forge security-audit", "check security".
argument-hint: "[optional: specific path or module to audit]"
allowed-tools: Read, Bash, Glob, Grep
---

# Security Audit (OWASP Top 10)

Perform a structured security review of the codebase following OWASP Top 10 categories.

## Workflow

### Step 1: Scope

- If $ARGUMENTS is provided, audit only that path/module
- Otherwise, audit the entire project from the root
- Identify the stack (check package.json, requirements.txt, Cargo.toml, go.mod)

### Step 2: Automated Scans

Run available tools first (skip any that aren't installed):

```bash
# Secret scanning
gitleaks detect --source . --no-banner 2>/dev/null || echo "gitleaks not installed"

# Dependency vulnerabilities
npm audit --json 2>/dev/null || true
pip-audit 2>/dev/null || true
cargo audit 2>/dev/null || true

# SAST (if available)
semgrep --config=auto . 2>/dev/null || echo "semgrep not installed"
bandit -r . 2>/dev/null || echo "bandit not installed"
```

### Step 3: Manual Code Review (OWASP Top 10)

For each category, search the codebase for relevant patterns:

**A01 — Broken Access Control**
- Search for routes/endpoints missing auth middleware
- Check for direct object references without authorization
- Look for CORS misconfigurations
- Verify role-based access control on sensitive operations

**A02 — Cryptographic Failures**
- Check for hardcoded secrets, keys, tokens
- Look for weak algorithms (MD5, SHA1, DES, RC4)
- Verify TLS configuration (no disabled verification)
- Check password storage (must be bcrypt/argon2/scrypt, never plain SHA/MD5)

**A03 — Injection**
- SQL: string concatenation/f-strings in queries
- Command: unsanitized input in os.system/exec/subprocess
- XSS: unescaped user input in HTML templates
- NoSQL: unvalidated input in MongoDB queries

**A04 — Insecure Design**
- Missing rate limiting on auth endpoints
- No account lockout after failed attempts
- Missing CSRF protection on state-changing operations
- Absence of input validation schemas

**A05 — Security Misconfiguration**
- Debug mode enabled in config files
- Default credentials in config/env files
- Overly permissive CORS (wildcard origins)
- Missing security headers (CSP, HSTS, X-Frame-Options)
- Verbose error messages exposing internals

**A06 — Vulnerable Components**
- Check dependency audit results from Step 2
- Look for pinned outdated versions with known CVEs
- Check for abandoned/unmaintained dependencies

**A07 — Authentication Failures**
- Weak password requirements
- Missing MFA support on sensitive operations
- Session tokens in URLs
- Missing session expiration/rotation

**A08 — Data Integrity Failures**
- Unsigned/unverified data in deserialization
- Missing integrity checks on file uploads
- CI/CD pipeline without signed artifacts

**A09 — Logging & Monitoring Failures**
- Missing logging on auth events (login, logout, failed attempts)
- Missing logging on sensitive operations (payments, data mutations)
- Sensitive data in logs (passwords, tokens, PII)
- No structured log format

**A10 — Server-Side Request Forgery**
- User-controlled URLs passed to HTTP clients without validation
- Internal service URLs constructed from user input
- Missing URL allowlist/denylist for outbound requests

### Step 4: Report

Generate a structured report:

```
## Security Audit Report
Date: <timestamp>
Scope: <path or "full project">
Stack: <detected stack>

### Critical (fix immediately)
- [A0X] <finding> — file:line
  Recommendation: <specific fix>

### High (fix before next release)
- [A0X] <finding> — file:line
  Recommendation: <specific fix>

### Medium (fix soon)
...

### Low / Informational
...

### Tools Available / Not Installed
- gitleaks: ✓/✗
- semgrep: ✓/✗
- npm audit / pip-audit / cargo audit: ✓/✗

### Recommendation
Install missing tools: <commands>
```

Order findings by severity (Critical > High > Medium > Low).
For each finding, provide the specific file, line, and a concrete fix — not generic advice.
