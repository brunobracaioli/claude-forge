#!/usr/bin/env bash
# =============================================================================
# auto-format.sh — PostToolUse hook for Write/Edit tools
# Runs the project formatter on modified files automatically.
# [CUSTOMIZE] Adjust the formatter command for your stack.
# =============================================================================
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# Skip if no file path
[ -z "$FILE_PATH" ] && exit 0

# [CUSTOMIZE] Uncomment and adjust the formatter for your stack:

# --- JavaScript/TypeScript (Prettier) ---
# if [[ "$FILE_PATH" =~ \.(ts|tsx|js|jsx|json|css|md)$ ]]; then
#   npx prettier --write "$FILE_PATH" 2>/dev/null || true
# fi

# --- Python (Black + isort) ---
# if [[ "$FILE_PATH" =~ \.py$ ]]; then
#   black "$FILE_PATH" 2>/dev/null || true
#   isort "$FILE_PATH" 2>/dev/null || true
# fi

# --- Rust ---
# if [[ "$FILE_PATH" =~ \.rs$ ]]; then
#   rustfmt "$FILE_PATH" 2>/dev/null || true
# fi

# --- Go ---
# if [[ "$FILE_PATH" =~ \.go$ ]]; then
#   gofmt -w "$FILE_PATH" 2>/dev/null || true
# fi

exit 0
