#!/usr/bin/env bash
# =============================================================================
# gen_manifest.sh — generate manifest.json with sha256 per shipped file
#
# Consumed by scripts/bootstrap.sh in --update mode. Files whose local hash
# matches the shipped hash are refreshed in-place; everything else is
# preserved and the new content is written as <file>.new.
#
# Usage: gen_manifest.sh [output_path]
#   output_path defaults to <repo_root>/manifest.json
#
# Invariants:
# - Run from the repo root (any CWD — paths are relative to the script).
# - Hashes are recorded as "sha256:<hex>".
# - Only files under templates/, stacks/, presets/ are shipped and hashed.
# - The resulting JSON validates (parseable by jq).
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT="${1:-$REPO_ROOT/manifest.json}"

# Source of truth for version
VERSION="unknown"
[ -f "$REPO_ROOT/VERSION" ] && VERSION=$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")

hasher() {
  if command -v sha256sum &>/dev/null; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum &>/dev/null; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "[gen_manifest] ERROR: no sha256sum or shasum available" >&2
    exit 1
  fi
}

command -v jq >/dev/null 2>&1 || { echo "[gen_manifest] ERROR: jq is required" >&2; exit 1; }

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

printf '{}' > "$TMP"
# Build file list: everything under templates/, stacks/, presets/
# Exclude the manifest itself and any .new sidecar files from a prior run.
while IFS= read -r -d '' file; do
  rel="${file#$REPO_ROOT/}"
  [ "$rel" = "manifest.json" ] && continue
  [[ "$rel" == *.new ]] && continue
  hash=$(hasher "$file")
  jq --arg k "$rel" --arg v "sha256:$hash" '. + {($k): $v}' "$TMP" > "$TMP.next"
  mv "$TMP.next" "$TMP"
done < <(find "$REPO_ROOT/templates" "$REPO_ROOT/stacks" "$REPO_ROOT/presets" -type f -print0 2>/dev/null | sort -z)

# Compose final document
jq -n \
  --arg version "$VERSION" \
  --arg generated "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --slurpfile files "$TMP" \
  '{"$schema": "https://json-schema.org/draft/2020-12/schema",
    description: "sha256 per shipped file — consumed by scripts/bootstrap.sh --update",
    version: $version,
    generated_at: $generated,
    files: $files[0]}' > "$OUTPUT"

count=$(jq -r '.files | length' "$OUTPUT")
echo "[gen_manifest] wrote $OUTPUT ($count files, v$VERSION)"
