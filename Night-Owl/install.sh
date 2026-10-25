#!/usr/bin/env bash
# ==============================================================================
#  Night Owl Desktop Theme — Installer Script
#  A developer-focused midnight navy aesthetic for Omarchy Linux + Hyprland
# ==============================================================================

set -euo pipefail

# Visual identity colors for terminal output
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_TEAL="\033[38;2;127;219;202m"    # #7FDBCA
C_BLUE="\033[38;2;130;170;255m"    # #82AAFF
C_VIOLET="\033[38;2;199;146;234m"  # #C792EA
C_NAVY="\033[38;2;29;59;83m"       # #1D3B53
C_GREEN="\033[38;2;173;219;103m"   # #ADDB67
C_YELLOW="\033[38;2;236;196;141m"  # #ECC48D
C_RED="\033[38;2;255;99;99m"       # #FF6363

log_info() {
  echo -e "${C_TEAL}🦉 [Night Owl]${C_RESET} $1"
}

log_success() {
  echo -e "${C_GREEN}✓${C_RESET} $1"
}

log_warn() {
  echo -e "${C_YELLOW}⚠${C_RESET} $1"
}

log_error() {
  echo -e "${C_RED}✗${C_RESET} $1" >&2
}

# ------------------------------------------------------------------------------
# Flags and parameters
# ------------------------------------------------------------------------------
DRY_RUN=false
NO_BACKUP=false
FORCE=false

show_help() {
  cat <<HELP
Usage: ./install.sh [OPTIONS]

Options:
  -d, --dry-run     Show what would be copied without making changes.
  --no-backup       Skip backing up existing configuration files.
  -f, --force       Overwrite existing files without prompting.
  -h, --help        Show this help message.

HELP
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-backup)
      NO_BACKUP=true
      shift
      ;;
    -f|--force)
      FORCE=true
      shift
      ;;
    -h|--help)
      show_help
      ;;
    *)
      log_error "Unknown option: $1"
      show_help
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${HOME}/.config/omarchy/backups/nightowl_pre_install_${TIMESTAMP}"

