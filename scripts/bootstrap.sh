#!/usr/bin/env bash
# =============================================================================
# project-bootstrap: Scaffold .claude/ directory structure
#
# Usage:
#   bootstrap.sh <project_root> [stack] [preset] [--tier core|full] [--update]
#
# Stacks:   flask-next | node | python | react | rust | generic | auto
# Presets:  mvp | production | none (default: none)
# Tiers:    core (5 agents, default) | full (all 15)
# --update: re-run on an existing project; unmodified templates are refreshed,
#           modified files are preserved and the new version is written as
#           <file>.new alongside. Non-destructive by default.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$SKILL_DIR/templates"

# --- Parse args (mix of positional and flags) ---
POS=()
UPDATE_MODE=0
AGENT_TIER="core"

while [ $# -gt 0 ]; do
  case "$1" in
    --update)    UPDATE_MODE=1; shift ;;
    --tier)      AGENT_TIER="${2:?--tier requires core|full}"; shift 2 ;;
    --tier=*)    AGENT_TIER="${1#--tier=}"; shift ;;
    --preset)    POS+=("__preset:$2"); shift 2 ;;
    --preset=*)  POS+=("__preset:${1#--preset=}"); shift ;;
    --)          shift; while [ $# -gt 0 ]; do POS+=("$1"); shift; done ;;
    -*)          echo "[bootstrap] Unknown flag: $1" >&2; shift ;;
    *)           POS+=("$1"); shift ;;
  esac
done

# Separate positional args from --preset overrides
PROJECT_ROOT="."
STACK="generic"
PRESET="none"
POS_INDEX=0
if [ "${#POS[@]}" -gt 0 ]; then
  for arg in "${POS[@]}"; do
    case "$arg" in
      __preset:*) PRESET="${arg#__preset:}" ;;
      *)
        case "$POS_INDEX" in
          0) PROJECT_ROOT="$arg" ;;
          1) STACK="$arg" ;;
          2) PRESET="$arg" ;;
        esac
        POS_INDEX=$((POS_INDEX + 1))
        ;;
    esac
  done
fi

# Validate tier
case "$AGENT_TIER" in
  core|full) : ;;
  *) echo "[bootstrap] Invalid --tier '$AGENT_TIER' (expected: core|full). Using 'core'." >&2; AGENT_TIER="core" ;;
esac

STACK_DIR="$SKILL_DIR/stacks/$STACK"
PRESET_DIR="$SKILL_DIR/presets/$PRESET"

# Read forge version if shipped
FORGE_VERSION="unknown"
[ -f "$SKILL_DIR/VERSION" ] && FORGE_VERSION=$(tr -d '[:space:]' < "$SKILL_DIR/VERSION")

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
  # Framework-specific markers take precedence over generic language markers
  if [ -f "$root/artisan" ]; then
    echo "laravel"
  elif [ -f "$root/manage.py" ]; then
    echo "django"
  elif [ -f "$root/go.mod" ]; then
    echo "go"
  elif [ -f "$root/next.config.js" ] || [ -f "$root/next.config.ts" ] || [ -f "$root/next.config.mjs" ]; then
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
VALID_STACKS="flask-next node python react rust django go laravel generic"
if ! echo "$VALID_STACKS" | grep -qw "$STACK"; then
  warn "Unknown stack '$STACK'. Using 'generic'."
  STACK="generic"
fi

STACK_DIR="$SKILL_DIR/stacks/$STACK"

# Alias legacy preset name (pre-1.2). Remove in v2.0.
if [ "$PRESET" = "production" ]; then
  warn "Preset 'production' is a deprecated alias for 'production-aws'. Update your invocation."
  PRESET="production-aws"
fi

# Validate preset
VALID_PRESETS="mvp production-aws production-gcp none"
if ! echo "$VALID_PRESETS" | grep -qw "$PRESET"; then
  warn "Unknown preset '$PRESET'. Using 'none'."
  PRESET="none"
fi
PRESET_DIR="$SKILL_DIR/presets/$PRESET"

# --- Hash helpers for --update mode ---
compute_sha256() {
  local f="$1"
  if command -v sha256sum &>/dev/null; then
    printf 'sha256:%s' "$(sha256sum "$f" | awk '{print $1}')"
  elif command -v shasum &>/dev/null; then
    printf 'sha256:%s' "$(shasum -a 256 "$f" | awk '{print $1}')"
  fi
}

shipped_hash() {
  local rel="$1"
  [ -f "$SKILL_DIR/manifest.json" ] || return 1
  command -v jq &>/dev/null || return 1
  jq -r --arg k "$rel" '.files[$k] // empty' "$SKILL_DIR/manifest.json"
}

