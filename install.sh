#!/usr/bin/env bash
# =============================================================================
# Install claude-forge as a global Claude Code skill
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/brunobracaioli/claude-forge/main/install.sh | bash
#   or:
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

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Claude Project Bootstrap — Installer              ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# --- Detect source ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/SKILL.md" ]; then
  SOURCE_DIR="$SCRIPT_DIR"
  log "Installing from local directory: $SOURCE_DIR"
else
  # Clone from GitHub
  REPO_URL="https://github.com/brunobracaioli/claude-forge.git"
  TEMP_DIR=$(mktemp -d)
  log "Cloning from $REPO_URL..."
  git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null
  SOURCE_DIR="$TEMP_DIR"
fi

# --- Install ---
if [ -d "$TARGET_DIR" ]; then
  warn "Existing installation found at $TARGET_DIR"
  read -p "  Overwrite? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Installation cancelled."
    exit 0
  fi
  rm -rf "$TARGET_DIR"
fi

mkdir -p "$TARGET_DIR"
cp -r "$SOURCE_DIR/SKILL.md" "$TARGET_DIR/"
cp -r "$SOURCE_DIR/scripts" "$TARGET_DIR/"
cp -r "$SOURCE_DIR/templates" "$TARGET_DIR/"
cp -r "$SOURCE_DIR/stacks" "$TARGET_DIR/"

# Make scripts executable
chmod +x "$TARGET_DIR/scripts/"*.sh
find "$TARGET_DIR" -name "*.sh" -exec chmod +x {} \;

# Cleanup temp if cloned
[ -n "${TEMP_DIR:-}" ] && rm -rf "$TEMP_DIR"

echo ""
log "Installed to: $TARGET_DIR"
echo ""
info "Usage:"
info "  In any project, run:  /project-bootstrap <stack>"
info "  Or ask Claude:        \"monte a estrutura do projeto\""
echo ""
info "Available stacks: flask-next | node | python | react | rust | generic"
echo ""
log "Done! Restart Claude Code to pick up the new skill."
echo ""
