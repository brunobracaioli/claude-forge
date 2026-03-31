#!/usr/bin/env bash
# =============================================================================
# teammate-idle.sh — TeammateIdle hook for Agent Teams
# Runs when a teammate is about to go idle.
# Exit code 0 = allow idle, Exit code 2 = send feedback and keep working
# [CUSTOMIZE] Adjust the conditions for keeping teammates active.
# =============================================================================
set -euo pipefail

INPUT=$(cat)
TEAMMATE_NAME=$(echo "$INPUT" | jq -r '.agent_name // "unknown"')

# --- Check if there are pending tasks ---
PENDING_TASKS=$(echo "$INPUT" | jq -r '.pending_tasks // 0')

if [ "$PENDING_TASKS" -gt 0 ] 2>/dev/null; then
  echo "{\"decision\":\"continue\",\"reason\":\"There are still $PENDING_TASKS pending tasks. Pick up the next one.\"}"
  exit 2
fi

# --- Allow idle ---
echo "{\"decision\":\"allow\"}"
exit 0
