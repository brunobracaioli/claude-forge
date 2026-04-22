#!/usr/bin/env bats
# =============================================================================
# bootstrap_test.bats — unit tests for scripts/bootstrap.sh and install.sh
# Run: bats tests/bootstrap_test.bats
# =============================================================================

REPO_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
BOOTSTRAP="$REPO_ROOT/scripts/bootstrap.sh"
FIXTURES="$REPO_ROOT/tests/fixtures"

setup() {
  TEST_DIR="$(mktemp -d)"
}

teardown() {
  [ -n "${TEST_DIR:-}" ] && [ -d "$TEST_DIR" ] && rm -rf "$TEST_DIR"
}

# --- auto_detect_stack ----------------------------------------------------

@test "auto_detect_stack: react fixture → react" {
  run bash -c "source '$BOOTSTRAP' --help 2>/dev/null; auto_detect_stack '$FIXTURES/next-app'" || true
  # Can't easily source due to set -e / exits; invoke via dedicated run:
  cp -r "$FIXTURES/next-app/." "$TEST_DIR/"
  run bash "$BOOTSTRAP" "$TEST_DIR" auto none
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Auto-detected stack: react"
}

@test "auto_detect_stack: flask-next fixture → flask-next" {
  cp -r "$FIXTURES/flask-next-app/." "$TEST_DIR/"
  run bash "$BOOTSTRAP" "$TEST_DIR" auto none
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Auto-detected stack: flask-next"
}

@test "auto_detect_stack: node fixture → node" {
  cp -r "$FIXTURES/node-app/." "$TEST_DIR/"
  run bash "$BOOTSTRAP" "$TEST_DIR" auto none
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Auto-detected stack: node"
}

@test "auto_detect_stack: python fixture → python" {
  cp -r "$FIXTURES/python-app/." "$TEST_DIR/"
  run bash "$BOOTSTRAP" "$TEST_DIR" auto none
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Auto-detected stack: python"
}

@test "auto_detect_stack: rust fixture → rust" {
  cp -r "$FIXTURES/rust-app/." "$TEST_DIR/"
  run bash "$BOOTSTRAP" "$TEST_DIR" auto none
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Auto-detected stack: rust"
}

@test "auto_detect_stack: generic fixture → generic" {
  cp -r "$FIXTURES/generic-app/." "$TEST_DIR/"
  run bash "$BOOTSTRAP" "$TEST_DIR" auto none
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Auto-detected stack: generic"
}

# --- safe_copy & --update -------------------------------------------------

@test "safe_copy: fresh install creates files" {
  run bash "$BOOTSTRAP" "$TEST_DIR" react none
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/.claude/settings.json" ]
  [ -f "$TEST_DIR/.claude/rules/security.md" ]
}

@test "safe_copy: re-run without --update skips existing files" {
  bash "$BOOTSTRAP" "$TEST_DIR" react none >/dev/null
  run bash "$BOOTSTRAP" "$TEST_DIR" react none
  [ "$status" -eq 0 ]
  # At least one SKIP expected — the rules/ files from the first run are still there
  [[ "$output" == *"SKIP (exists)"* ]]
}

@test "--update: unmodified files refreshed in-place" {
  [ -f "$REPO_ROOT/manifest.json" ] || skip "manifest.json absent — run scripts/gen_manifest.sh"
  bash "$BOOTSTRAP" "$TEST_DIR" react none >/dev/null
  run bash "$BOOTSTRAP" "$TEST_DIR" react none --update
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Updated (unmodified)"
}

@test "--update: locally modified files preserved, sidecar .new created" {
  [ -f "$REPO_ROOT/manifest.json" ] || skip "manifest.json absent"
  bash "$BOOTSTRAP" "$TEST_DIR" react none >/dev/null
  echo "LOCAL HACK" >> "$TEST_DIR/.claude/rules/security.md"
  run bash "$BOOTSTRAP" "$TEST_DIR" react none --update
  [ "$status" -eq 0 ]
  [ -f "$TEST_DIR/.claude/rules/security.md.new" ]
  grep -q "LOCAL HACK" "$TEST_DIR/.claude/rules/security.md"
}

