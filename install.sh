#!/usr/bin/env bash
# ==============================================================================
# OpenCode + Orca Two-Tier Multi-Agent Orchestration Installer
# Supports: Linux, macOS, WSL, Git Bash
# ==============================================================================

set -euo pipefail

# Color palette
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Default flags
DRY_RUN=false
FORCE=false
BACKUP=true

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force|-f)
      FORCE=true
      shift
      ;;
    --no-backup)
      BACKUP=false
      shift
      ;;
    --help|-h)
      echo -e "${BOLD}OpenCode + Orca Orchestration Installer${NC}"
      echo ""
      echo "Usage: ./install.sh [options]"
      echo ""
      echo "Options:"
      echo "  --dry-run     Show what would be copied without making changes"
      echo "  --force, -f   Overwrite existing destination files without prompting"
      echo "  --no-backup   Do not create .bak copies of existing configuration"
      echo "  --help, -h    Display this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Run './install.sh --help' for usage."
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
TARGET_AGENT_DIR="$TARGET_CONFIG_DIR/agent"
TARGET_SKILLS_DIR="$HOME/.agents/skills"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo -e "${CYAN}${BOLD}"
cat << "EOF"
  ___  ____  _____ _   _  ____ ___  ____  _____ 
 / _ \|  _ \| ____| \ | |/ ___/ _ \|  _ \| ____|
| | | | |_) |  _| |  \| | |  | | | | | | |  _|  
| |_| |  __/| |___| |\  | |__| |_| | |_| | |___ 
 \___/|_|   |_____|_| \_|\____\___/|____/|_____|
  + Orca Two-Tier Multi-Agent Orchestration
EOF
echo -e "${NC}"

echo -e "${BLUE}==>${NC} Target Configuration Directory: ${BOLD}$TARGET_CONFIG_DIR${NC}"
echo -e "${BLUE}==>${NC} Target Skills Directory:        ${BOLD}$TARGET_SKILLS_DIR${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}${BOLD}[DRY-RUN MODE] No files will be written.${NC}"
fi
echo ""

# Helper copy function with dry-run and backup handling
deploy_file() {
  local src="$1"
  local dest="$2"

  if [ ! -f "$src" ]; then
    echo -e "${RED}Error:${NC} Source file $src does not exist."
    return 1
  fi

  if [ -f "$dest" ]; then
    if [ "$BACKUP" = true ] && [ "$DRY_RUN" = false ]; then
      cp "$dest" "${dest}.bak_${TIMESTAMP}"
      echo -e "  ${YELLOW}Backed up:${NC} $dest -> ${dest}.bak_${TIMESTAMP}"
    fi
  fi

  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${CYAN}[dry-run] Would copy:${NC} $src -> $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo -e "  ${GREEN}Installed:${NC} $dest"
  fi
}

