#!/usr/bin/env bash
# =============================================================================
# secret-scan.sh — PreToolUse hook for Bash(git commit)
# Scans staged files for hardcoded secrets before allowing a commit.
# Uses gitleaks if available, otherwise falls back to regex patterns.
# Exit code 0 = allow, Exit code 2 = block
# =============================================================================
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only run on git commit commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit'; then
  echo '{"decision":"allow"}'
  exit 0
fi

# Collect staged files (skip deleted)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=d 2>/dev/null || true)

if [ -z "$STAGED_FILES" ]; then
  echo '{"decision":"allow"}'
  exit 0
fi

# --- Try gitleaks first ---
if command -v gitleaks &>/dev/null; then
  GITLEAKS_OUTPUT=$(gitleaks protect --staged --no-banner 2>&1 || true)
  if echo "$GITLEAKS_OUTPUT" | grep -qiE '(leak|secret|finding)'; then
    echo "{\"decision\":\"block\",\"reason\":\"gitleaks detected secrets in staged files:\\n${GITLEAKS_OUTPUT}\"}"
    exit 2
  fi
  echo '{"decision":"allow"}'
  exit 0
fi

# --- Regex fallback ---
# Patterns that indicate hardcoded secrets
SECRET_PATTERNS=(
  # API keys and tokens (generic)
  '(?i)(api[_-]?key|api[_-]?secret|access[_-]?key)\s*[:=]\s*["\x27][A-Za-z0-9/+=]{16,}'
  # AWS
  '(?:AKIA|ABIA|ACCA|ASIA)[0-9A-Z]{16}'
  'aws[_-]?secret[_-]?access[_-]?key\s*[:=]\s*["\x27][A-Za-z0-9/+=]{40}'
  # Private keys
  '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----'
  # Generic high-entropy secrets assigned to suspicious variable names
  '(?i)(password|passwd|secret|token|private[_-]?key)\s*[:=]\s*["\x27][^\s"'\'']{8,}'
  # GitHub tokens
  '(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}'
  # Slack tokens
  'xox[bpors]-[0-9]{10,}-[A-Za-z0-9-]+'
  # JWT (hardcoded)
  'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]+'
  # Connection strings with credentials
  '(?i)(mysql|postgres|postgresql|mongodb|redis|amqp)://[^\s:]+:[^\s@]+@'
)

FOUND_SECRETS=""

for file in $STAGED_FILES; do
  # Skip binary files and common false-positive paths
  [[ "$file" =~ \.(png|jpg|jpeg|gif|ico|woff|woff2|ttf|eot|pdf|zip|tar|gz)$ ]] && continue
  [[ "$file" =~ ^(vendor/|node_modules/|\.git/) ]] && continue
  [[ "$file" == *".lock"* ]] && continue
  [[ "$file" == *"lock.json"* ]] && continue

  # Get staged content (not working tree)
  CONTENT=$(git show ":$file" 2>/dev/null || true)
  [ -z "$CONTENT" ] && continue

  for pattern in "${SECRET_PATTERNS[@]}"; do
    MATCHES=$(echo "$CONTENT" | grep -nP "$pattern" 2>/dev/null | head -3 || true)
    if [ -n "$MATCHES" ]; then
      FOUND_SECRETS="${FOUND_SECRETS}\n  ${file}: pattern matched (possible secret)"
    fi
  done
done

if [ -n "$FOUND_SECRETS" ]; then
  echo "{\"decision\":\"block\",\"reason\":\"Potential secrets detected in staged files:${FOUND_SECRETS}\nReview these files and use environment variables instead. To skip, unstage the file or use a .gitleaksignore.\"}"
  exit 2
fi

echo '{"decision":"allow"}'
exit 0