# --- Agent tier gating ----------------------------------------------------

@test "--tier core (default): installs 5 agents" {
  bash "$BOOTSTRAP" "$TEST_DIR" react none >/dev/null
  count=$(find "$TEST_DIR/.claude/agents" -maxdepth 1 -name '*.md' | wc -l)
  [ "$count" -eq 5 ]
  [ -f "$TEST_DIR/.claude/agents/code-reviewer.md" ]
  [ -f "$TEST_DIR/.claude/agents/orchestrator.md" ]
}

@test "--tier full: installs all 15 agents" {
  bash "$BOOTSTRAP" "$TEST_DIR" react none --tier full >/dev/null
  count=$(find "$TEST_DIR/.claude/agents" -maxdepth 1 -name '*.md' | wc -l)
  [ "$count" -eq 15 ]
  [ -f "$TEST_DIR/.claude/agents/ux-designer.md" ]
}

@test "--tier does not copy TIERS.json into project" {
  bash "$BOOTSTRAP" "$TEST_DIR" react none --tier full >/dev/null
  [ ! -f "$TEST_DIR/.claude/agents/TIERS.json" ]
}

@test "--tier invalid value falls back to core" {
  run bash "$BOOTSTRAP" "$TEST_DIR" react none --tier bogus
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "Invalid --tier"
  count=$(find "$TEST_DIR/.claude/agents" -maxdepth 1 -name '*.md' | wc -l)
  [ "$count" -eq 5 ]
}

# --- Flag parsing ---------------------------------------------------------

@test "--preset flag form equivalent to positional" {
  bash "$BOOTSTRAP" "$TEST_DIR" react --preset mvp >/dev/null
  [ -f "$TEST_DIR/docker-compose.yml" ]
}

@test "positional preset still works" {
  bash "$BOOTSTRAP" "$TEST_DIR" react mvp >/dev/null
  [ -f "$TEST_DIR/docker-compose.yml" ]
}

# --- Settings jq merge ----------------------------------------------------

@test "settings.json is valid JSON after stack overlay" {
  bash "$BOOTSTRAP" "$TEST_DIR" react none >/dev/null
  run jq empty "$TEST_DIR/.claude/settings.json"
  [ "$status" -eq 0 ]
}

@test "settings.json is valid JSON after stack + preset overlay" {
  bash "$BOOTSTRAP" "$TEST_DIR" react mvp >/dev/null
  run jq empty "$TEST_DIR/.claude/settings.json"
  [ "$status" -eq 0 ]
}

@test "stack permissions are merged (react allow rules present)" {
  bash "$BOOTSTRAP" "$TEST_DIR" react none >/dev/null
  # React stack override should contribute at least one allow rule
  allow_count=$(jq -r '.permissions.allow | length' "$TEST_DIR/.claude/settings.json")
  [ "$allow_count" -gt 0 ]
}

# --- CLAUDE.md budget -----------------------------------------------------

@test "CLAUDE.md under 200 lines after bootstrap (react mvp)" {
  bash "$BOOTSTRAP" "$TEST_DIR" react mvp >/dev/null
  [ -f "$TEST_DIR/CLAUDE.md" ]
  lines=$(wc -l < "$TEST_DIR/CLAUDE.md")
  [ "$lines" -lt 200 ]
}

@test "CLAUDE.md under 200 lines after bootstrap (python production)" {
  bash "$BOOTSTRAP" "$TEST_DIR" python production >/dev/null
  [ -f "$TEST_DIR/CLAUDE.md" ]
  lines=$(wc -l < "$TEST_DIR/CLAUDE.md")
  [ "$lines" -lt 200 ]
}

# --- Hooks ---------------------------------------------------------------

@test "hooks are copied and executable" {
  bash "$BOOTSTRAP" "$TEST_DIR" react none >/dev/null
  for h in validate-bash secret-scan sast-scan dependency-check auto-format; do
    [ -x "$TEST_DIR/.claude/hooks/${h}.sh" ] || {
      echo "hook not executable: ${h}.sh"
      return 1
    }
  done
}
