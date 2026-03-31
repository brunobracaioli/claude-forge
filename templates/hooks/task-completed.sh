#!/usr/bin/env bash
# =============================================================================
# task-completed.sh — TaskCompleted hook for Agent Teams
# Runs when a teammate marks a task as complete.
# Exit code 0 = allow completion, Exit code 2 = block (require quality gate)
# [CUSTOMIZE] Add quality gates before tasks can be marked complete.
# =============================================================================
set -euo pipefail

INPUT=$(cat)
TASK_NAME=$(echo "$INPUT" | jq -r '.task_name // "unknown"')

# [CUSTOMIZE] Uncomment to require tests to pass before completing tasks:

# --- Block completion if tests fail ---
# if ! npm test --silent 2>/dev/null; then
#   echo '{"decision":"block","reason":"Tests must pass before marking task complete."}'
#   exit 2
# fi

# --- Block completion if linter fails ---
# if ! npm run lint --silent 2>/dev/null; then
#   echo '{"decision":"block","reason":"Linter must pass before marking task complete."}'
#   exit 2
# fi

# --- Allow completion ---
echo '{"decision":"allow"}'
exit 0