deploy_dir() {
  local src_dir="$1"
  local dest_dir="$2"

  if [ ! -d "$src_dir" ]; then
    echo -e "${RED}Error:${NC} Source directory $src_dir does not exist."
    return 1
  fi

  if [ "$DRY_RUN" = true ]; then
    echo -e "  ${CYAN}[dry-run] Would sync directory:${NC} $src_dir -> $dest_dir"
  else
    mkdir -p "$dest_dir"
    cp -R "$src_dir"/* "$dest_dir"/
    echo -e "  ${GREEN}Synced directory:${NC} $dest_dir"
  fi
}

# 1. Prepare directories
echo -e "${BOLD}1. Preparing directories...${NC}"
if [ "$DRY_RUN" = false ]; then
  mkdir -p "$TARGET_AGENT_DIR"
  mkdir -p "$TARGET_SKILLS_DIR"
fi
echo -e "  ${GREEN}Directories ready.${NC}"

# 2. Deploy Orchestration Contract
echo -e "\n${BOLD}2. Deploying ORCHESTRATION.md...${NC}"
deploy_file "$SCRIPT_DIR/ORCHESTRATION.md" "$TARGET_CONFIG_DIR/ORCHESTRATION.md"

# 3. Deploy Subagents
echo -e "\n${BOLD}3. Deploying Subagents (agent/)...${NC}"
for agent_file in "$SCRIPT_DIR/agent"/*.md; do
  if [ -f "$agent_file" ]; then
    fname="$(basename "$agent_file")"
    deploy_file "$agent_file" "$TARGET_AGENT_DIR/$fname"
  fi
done

# 4. Deploy Skills
echo -e "\n${BOLD}4. Deploying Specialized Skills (skills/)...${NC}"
for skill_dir in "$SCRIPT_DIR/skills"/*; do
  if [ -d "$skill_dir" ]; then
    sname="$(basename "$skill_dir")"
    deploy_dir "$skill_dir" "$TARGET_SKILLS_DIR/$sname"
  fi
done

# 5. Handle opencode.jsonc configuration
echo -e "\n${BOLD}5. Configuring opencode.jsonc...${NC}"
DEST_JSONC="$TARGET_CONFIG_DIR/opencode.jsonc"

if [ -f "$DEST_JSONC" ]; then
  echo -e "  ${YELLOW}Notice:${NC} $DEST_JSONC already exists."
  if grep -q "ORCHESTRATION.md" "$DEST_JSONC"; then
    echo -e "  ${GREEN}Verified:${NC} ORCHESTRATION.md is already referenced in instructions."
  else
    echo -e "  ${YELLOW}Action required:${NC} Add '${BOLD}$TARGET_CONFIG_DIR/ORCHESTRATION.md${NC}' to your 'instructions' array in $DEST_JSONC."
    echo -e "  A reference template has been copied to: ${BOLD}$TARGET_CONFIG_DIR/opencode.jsonc.template${NC}"
    deploy_file "$SCRIPT_DIR/opencode.jsonc" "$TARGET_CONFIG_DIR/opencode.jsonc.template"
  fi
else
  deploy_file "$SCRIPT_DIR/opencode.jsonc" "$DEST_JSONC"
fi

# 6. Check CLI dependencies
echo -e "\n${BOLD}6. Checking System Dependencies...${NC}"

if command -v opencode >/dev/null 2>&1; then
  OPENCODE_VER=$(opencode --version 2>/dev/null || echo "detected")
  echo -e "  ${GREEN}✓ OpenCode installed:${NC} $OPENCODE_VER"
else
  echo -e "  ${YELLOW}! OpenCode CLI not found in PATH.${NC}"
  echo -e "    Install via: ${BOLD}npm install -g opencode-ai${NC} or ${BOLD}bun add -g opencode-ai${NC}"
fi

if command -v orca >/dev/null 2>&1; then
  echo -e "  ${GREEN}✓ Orca CLI installed.${NC}"
else
  echo -e "  ${YELLOW}i Orca CLI not detected.${NC}"
  echo -e "    Orca is required for Tier 1 floating dispatcher handoffs."
  echo -e "    (OpenCode subagent delegation still works standalone inside any worktree!)"
fi

echo -e "\n${GREEN}${BOLD}==============================================================${NC}"
echo -e "${GREEN}${BOLD}Installation Complete! Setup is ready to use.${NC}"
echo -e "${GREEN}${BOLD}==============================================================${NC}"
echo ""
echo -e "Installed components:"
echo -e "  - Tier 1 & Tier 2 Contract : ${BOLD}$TARGET_CONFIG_DIR/ORCHESTRATION.md${NC}"
echo -e "  - Subagent Definitions     : ${BOLD}$TARGET_AGENT_DIR/{worker-gemini,worker-gpt,tester,code-reviewer,researcher}.md${NC}"
echo -e "  - Performance Skills       : ${BOLD}$TARGET_SKILLS_DIR/{ponytail,caveman,orchestration,orca-cli}${NC}"
echo ""
echo -e "To start your lead orchestrator:"
echo -e "  ${CYAN}opencode --model openai/gpt-5.6-sol${NC}"
echo ""
echo -e "To dispatch from Orca Floating Terminal (Tier 1):"
echo -e "  ${CYAN}orca terminal create --worktree \"path:<worktree_path>\" --title \"<Task>\" --command \"opencode --model openai/gpt-5.6-sol\"${NC}"
echo -e "  ${CYAN}orca orchestration dispatch --task <task_id> --to <terminal_handle> --inject${NC}"
echo ""
