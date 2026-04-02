#!/usr/bin/env bash
# =============================================================================
# dependency-check.sh — PostToolUse hook for Edit/Write on package files
# Flags known insecure dependency patterns when package manifests are modified.
# Uses npm audit / pip-audit if available, otherwise checks for risky patterns.
# =============================================================================
set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# Only run on Edit/Write
[[ "$TOOL_NAME" =~ ^(Edit|Write)$ ]] || exit 0
[ -z "$FILE_PATH" ] && exit 0

FILENAME=$(basename "$FILE_PATH")
WARNINGS=""

# --- package.json ---
if [ "$FILENAME" = "package.json" ] && [ -f "$FILE_PATH" ]; then
  # Check for wildcard versions
  if grep -P '"[*]"' "$FILE_PATH" 2>/dev/null | grep -q .; then
    WARNINGS="${WARNINGS}\n  [WILDCARD_VERSION] Wildcard (*) version in package.json. Pin to specific versions."
  fi

  # Check for git dependencies (supply chain risk)
  if grep -Pi '"(git\+|github:|git://)' "$FILE_PATH" 2>/dev/null | grep -q .; then
    WARNINGS="${WARNINGS}\n  [GIT_DEPENDENCY] Git URL dependency detected. Prefer published packages with pinned versions."
  fi

  # Check for http (non-https) dependencies
  if grep -Pi '"http://' "$FILE_PATH" 2>/dev/null | grep -q .; then
    WARNINGS="${WARNINGS}\n  [HTTP_DEPENDENCY] HTTP (non-HTTPS) dependency URL. Use HTTPS only."
  fi

  # Run npm audit if available and node_modules exists
  if command -v npm &>/dev/null && [ -d "$(dirname "$FILE_PATH")/node_modules" ]; then
    AUDIT_OUTPUT=$(cd "$(dirname "$FILE_PATH")" && npm audit --json 2>/dev/null || true)
    VULN_COUNT=$(echo "$AUDIT_OUTPUT" | jq -r '.metadata.vulnerabilities.high // 0' 2>/dev/null || echo "0")
    CRIT_COUNT=$(echo "$AUDIT_OUTPUT" | jq -r '.metadata.vulnerabilities.critical // 0' 2>/dev/null || echo "0")
    TOTAL=$((VULN_COUNT + CRIT_COUNT))
    if [ "$TOTAL" -gt 0 ]; then
      WARNINGS="${WARNINGS}\n  [NPM_AUDIT] ${VULN_COUNT} high + ${CRIT_COUNT} critical vulnerabilities. Run 'npm audit' for details."
    fi
  fi
fi

# --- requirements.txt / pyproject.toml ---
if [[ "$FILENAME" =~ ^(requirements.*\.txt|pyproject\.toml|setup\.py|setup\.cfg)$ ]] && [ -f "$FILE_PATH" ]; then
  # Check for unpinned dependencies
  if [ "$FILENAME" = "requirements.txt" ] || [[ "$FILENAME" =~ ^requirements.*\.txt$ ]]; then
    if grep -P '^[a-zA-Z][a-zA-Z0-9_-]*\s*$' "$FILE_PATH" 2>/dev/null | head -3 | grep -q .; then
      WARNINGS="${WARNINGS}\n  [UNPINNED] Unpinned dependencies in $FILENAME. Pin versions (package==x.y.z)."
    fi
  fi

  # Check for git/URL dependencies
  if grep -Pi '^(git\+|https?://|-e\s+git)' "$FILE_PATH" 2>/dev/null | grep -q .; then
    WARNINGS="${WARNINGS}\n  [GIT_DEPENDENCY] Git/URL dependency in $FILENAME. Prefer published packages."
  fi

  # Run pip-audit if available
  if command -v pip-audit &>/dev/null && [ "$FILENAME" = "requirements.txt" ]; then
    AUDIT_OUTPUT=$(pip-audit -r "$FILE_PATH" --format json 2>/dev/null || true)
    VULN_COUNT=$(echo "$AUDIT_OUTPUT" | jq -r 'length' 2>/dev/null || echo "0")
    if [ "$VULN_COUNT" -gt 0 ]; then
      WARNINGS="${WARNINGS}\n  [PIP_AUDIT] ${VULN_COUNT} known vulnerabilities found. Run 'pip-audit -r $FILENAME' for details."
    fi
  fi
fi

# --- Cargo.toml ---
if [ "$FILENAME" = "Cargo.toml" ] && [ -f "$FILE_PATH" ]; then
  # Check for git dependencies
  if grep -Pi 'git\s*=' "$FILE_PATH" 2>/dev/null | grep -q .; then
    WARNINGS="${WARNINGS}\n  [GIT_DEPENDENCY] Git dependency in Cargo.toml. Prefer crates.io with pinned versions."
  fi

  # Run cargo-audit if available
  if command -v cargo-audit &>/dev/null; then
    AUDIT_OUTPUT=$(cd "$(dirname "$FILE_PATH")" && cargo audit --json 2>/dev/null || true)
    VULN_COUNT=$(echo "$AUDIT_OUTPUT" | jq -r '.vulnerabilities.found // 0' 2>/dev/null || echo "0")
    if [ "$VULN_COUNT" -gt 0 ]; then
      WARNINGS="${WARNINGS}\n  [CARGO_AUDIT] ${VULN_COUNT} known vulnerabilities. Run 'cargo audit' for details."
    fi
  fi
fi

if [ -n "$WARNINGS" ]; then
  echo "Dependency security warnings for $FILE_PATH:${WARNINGS}"
fi

exit 0
