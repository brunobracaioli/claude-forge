#!/usr/bin/env bash
# =============================================================================
# project-bootstrap: Scaffold .claude/ directory structure
# Usage: bootstrap.sh <project_root> [stack]
# Stacks: flask-next | node | python | react | rust | generic
# =============================================================================
set -euo pipefail

PROJECT_ROOT="${1:-.}"
STACK="${2:-generic}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$SKILL_DIR/templates"
STACK_DIR="$SKILL_DIR/stacks/$STACK"

# --- Colors ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}[bootstrap]${NC} $1"; }
warn() { echo -e "${YELLOW}[bootstrap]${NC} $1"; }
info() { echo -e "${CYAN}[bootstrap]${NC} $1"; }
bold() { echo -e "${BOLD}$1${NC}"; }

# --- Auto-detect stack if generic ---
auto_detect_stack() {
  local root="$1"
  if [ -f "$root/next.config.js" ] || [ -f "$root/next.config.ts" ] || [ -f "$root/next.config.mjs" ]; then
    if [ -f "$root/requirements.txt" ] || [ -f "$root/pyproject.toml" ] || [ -d "$root/backend" ]; then
      echo "flask-next"
    else
      echo "react"
    fi
  elif [ -f "$root/package.json" ]; then
    echo "node"
  elif [ -f "$root/Cargo.toml" ]; then
    echo "rust"
  elif [ -f "$root/requirements.txt" ] || [ -f "$root/pyproject.toml" ] || [ -f "$root/setup.py" ]; then
    echo "python"
  else
    echo "generic"
  fi
}

# Auto-detect if user didn't specify
if [ "$STACK" = "auto" ] || [ "$STACK" = "detect" ]; then
  STACK=$(auto_detect_stack "$PROJECT_ROOT")
  info "Auto-detected stack: $STACK"
fi

# Validate stack
VALID_STACKS="flask-next node python react rust generic"
if ! echo "$VALID_STACKS" | grep -qw "$STACK"; then
  warn "Unknown stack '$STACK'. Using 'generic'."
  STACK="generic"
fi

STACK_DIR="$SKILL_DIR/stacks/$STACK"

# --- Safe copy: never overwrite ---
safe_copy() {
  local src="$1" dst="$2"
  if [ -f "$dst" ]; then
    warn "SKIP (exists): $dst"
    return 1
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    log "Created: $dst"
    return 0
  fi
}

# --- Copy directory contents ---
copy_dir() {
  local src_dir="$1" dst_dir="$2" ext="${3:-*}"
  [ -d "$src_dir" ] || return 0
  for file in "$src_dir"/$ext; do
    [ -f "$file" ] || continue
    local filename
    filename=$(basename "$file")
    safe_copy "$file" "$dst_dir/$filename"
  done
}

# =============================================================================
echo ""
bold "╔══════════════════════════════════════════════════════╗"
bold "║     Claude Code Project Bootstrap                   ║"
bold "║     Stack: $STACK$(printf '%*s' $((36 - ${#STACK})) '')║"
bold "╚══════════════════════════════════════════════════════╝"
echo ""

# --- Create directory structure ---
log "Creating .claude/ structure..."
mkdir -p "$PROJECT_ROOT/.claude/"{rules,agents,hooks}
mkdir -p "$PROJECT_ROOT/.claude/skills/"{commit,fix-issue,review,spec,example-skill}

# --- Base templates ---
log "Copying base templates..."

# Rules (base)
copy_dir "$TEMPLATE_DIR/rules" "$PROJECT_ROOT/.claude/rules"

# Skills (slash commands)
for skill_dir in "$TEMPLATE_DIR/skills"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  if [ -f "$skill_dir/SKILL.md" ]; then
    safe_copy "$skill_dir/SKILL.md" "$PROJECT_ROOT/.claude/skills/$skill_name/SKILL.md"
  fi
done

# Agents
copy_dir "$TEMPLATE_DIR/agents" "$PROJECT_ROOT/.claude/agents"

# Hooks
copy_dir "$TEMPLATE_DIR/hooks" "$PROJECT_ROOT/.claude/hooks"
chmod +x "$PROJECT_ROOT/.claude/hooks/"*.sh 2>/dev/null || true

# Note: example-skill is already copied in the skills loop above

