#!/usr/bin/env bash
# =============================================================================
# sast-scan.sh — PostToolUse hook for Edit/Write tools
# Lightweight static analysis: flags common security anti-patterns in code.
# Returns warnings (does not block) so the agent can self-correct.
# =============================================================================
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# Only run on Edit/Write
[[ "$TOOL_NAME" =~ ^(Edit|Write)$ ]] || exit 0
[ -z "$FILE_PATH" ] && exit 0
[ -f "$FILE_PATH" ] || exit 0

# Skip non-code files
[[ "$FILE_PATH" =~ \.(md|txt|json|yaml|yml|toml|cfg|ini|lock|svg|html|css)$ ]] && exit 0
[[ "$FILE_PATH" =~ \.(png|jpg|jpeg|gif|ico|woff|pdf|zip)$ ]] && exit 0

WARNINGS=""

# --- SQL Injection ---
if grep -nPi '(query|execute|raw|sql)\s*\(.*["\x27]\s*\+|f["\x27].*SELECT|f["\x27].*INSERT|f["\x27].*UPDATE|f["\x27].*DELETE|\.format\(.*SELECT' "$FILE_PATH" 2>/dev/null | head -3 | grep -q .; then
  WARNINGS="${WARNINGS}\n  [SQL_INJECTION] String concatenation/f-string in SQL query. Use parameterized queries."
fi

# --- Command Injection ---
if grep -nPi '(os\.system|subprocess\.(call|run|Popen))\s*\(.*["\x27]\s*\+|exec\s*\(.*\+|child_process\.exec\s*\(.*\+|eval\s*\(.*\+' "$FILE_PATH" 2>/dev/null | head -3 | grep -q .; then
  WARNINGS="${WARNINGS}\n  [CMD_INJECTION] String concatenation in command execution. Use parameterized commands."
fi

# --- Dangerous eval/exec ---
if grep -nPi '^\s*(eval|exec)\s*\(' "$FILE_PATH" 2>/dev/null | grep -v '#.*eval\|//.*eval\|/\*.*eval' | head -3 | grep -q .; then
  WARNINGS="${WARNINGS}\n  [EVAL] eval()/exec() usage detected. Avoid unless absolutely necessary."
fi

# --- Hardcoded IPs (non-localhost) ---
if grep -nP '\b(?!127\.0\.0\.1|0\.0\.0\.0|localhost)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b' "$FILE_PATH" 2>/dev/null | grep -v '#\|//\|/\*' | head -3 | grep -q .; then
  WARNINGS="${WARNINGS}\n  [HARDCODED_IP] Hardcoded IP address found. Use configuration/env vars."
fi

# --- Disabled TLS verification ---
if grep -nPi 'verify\s*=\s*False|NODE_TLS_REJECT_UNAUTHORIZED\s*=\s*["\x27]0|rejectUnauthorized\s*:\s*false|InsecureSkipVerify\s*:\s*true' "$FILE_PATH" 2>/dev/null | head -3 | grep -q .; then
  WARNINGS="${WARNINGS}\n  [TLS_DISABLED] TLS/SSL verification disabled. This allows MITM attacks."
fi

# --- Cors wildcard ---
if grep -nPi 'cors\(.*\*|Access-Control-Allow-Origin.*\*|allow_origins.*\[.*\*.*\]' "$FILE_PATH" 2>/dev/null | head -3 | grep -q .; then
  WARNINGS="${WARNINGS}\n  [CORS_WILDCARD] CORS wildcard (*) detected. Restrict to specific origins."
fi

# --- Debug mode in production-like files ---
if grep -nPi '^\s*DEBUG\s*=\s*True|app\.run\(.*debug\s*=\s*True|EnableDebugging' "$FILE_PATH" 2>/dev/null | head -3 | grep -q .; then
  WARNINGS="${WARNINGS}\n  [DEBUG_ON] Debug mode enabled. Ensure this is disabled in production."
fi

# --- Weak crypto ---
if grep -nPi '\b(md5|sha1)\s*\(|hashlib\.(md5|sha1)|createHash\s*\(\s*["\x27](md5|sha1)|DES\b|RC4\b' "$FILE_PATH" 2>/dev/null | grep -v '#\|//\|/\*' | head -3 | grep -q .; then
  WARNINGS="${WARNINGS}\n  [WEAK_CRYPTO] Weak hash/cipher (MD5/SHA1/DES/RC4). Use SHA-256+ or bcrypt/argon2."
fi

if [ -n "$WARNINGS" ]; then
  echo "SAST warnings for $FILE_PATH:${WARNINGS}"
fi

exit 0
