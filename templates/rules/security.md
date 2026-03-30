# Security

## Secrets

- NEVER hardcode secrets, tokens, API keys, or passwords in code
- NEVER read or expose .env files in responses
- Use environment variables or secret managers (e.g., GCP Secret Manager, AWS SSM)
- If you see a secret in code, flag it immediately — don't just fix silently

## Input Validation

- Validate ALL external input (API requests, URL params, form data)
- Use schema validation (zod, pydantic, joi) at the boundary
- Sanitize data before database queries — prefer ORM/parameterized queries
- Never build SQL/shell commands from string concatenation with user input

## Authentication & Authorization

- Always check auth before processing any request
- Verify permissions at the resource level, not just route level
- Never expose internal IDs or stack traces in API responses

## Dependencies

- Don't add dependencies without checking for known vulnerabilities
- Prefer well-maintained packages with active security updates
