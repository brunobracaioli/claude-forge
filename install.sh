#!/usr/bin/env bash
# =============================================================================
# Install claude-forge as a global Claude Code skill
#
# Usage:
#   # Install latest tagged release (recommended — reproducible):
#   curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/v1.1.0/install.sh | CLAUDE_FORGE_REF=v1.1.0 bash
#
#   # Install from a specific tag, branch, or commit:
#   curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash -s -- --ref v1.1.0
#
#   # Install from current clone:
#   git clone https://github.com/brunobracaioli/claude-forge.git
#   cd claude-forge && bash install.sh
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}[install]${NC} $1"; }
warn() { echo -e "${YELLOW}[install]${NC} $1"; }
info() { echo -e "${CYAN}[install]${NC} $1"; }

SKILL_NAME="claude-forge"
TARGET_DIR="$HOME/.claude/skills/$SKILL_NAME"
REF="${CLAUDE_FORGE_REF:-main}"

# --- Parse args ---
while [ $# -gt 0 ]; do
  case "$1" in
    --ref)   REF="${2:?--ref requires a value}"; shift 2 ;;
    --ref=*) REF="${1#--ref=}"; shift ;;
    -h|--help)
      sed -n '/^# Usage:/,/^# ====/p' "$0" | sed 's/^# //'
      exit 0 ;;
    *) warn "Unknown argument: $1"; shift ;;
  esac
done

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Claude Project Bootstrap — Installer              ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# --- Detect source ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if [ -f "$SCRIPT_DIR/SKILL.md" ]; then
  SOURCE_DIR="$SCRIPT_DIR"
  log "Installing from local directory: $SOURCE_DIR"
  if [ "$REF" != "main" ]; then
    warn "--ref=$REF ignored (installing from local checkout)"
  fi
else
  # Clone from GitHub at the requested ref (branch, tag, or commit-ish)
  REPO_URL="https://github.com/brunobracaioli/claude-forge.git"
  TEMP_DIR=$(mktemp -d)
  log "Cloning $REPO_URL @ $REF..."
  if ! git clone --depth 1 --branch "$REF" "$REPO_URL" "$TEMP_DIR" 2>/dev/null; then
    warn "Shallow clone of '$REF' failed — falling back to full clone + checkout"
    rm -rf "$TEMP_DIR" && TEMP_DIR=$(mktemp -d)
    git clone "$REPO_URL" "$TEMP_DIR" 2>/dev/null
    git -C "$TEMP_DIR" checkout "$REF"
  fi
  SOURCE_DIR="$TEMP_DIR"
fi

# --- Remove previous installation automatically ---
if [ -d "$TARGET_DIR" ]; then
  warn "Removing previous installation at $TARGET_DIR..."
  rm -rf "$TARGET_DIR"
fi

mkdir -p "$TARGET_DIR"
cp -r "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/"
cp -r "$SOURCE_DIR/scripts" "$TARGET_DIR/"
cp -r "$SOURCE_DIR/templates" "$TARGET_DIR/"
cp -r "$SOURCE_DIR/stacks" "$TARGET_DIR/"
cp -r "$SOURCE_DIR/presets" "$TARGET_DIR/"

# Copy release metadata if present (consumed by bootstrap.sh --update)
for meta in VERSION CHANGELOG.md plugin.json manifest.json LICENSE; do
  [ -f "$SOURCE_DIR/$meta" ] && cp "$SOURCE_DIR/$meta" "$TARGET_DIR/"
done

# Make scripts executable
chmod +x "$TARGET_DIR/scripts/"*.sh
find "$TARGET_DIR" -name "*.sh" -exec chmod +x {} \;

# Cleanup temp if cloned
[ -n "${TEMP_DIR:-}" ] && rm -rf "$TEMP_DIR"

INSTALLED_VERSION="unknown"
[ -f "$TARGET_DIR/VERSION" ] && INSTALLED_VERSION=$(tr -d '[:space:]' < "$TARGET_DIR/VERSION")

echo ""
log "Installed claude-forge v${INSTALLED_VERSION} to: $TARGET_DIR"
echo ""
info "Usage:"
info "  In any project, run:  /claude-forge <stack> [--preset mvp|production] [--tier core|full] [--update]"
info "  Or ask Claude:        \"monte a estrutura do projeto\""
echo ""
info "Available stacks:  flask-next | node | python | react | rust | generic | auto"
info "Available presets: mvp | production | none"
info "Agent tiers:       core (5 default) | full (all 15)"
echo ""
info "To pin a specific version, re-run:"
info "  curl -fsSL .../install.sh | CLAUDE_FORGE_REF=v1.1.0 bash"
echo ""
log "Done! Restart Claude Code to pick up the new skill."
echo ""
