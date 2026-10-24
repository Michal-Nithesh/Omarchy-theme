#!/usr/bin/env bash
# ==============================================================================
#  Michal × Sakurazuki — Uninstaller Script
#  Reverts Sakurazuki configuration and restores pre-install backups
# ==============================================================================

set -euo pipefail

C_RESET="\033[0m"
C_BOLD="\033[1m"
C_SAKURA="\033[38;2;217;166;196m"
C_PLUM="\033[38;2;168;118;146m"
C_GREEN="\033[38;2;140;210;140m"
C_YELLOW="\033[38;2;240;200;120m"
C_RED="\033[38;2;240;120;120m"

log_info() { echo -e "${C_PLUM}[Uninstall]${C_RESET} $1"; }
log_success() { echo -e "${C_GREEN}✓${C_RESET} $1"; }
log_warn() { echo -e "${C_YELLOW}⚠${C_RESET} $1"; }
log_error() { echo -e "${C_RED}✗${C_RESET} $1" >&2; }

BACKUP_DIR=""
AUTO_CONFIRM=false

show_help() {
  cat <<HELP
Usage: ./uninstall.sh [OPTIONS]

Options:
  -b, --backup <dir>   Specify an explicit backup directory to restore.
  -y, --yes            Do not prompt for confirmation before uninstalling.
  -h, --help           Show this help message.

HELP
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--backup)
      BACKUP_DIR="$2"
      shift 2
      ;;
    -y|--yes)
      AUTO_CONFIRM=true
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

if [[ "$AUTO_CONFIRM" == false ]]; then
  echo -e "${C_YELLOW}Are you sure you want to remove the Sakurazuki desktop customization? [y/N]${C_RESET} "
  read -r response
  if [[ ! "$response" =~ ^[yY]([eE][sS])?$ ]]; then
    log_info "Uninstallation cancelled."
    exit 0
  fi
fi

# Locate latest backup if not provided
if [[ -z "$BACKUP_DIR" ]]; then
  LATEST_BACKUP="$(find "${HOME}/.config/omarchy/backups" -maxdepth 1 -type d -name "sakurazuki_pre_install_*" 2>/dev/null | sort -r | head -n 1 || true)"
  if [[ -n "$LATEST_BACKUP" && -d "$LATEST_BACKUP" ]]; then
    BACKUP_DIR="$LATEST_BACKUP"
    log_info "Detected latest pre-install backup: $BACKUP_DIR"
  fi
fi

if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
  log_info "Restoring files from backup: $BACKUP_DIR..."
  cp -rP "${BACKUP_DIR}"/* "${HOME}/" 2>/dev/null || true
  log_success "Files restored from backup."
else
  log_warn "No pre-install backup directory found. Removing Sakurazuki files manually..."

  # Remove custom plugins
  for p in michal.workspaces michal.center-island michal.system-island michal.menu michal.lock; do
    rm -rf "${HOME}/.config/omarchy/plugins/${p}"
    log_info "Removed plugin: ${p}"
  done

  # Remove screensaver overrides
  rm -f "${HOME}/.local/bin/omarchy-launch-screensaver" "${HOME}/.local/bin/omarchy-screensaver"
  rm -rf "${HOME}/.config/omarchy/foot"
  rm -f "${HOME}/.config/omarchy/assets/Screensaver.png"

  # Revert shell.json if present
  if [[ -f "${HOME}/.config/omarchy/shell.json.bak" ]]; then
    mv "${HOME}/.config/omarchy/shell.json.bak" "${HOME}/.config/omarchy/shell.json"
    log_info "Restored shell.json.bak"
  fi
fi

# Update icon cache
if [[ -d "${HOME}/.local/share/icons/Sakurazuki" ]]; then
  rm -rf "${HOME}/.local/share/icons/Sakurazuki"
  log_info "Removed Sakurazuki icon theme."
fi

# Refresh shell
if command -v omarchy-shell &>/dev/null; then
  omarchy-shell shell ping 2>/dev/null || true
fi

log_success "Sakurazuki uninstalled."
