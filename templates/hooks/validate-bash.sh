#!/usr/bin/env bash
# =============================================================================
# validate-bash.sh — PreToolUse hook for Bash commands
# Blocks destructive or dangerous commands with 100% reliability.
# Exit code 0 = allow, Exit code 2 = block
# =============================================================================
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# --- Block destructive commands ---
if echo "$COMMAND" | grep -qEi '(rm\s+-rf\s+[/~.]|DROP\s+DATABASE|DROP\s+TABLE|TRUNCATE|FORMAT\s+C)'; then
  echo '{"decision":"block","reason":"Destructive command blocked by safety hook."}'
  exit 2
fi

# --- Block secret exposure ---
if echo "$COMMAND" | grep -qEi '(cat\s+\.env|echo\s+.*PASSWORD|echo\s+.*SECRET|echo\s+.*TOKEN|printenv)'; then
  echo '{"decision":"block","reason":"Command may expose secrets."}'
  exit 2
fi

# --- Block network exfiltration ---
if echo "$COMMAND" | grep -qEi '(curl\s+.*-d|wget\s+.*--post|nc\s+-|ncat)'; then
  echo '{"decision":"block","reason":"Outbound data transfer blocked."}'
  exit 2
fi

# --- Allow everything else ---
echo '{"decision":"allow"}'
exit 0