# Settings
safe_copy "$TEMPLATE_DIR/settings.json.template" \
          "$PROJECT_ROOT/.claude/settings.json" || true

# --- Stack-specific overlays ---
if [ -d "$STACK_DIR" ] && [ "$STACK" != "generic" ]; then
  log "Applying stack overlay: $STACK..."

  # Stack-specific rules (additional, don't replace base)
  copy_dir "$STACK_DIR/rules" "$PROJECT_ROOT/.claude/rules"

  # Stack-specific settings override (merge permissions)
  if [ -f "$STACK_DIR/settings.json.override" ] && [ -f "$PROJECT_ROOT/.claude/settings.json" ]; then
    # Merge: add stack-specific allow rules to existing settings
    if command -v jq &>/dev/null; then
      local_settings="$PROJECT_ROOT/.claude/settings.json"
      override="$STACK_DIR/settings.json.override"
      merged=$(jq -s '
        .[0].permissions.allow = (.[0].permissions.allow + .[1].permissions.allow | unique) |
        .[0].permissions.deny = (.[0].permissions.deny + (.[1].permissions.deny // []) | unique) |
        .[0]
      ' "$local_settings" "$override")
      echo "$merged" > "$local_settings"
      log "Merged stack permissions into settings.json"
    else
      warn "jq not found — stack permissions not auto-merged. Merge manually."
    fi
  fi

  # Stack-specific CLAUDE.md template
  if [ -f "$STACK_DIR/CLAUDE.md.template" ]; then
    safe_copy "$STACK_DIR/CLAUDE.md.template" "$PROJECT_ROOT/CLAUDE.md" || true
  fi
fi

# Generic CLAUDE.md fallback
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  safe_copy "$TEMPLATE_DIR/CLAUDE.md.template" "$PROJECT_ROOT/CLAUDE.md" || true
fi

# --- .gitignore for .claude/ ---
if [ ! -f "$PROJECT_ROOT/.claude/.gitignore" ]; then
  cat > "$PROJECT_ROOT/.claude/.gitignore" << 'GITIGNORE'
# Personal overrides — never commit
settings.local.json
agent-memory-local/
GITIGNORE
  log "Created: .claude/.gitignore"
fi

# --- Add CLAUDE.local.md to root .gitignore ---
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
  if ! grep -q "CLAUDE.local.md" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    echo -e "\n# Claude Code personal overrides\nCLAUDE.local.md" >> "$PROJECT_ROOT/.gitignore"
    log "Added CLAUDE.local.md to .gitignore"
  fi
fi

# --- Summary ---
echo ""
info "════════════════════════════════════════════════════════"
info "  Bootstrap complete! Stack: $STACK"
info "════════════════════════════════════════════════════════"
echo ""

log "Files created:"
find "$PROJECT_ROOT/.claude" -type f | sort | sed "s|$PROJECT_ROOT/||"
[ -f "$PROJECT_ROOT/CLAUDE.md" ] && echo "  CLAUDE.md"
echo ""

bold "Available skills:"
echo "  /review     — Code review current branch"
echo "  /fix-issue  — Fix a GitHub issue by number"
echo "  /spec       — Interview → write spec"
echo "  /commit     — Conventional commit"
echo ""

bold "Available agents:"
for agent_file in "$PROJECT_ROOT/.claude/agents"/*.md; do
  [ -f "$agent_file" ] || continue
  agent_name=$(basename "$agent_file" .md)
  # Extract first content line after "description:" (handles YAML folded style)
  agent_desc=$(awk '/^description:/{found=1; sub(/^description: *>? */, ""); if(length($0)>0){print; exit} next} found && /^  /{sub(/^  +/,""); print; exit}' "$agent_file" 2>/dev/null)
  # Truncate at first period or 50 chars
  agent_desc=$(echo "$agent_desc" | sed 's/\..*//' | cut -c1-50)
  if [ -n "$agent_desc" ]; then
    printf "  %-22s— %s\n" "$agent_name" "$agent_desc"
  else
    echo "  $agent_name"
  fi
done
echo ""

warn "Next steps:"
warn "  1. Edit CLAUDE.md — fill in [CUSTOMIZE] sections"
warn "  2. Review .claude/settings.json — adjust permissions for your stack"
warn "  3. Uncomment your formatter in .claude/hooks/auto-format.sh"
warn "  4. Delete rules you don't need from .claude/rules/"
echo ""