# --- Safe copy: never overwrite unless --update + hash matches shipped ---
safe_copy() {
  local src="$1" dst="$2"
  if [ -f "$dst" ]; then
    if [ "$UPDATE_MODE" = "1" ]; then
      local rel="${src#$SKILL_DIR/}"
      # Defensive: collapse any accidental double slashes from caller
      rel="${rel//\/\//\/}"
      local ship local_h
      ship=$(shipped_hash "$rel" 2>/dev/null || true)
      local_h=$(compute_sha256 "$dst" 2>/dev/null || true)
      if [ -n "$ship" ] && [ -n "$local_h" ] && [ "$ship" = "$local_h" ]; then
        cp "$src" "$dst"
        log "Updated (unmodified): $dst"
        return 0
      fi
      cp "$src" "$dst.new"
      warn "Preserved local + wrote sidecar: $dst.new"
      return 0
    fi
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
bold "╚══════════════════════════════════════════════════════╝"
info "Version: v$FORGE_VERSION"
info "Stack:   $STACK"
info "Preset:  $PRESET"
info "Agents:  $AGENT_TIER tier"
[ "$UPDATE_MODE" = "1" ] && info "Mode:    update (non-destructive)"
echo ""

# --- Create directory structure ---
log "Creating .claude/ structure..."
mkdir -p "$PROJECT_ROOT/.claude/"{rules,agents,hooks}
mkdir -p "$PROJECT_ROOT/.claude/skills/"{commit,fix-issue,review,spec,spec-build,checkpoint,security-audit,infra-audit,pentest-recon,example-skill}
mkdir -p "$PROJECT_ROOT/.claude/checkpoints"

# --- Base templates ---
log "Copying base templates..."

# Rules (base)
copy_dir "$TEMPLATE_DIR/rules" "$PROJECT_ROOT/.claude/rules"

# Skills (slash commands)
for skill_dir in "$TEMPLATE_DIR/skills"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  # Strip trailing slash to avoid "commit//SKILL.md" breaking manifest lookups
  skill_dir_norm="${skill_dir%/}"
  if [ -f "$skill_dir_norm/SKILL.md" ]; then
    safe_copy "$skill_dir_norm/SKILL.md" "$PROJECT_ROOT/.claude/skills/$skill_name/SKILL.md"
  fi
done

# Agents — gated by tier (core = 5 default, full = all 15)
AGENTS_DIR="$TEMPLATE_DIR/agents"
TIERS_FILE="$AGENTS_DIR/TIERS.json"
if [ "$AGENT_TIER" = "full" ]; then
  # Copy every .md agent (skip TIERS.json manifest)
  copy_dir "$AGENTS_DIR" "$PROJECT_ROOT/.claude/agents" "*.md"
  log "Installed full agent tier (all agents)"
elif [ -f "$TIERS_FILE" ] && command -v jq &>/dev/null; then
  CORE_COUNT=$(jq -r '.core | length' "$TIERS_FILE")
  log "Installing core agent tier ($CORE_COUNT agents). Use --tier full for all."
  while IFS= read -r agent; do
    [ -z "$agent" ] && continue
    [ -f "$AGENTS_DIR/${agent}.md" ] || { warn "TIERS.json references missing agent: ${agent}.md"; continue; }
    safe_copy "$AGENTS_DIR/${agent}.md" "$PROJECT_ROOT/.claude/agents/${agent}.md" || true
  done < <(jq -r '.core[]' "$TIERS_FILE")
else
  warn "TIERS.json missing or jq unavailable — falling back to full agent install"
  copy_dir "$AGENTS_DIR" "$PROJECT_ROOT/.claude/agents" "*.md"
fi

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

# --- Preset overlay ---
if [ -d "$PRESET_DIR" ] && [ "$PRESET" != "none" ]; then
  log "Applying architecture preset: $PRESET..."

  # Preset-specific rules
  copy_dir "$PRESET_DIR/rules" "$PROJECT_ROOT/.claude/rules"

  # Preset-specific settings override (merge permissions)
  if [ -f "$PRESET_DIR/settings.json.override" ] && [ -f "$PROJECT_ROOT/.claude/settings.json" ]; then
    if command -v jq &>/dev/null; then
      local_settings="$PROJECT_ROOT/.claude/settings.json"
      override="$PRESET_DIR/settings.json.override"
      merged=$(jq -s '
        .[0].permissions.allow = (.[0].permissions.allow + .[1].permissions.allow | unique) |
        .[0].permissions.deny = (.[0].permissions.deny + (.[1].permissions.deny // []) | unique) |
        .[0]
      ' "$local_settings" "$override")
      echo "$merged" > "$local_settings"
      log "Merged preset permissions into settings.json"
    else
      warn "jq not found — preset permissions not auto-merged. Merge manually."
    fi
  fi

  # Copy preset IaC/CI templates to project root
  if [ -d "$PRESET_DIR/templates" ]; then
    log "Copying $PRESET IaC/CI templates..."
    # Recursively copy template files, preserving directory structure
    (cd "$PRESET_DIR/templates" && find . -type f) | while read -r file; do
      file="${file#./}"
      src="$PRESET_DIR/templates/$file"
      dst="$PROJECT_ROOT/$file"
      safe_copy "$src" "$dst"
    done
  fi
fi

# Generic CLAUDE.md fallback
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  safe_copy "$TEMPLATE_DIR/CLAUDE.md.template" "$PROJECT_ROOT/CLAUDE.md" || true
fi

# --- Append preset snippet to CLAUDE.md ---
if [ -f "$PRESET_DIR/CLAUDE.md.snippet" ] && [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  if ! grep -q "Architecture.*Preset" "$PROJECT_ROOT/CLAUDE.md" 2>/dev/null; then
    echo "" >> "$PROJECT_ROOT/CLAUDE.md"
    cat "$PRESET_DIR/CLAUDE.md.snippet" >> "$PROJECT_ROOT/CLAUDE.md"
    log "Appended $PRESET preset architecture section to CLAUDE.md"
  else
    warn "SKIP: CLAUDE.md already has an architecture preset section"
  fi
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
info "  Bootstrap complete! Stack: $STACK | Preset: $PRESET"
info "════════════════════════════════════════════════════════"
echo ""

log "Files created:"
find "$PROJECT_ROOT/.claude" -type f | sort | sed "s|$PROJECT_ROOT/||"
[ -f "$PROJECT_ROOT/CLAUDE.md" ] && echo "  CLAUDE.md"
echo ""

bold "Available skills:"
echo "  /review         — Code review current branch"
echo "  /fix-issue      — Fix a GitHub issue by number"
echo "  /spec           — Interview → write spec"
echo "  /spec-build     — Build project from spec (Agent Teams)"
echo "  /commit         — Conventional commit"
echo "  /checkpoint     — Save verified snapshot (tests + tag + context)"
echo "  /security-audit — OWASP Top 10 security review"
echo "  /infra-audit    — Terraform/Docker/CI config review"
echo "  /pentest-recon  — Attack surface mapping (passive, codebase-only)"
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

bold "Spec-Driven Build (Agent Teams):"
echo "  1. /spec <feature>       — Generate a spec via interview"
echo "  2. /spec-build            — Build the project from spec using multi-agent team"
echo "  Requires: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=\"1\" in settings.json"
echo "  Agents: orchestrator, api-developer, frontend-developer + reviewers"
echo ""

if [ "$PRESET" = "production-aws" ]; then
  bold "Infrastructure as Code (AWS production preset):"
  echo "  terraform/              — VPC + RDS + ECS Fargate (modular)"
  echo "  Dockerfile              — Multi-stage build, non-root, healthcheck"
  echo "  docker-compose.yml      — Local dev with Postgres + Redis + LocalStack"
  echo "  .github/workflows/ci.yml    — Lint + test + SAST + Docker build"
  echo "  .github/workflows/deploy.yml — ECR push + ECS deploy on merge"
  echo ""
elif [ "$PRESET" = "production-gcp" ]; then
  bold "Infrastructure as Code (GCP production preset):"
  echo "  terraform/              — VPC + Cloud SQL + Cloud Run (modular)"
  echo "  Dockerfile              — Multi-stage build, non-root, healthcheck"
  echo "  docker-compose.yml      — Local dev with Postgres + Redis"
  echo "  .github/workflows/ci.yml    — Lint + test + SAST + Docker build"
  echo "  .github/workflows/deploy.yml — Cloud Build + Cloud Run deploy (WIF, no keys)"
  echo ""
elif [ "$PRESET" = "mvp" ]; then
  bold "Infrastructure (MVP preset):"
  echo "  docker-compose.yml      — Local dev with Postgres + Redis"
  echo "  .github/workflows/ci.yml — Lint + test + build"
  echo ""
fi

bold "Security hooks (active by default):"
echo "  secret-scan        — Blocks commits with hardcoded secrets (gitleaks or regex)"
echo "  sast-scan          — Flags SQL injection, eval(), weak crypto, disabled TLS"
echo "  dependency-check   — Warns on insecure deps (npm audit / pip-audit / cargo audit)"
echo ""

warn "Next steps:"
warn "  1. Edit CLAUDE.md — fill in [CUSTOMIZE] sections"
warn "  2. Review .claude/settings.json — adjust permissions for your stack"
warn "  3. Uncomment your formatter in .claude/hooks/auto-format.sh"
warn "  4. Delete rules you don't need from .claude/rules/"
warn "  5. To use Agent Teams: set CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS to \"1\""
echo ""
