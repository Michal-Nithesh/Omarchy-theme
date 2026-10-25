#!/usr/bin/env bash
# ==============================================================================
#  Night Owl Desktop Theme — Uninstaller Script
#  Safely removes Night Owl files and restores the prior desktop theme
# ==============================================================================

set -euo pipefail

C_RESET="\033[0m"
C_BOLD="\033[1m"
C_TEAL="\033[38;2;127;219;202m"
C_GREEN="\033[38;2;173;219;103m"
C_YELLOW="\033[38;2;236;196;141m"
C_RED="\033[38;2;255;99;99m"

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

DRY_RUN=false
FORCE=false

show_help() {
  cat <<HELP
Usage: ./uninstall.sh [OPTIONS]

Options:
  -d, --dry-run     Show files that would be removed without deleting them.
  -f, --force       Uninstall without confirmation prompt.
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

if [[ "$FORCE" == false && "$DRY_RUN" == false ]]; then
  echo -e "${C_YELLOW}This will remove the Night Owl desktop theme and its workspace widget.${C_RESET}"
  echo -e "Existing Sakurazuki files will NOT be affected."
  read -rp "Are you sure you want to proceed? [y/N] " confirm
  if [[ "$confirm" != [yY] && "$confirm" != [yY][eE][sS] ]]; then
    echo "Uninstallation cancelled."
    exit 0
  fi
fi

log_info "Uninstalling Night Owl desktop theme..."

# 1. Revert active theme if currently Night Owl
CURRENT_THEME=$(cat "${HOME}/.local/state/omarchy/current/theme.name" 2>/dev/null || echo "")
if [[ "$CURRENT_THEME" == "night-owl" ]]; then
  log_info "Active theme is Night Owl. Reverting to Sakurazuki..."
  if [[ "$DRY_RUN" == false && -d "${HOME}/.config/omarchy/themes/sakurazuki" ]]; then
    omarchy theme set sakurazuki 2>/dev/null || true
    log_success "Reverted active theme to Sakurazuki."
  fi
fi

# 2. Remove Night Owl Theme Files
NIGHT_OWL_THEME="${HOME}/.config/omarchy/themes/night-owl"
if [[ -e "$NIGHT_OWL_THEME" ]]; then
  if [[ "$DRY_RUN" == true ]]; then
    echo "  [DRY-RUN] Would remove: $NIGHT_OWL_THEME"
  else
    rm -rf "$NIGHT_OWL_THEME"
    log_success "Removed: $NIGHT_OWL_THEME"
  fi
fi

# 3. Remove Night Owl Workspaces Plugin
NIGHT_OWL_PLUGIN="${HOME}/.config/omarchy/plugins/nightowl.workspaces"
if [[ -e "$NIGHT_OWL_PLUGIN" ]]; then
  if [[ "$DRY_RUN" == true ]]; then
    echo "  [DRY-RUN] Would remove: $NIGHT_OWL_PLUGIN"
  else
    rm -rf "$NIGHT_OWL_PLUGIN"
    log_success "Removed: $NIGHT_OWL_PLUGIN"
  fi
fi

# 4. Remove Hook if no other themes require it
NIGHT_OWL_HOOK="${HOME}/.config/omarchy/hooks/theme-set.d/omarchy-theme-switch.sh"
if [[ -e "$NIGHT_OWL_HOOK" && ! -d "${HOME}/.config/omarchy/themes/sakurazuki" ]]; then
  if [[ "$DRY_RUN" == true ]]; then
    echo "  [DRY-RUN] Would remove: $NIGHT_OWL_HOOK"
  else
    rm -f "$NIGHT_OWL_HOOK"
    log_success "Removed: $NIGHT_OWL_HOOK"
  fi
fi

log_success "Night Owl desktop theme uninstalled successfully!"
