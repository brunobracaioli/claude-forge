#!/usr/bin/env bash
# =============================================================================
# smoke_test.sh — plain-bash smoke coverage for scripts/bootstrap.sh
# Runs the most important assertions without requiring bats. CI runs the
# full bats suite (tests/bootstrap_test.bats) on top of this.
# =============================================================================
set -eu
# Note: no pipefail — bootstrap.sh writes a lot; `| grep -q` causes SIGPIPE
# which is benign here but would trip pipefail and abort the suite.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOOTSTRAP="$REPO_ROOT/scripts/bootstrap.sh"
FIXTURES="$REPO_ROOT/tests/fixtures"
PASS=0
FAIL=0

report() {
  if [ "$1" = "PASS" ]; then
    printf '  \033[32m✓\033[0m %s\n' "$2"
    PASS=$((PASS + 1))
  else
    printf '  \033[31m✗\033[0m %s\n' "$2"
    FAIL=$((FAIL + 1))
  fi
}

run_case() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    report PASS "$name"
  else
    report FAIL "$name"
  fi
}

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

echo "--- auto-detect ---"
declare -A FIXMAP=(
  [react]=next-app
  [flask-next]=flask-next-app
  [node]=node-app
  [python]=python-app
  [rust]=rust-app
  [django]=django-app
  [go]=go-app
  [laravel]=laravel-app
)
for stack in react flask-next node python rust django go laravel; do
  dir="$workdir/detect-$stack"
  mkdir -p "$dir"
  cp -r "$FIXTURES/${FIXMAP[$stack]}/." "$dir/"
  out=$(bash "$BOOTSTRAP" "$dir" auto none 2>&1 || true)
  if echo "$out" | grep -q "Auto-detected stack: $stack"; then
    report PASS "detect: $stack"
  else
    report FAIL "detect: $stack"
  fi
done

echo "--- tier gating ---"
dir="$workdir/tier-core"; mkdir -p "$dir"
bash "$BOOTSTRAP" "$dir" react none >/dev/null 2>&1
count=$(find "$dir/.claude/agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')
[ "$count" = "5" ] && report PASS "core tier installs 5 agents" || report FAIL "core tier installs 5 agents (got $count)"

dir="$workdir/tier-full"; mkdir -p "$dir"
bash "$BOOTSTRAP" "$dir" react none --tier full >/dev/null 2>&1
count=$(find "$dir/.claude/agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')
[ "$count" = "15" ] && report PASS "full tier installs 15 agents" || report FAIL "full tier installs 15 agents (got $count)"

echo "--- update mode ---"
if [ -f "$REPO_ROOT/manifest.json" ]; then
  dir="$workdir/update-clean"; mkdir -p "$dir"
  bash "$BOOTSTRAP" "$dir" react mvp >/dev/null 2>&1 || true
  out=$(bash "$BOOTSTRAP" "$dir" react mvp --update 2>&1 || true)
  if echo "$out" | grep -q "Updated (unmodified)"; then
    report PASS "update refreshes unmodified files"
  else
    report FAIL "update refreshes unmodified files"
  fi

  dir="$workdir/update-modified"; mkdir -p "$dir"
  bash "$BOOTSTRAP" "$dir" react mvp >/dev/null 2>&1
  echo "LOCAL HACK" >> "$dir/.claude/rules/security.md"
  bash "$BOOTSTRAP" "$dir" react mvp --update >/dev/null 2>&1
  if [ -f "$dir/.claude/rules/security.md.new" ] && grep -q "LOCAL HACK" "$dir/.claude/rules/security.md"; then
    report PASS "update preserves modified file + writes .new sidecar"
  else
    report FAIL "update preserves modified file + writes .new sidecar"
  fi
else
  report FAIL "manifest.json missing — run scripts/gen_manifest.sh first"
fi

echo "--- settings integrity ---"
dir="$workdir/settings"; mkdir -p "$dir"
bash "$BOOTSTRAP" "$dir" react mvp >/dev/null 2>&1
run_case "settings.json is valid JSON" jq empty "$dir/.claude/settings.json"

echo "--- CLAUDE.md line budget ---"
lines=$(wc -l < "$dir/CLAUDE.md")
[ "$lines" -lt 200 ] && report PASS "CLAUDE.md under 200 lines ($lines)" || report FAIL "CLAUDE.md too long: $lines"

echo "--- hooks executable ---"
all_ok=1
for h in validate-bash secret-scan sast-scan dependency-check auto-format; do
  [ -x "$dir/.claude/hooks/${h}.sh" ] || { all_ok=0; break; }
done
[ "$all_ok" = "1" ] && report PASS "all hooks executable" || report FAIL "some hooks missing +x"

echo ""
echo "============================================="
echo "  $PASS passed, $FAIL failed"
echo "============================================="
[ "$FAIL" -eq 0 ]