# ------------------------------------------------------------------------------
# Banner
# ------------------------------------------------------------------------------
echo -e "${C_TEAL}"
cat << "BANNER"
  _   _ _       _     _      ___            _ 
 | \ | (_) __ _| |__ | |_   / _ \__      _| |
 |  \| | |/ _` | '_ \| __| | | | \ \ /\ / / |
 | |\  | | (_| | | | | |_  | |_| |\ V  V /| |
 |_| \_|_|\__, |_| |_|\__|  \___/  \_/\_/ |_|
          |___/      Night Owl Desktop
BANNER
echo -e "${C_RESET}"
log_info "Starting Night Owl installation..."

# ------------------------------------------------------------------------------
# Prerequisites Check
# ------------------------------------------------------------------------------
log_info "Verifying dependencies..."
MISSING_DEPS=()
for dep in hyprland quickshell python3; do
  if ! command -v "$dep" &>/dev/null; then
    MISSING_DEPS+=("$dep")
  fi
done

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
  log_warn "Optional dependencies missing: ${MISSING_DEPS[*]}"
fi

# ------------------------------------------------------------------------------
# Backup function
# ------------------------------------------------------------------------------
backup_item() {
  local target="$1"
  if [[ -e "$target" && "$NO_BACKUP" == false ]]; then
    # Do not back up Night Owl's own custom files
    if [[ "$target" == "${HOME}/.config/omarchy/themes/night-owl"* ]] || \
       [[ "$target" == "${HOME}/.config/omarchy/plugins/nightowl."* ]]; then
      return 0
    fi
    local rel_path="${target#"$HOME"/}"
    local backup_target="${BACKUP_DIR}/${rel_path}"
    mkdir -p "$(dirname "$backup_target")"
    cp -rP "$target" "$backup_target"
    log_info "Backed up: $rel_path -> ${BACKUP_DIR}/${rel_path}"
  fi
}

copy_safe() {
  local src="$1"
  local dst="$2"

  if [[ "$DRY_RUN" == true ]]; then
    echo -e "  ${C_BLUE}[DRY-RUN]${C_RESET} Would deploy: $src -> $dst"
    return 0
  fi

  backup_item "$dst"
  mkdir -p "$(dirname "$dst")"
  cp -r "$src" "$dst"
  log_success "Deployed: $dst"
}

# ------------------------------------------------------------------------------
# 1. Deploy Quickshell Plugins
# ------------------------------------------------------------------------------
log_info "Deploying Night Owl Quickshell plugins..."
PLUGINS_SRC="${SCRIPT_DIR}/config/omarchy/plugins"
PLUGINS_DST="${HOME}/.config/omarchy/plugins"

if [[ -d "${PLUGINS_SRC}/nightowl.workspaces" ]]; then
  copy_safe "${PLUGINS_SRC}/nightowl.workspaces" "${PLUGINS_DST}/nightowl.workspaces"
fi

# ------------------------------------------------------------------------------
# 2. Deploy Night Owl Theme Bundle
# ------------------------------------------------------------------------------
log_info "Deploying Night Owl theme files..."
THEME_SRC="${SCRIPT_DIR}/config/omarchy/themes/night-owl"
THEME_DST="${HOME}/.config/omarchy/themes/night-owl"
copy_safe "$THEME_SRC" "$THEME_DST"

# ------------------------------------------------------------------------------
# 3. Deploy Assets & Wallpapers
# ------------------------------------------------------------------------------
log_info "Deploying wallpapers and preview assets..."
mkdir -p "${HOME}/.config/omarchy/themes/night-owl/backgrounds"

if [[ -d "${SCRIPT_DIR}/assets/wallpapers" ]]; then
  for wp in "${SCRIPT_DIR}/assets/wallpapers"/*; do
    if [[ -f "$wp" && "$wp" == *.png ]]; then
      copy_safe "$wp" "${HOME}/.config/omarchy/themes/night-owl/backgrounds/$(basename "$wp")"
    fi
  done
fi

# ------------------------------------------------------------------------------
# 4. Deploy Theme Switch Hook & Utilities
# ------------------------------------------------------------------------------
log_info "Deploying automation hooks and switcher binary..."
HOOK_SRC="${SCRIPT_DIR}/config/omarchy/themes/night-owl/scripts/omarchy-theme-switch.sh"
HOOK_DST="${HOME}/.config/omarchy/hooks/theme-set.d/omarchy-theme-switch.sh"

if [[ -f "$HOOK_SRC" ]]; then
  copy_safe "$HOOK_SRC" "$HOOK_DST"
  if [[ "$DRY_RUN" == false ]]; then
    chmod +x "$HOOK_DST" 2>/dev/null || true
  fi
fi

if [[ -f "${SCRIPT_DIR}/bin/omarchy-theme-switch" ]]; then
  copy_safe "${SCRIPT_DIR}/bin/omarchy-theme-switch" "${HOME}/.local/bin/omarchy-theme-switch"
  if [[ "$DRY_RUN" == false ]]; then
    chmod +x "${HOME}/.local/bin/omarchy-theme-switch" 2>/dev/null || true
  fi
fi

# ------------------------------------------------------------------------------
# 5. Activate Night Owl Theme
# ------------------------------------------------------------------------------
if [[ "$DRY_RUN" == false ]]; then
  log_info "Activating Night Owl desktop theme..."
  if command -v omarchy &>/dev/null; then
    omarchy theme set night-owl 2>/dev/null || true
  fi
  log_success "Night Owl desktop theme installed and activated successfully!"
  if [[ "$NO_BACKUP" == false ]]; then
    log_info "Previous configuration backups saved in: $BACKUP_DIR"
  fi
else
  log_info "Dry run complete. No modifications were written to disk."
fi
