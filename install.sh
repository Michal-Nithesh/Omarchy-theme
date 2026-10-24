#!/usr/bin/env bash
# ==============================================================================
#  Michal × Sakurazuki — Installer Script
#  A polished Japanese cherry blossom aesthetic for Omarchy Linux + Hyprland
# ==============================================================================

set -euo pipefail

# Visual identity colors for terminal output
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_SAKURA="\033[38;2;217;166;196m" # #D9A6C4
C_PLUM="\033[38;2;168;118;146m"   # #A87692
C_LAVENDER="\033[38;2;194;174;223m" # #C2AEDF
C_GREEN="\033[38;2;140;210;140m"
C_YELLOW="\033[38;2;240;200;120m"
C_RED="\033[38;2;240;120;120m"

log_info() {
  echo -e "${C_LAVENDER}🌸 [Sakurazuki]${C_RESET} $1"
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
BACKUP_DIR="${HOME}/.config/omarchy/backups/sakurazuki_pre_install_${TIMESTAMP}"

# ------------------------------------------------------------------------------
# Banner
# ------------------------------------------------------------------------------
echo -e "${C_SAKURA}"
cat << "BANNER"
  ____             _                               _     _ 
 / ___|  __ _     | |  _   _   _ __    __ _   ____| |  | | _ 
 \___ \ / _` |    | | / / | | | '__|  / _` | |_  /| |  | |/ /
  ___) | (_| | _  | |< <  | | | |    | (_| |  / / | |_ |   < 
 |____/ \__,_|(_) |_| \_\ \__,_|_|     \__,_| /___|  \__|_|\_\
                Michal × Sakurazuki Desktop
BANNER
echo -e "${C_RESET}"
log_info "Starting Sakurazuki installation..."

# ------------------------------------------------------------------------------
# Prerequisites Check
# ------------------------------------------------------------------------------
log_info "Verifying dependencies..."
MISSING_DEPS=()
for dep in hyprland quickshell grim slurp python3; do
  if ! command -v "$dep" &>/dev/null; then
    MISSING_DEPS+=("$dep")
  fi
done

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
  log_warn "Some dependencies are missing: ${MISSING_DEPS[*]}"
  log_warn "The theme will still install, but runtime features may need these packages."
fi

# ------------------------------------------------------------------------------
# Backup function
# ------------------------------------------------------------------------------
backup_item() {
  local target="$1"
  if [[ -e "$target" && "$NO_BACKUP" == false ]]; then
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
    echo -e "  ${C_PLUM}[DRY-RUN]${C_RESET} Would copy: $src -> $dst"
    return 0
  fi

  backup_item "$dst"
  mkdir -p "$(dirname "$dst")"
  cp -r "$src" "$dst"
  log_success "Deployed: $dst"
}

# ------------------------------------------------------------------------------
# 1. Deploy Omarchy Plugins
# ------------------------------------------------------------------------------
log_info "Deploying Quickshell plugins..."
PLUGINS_SRC="${SCRIPT_DIR}/config/omarchy/plugins"
PLUGINS_DST="${HOME}/.config/omarchy/plugins"

for plugin in michal.workspaces michal.center-island michal.system-island michal.menu michal.lock; do
  if [[ -d "${PLUGINS_SRC}/${plugin}" ]]; then
    copy_safe "${PLUGINS_SRC}/${plugin}" "${PLUGINS_DST}/${plugin}"
  fi
done

# ------------------------------------------------------------------------------
# 2. Deploy Extensions & Shell Configuration
# ------------------------------------------------------------------------------
log_info "Deploying shell layout & menu extensions..."
copy_safe "${SCRIPT_DIR}/config/omarchy/extensions/omarchy-menu.jsonc" "${HOME}/.config/omarchy/extensions/omarchy-menu.jsonc"
copy_safe "${SCRIPT_DIR}/config/omarchy/shell.json" "${HOME}/.config/omarchy/shell.json"

if [[ -f "${SCRIPT_DIR}/config/omarchy/branding/about.txt" ]]; then
  copy_safe "${SCRIPT_DIR}/config/omarchy/branding/about.txt" "${HOME}/.config/omarchy/branding/about.txt"
fi

# ------------------------------------------------------------------------------
# 3. Deploy Sakurazuki Theme
# ------------------------------------------------------------------------------
log_info "Deploying Sakurazuki theme files..."
THEME_SRC="${SCRIPT_DIR}/config/omarchy/themes/sakurazuki"
THEME_DST="${HOME}/.config/omarchy/themes/sakurazuki"
copy_safe "$THEME_SRC" "$THEME_DST"

# ------------------------------------------------------------------------------
# 4. Deploy Assets (Wallpapers, Avatars, Icons)
# ------------------------------------------------------------------------------
log_info "Deploying assets, wallpapers, and icons..."
mkdir -p "${HOME}/.config/omarchy/assets"
mkdir -p "${HOME}/.config/omarchy/themes/sakurazuki/backgrounds"
mkdir -p "${HOME}/.local/share/icons"

if [[ -d "${SCRIPT_DIR}/assets/wallpapers" ]]; then
  for wp in "${SCRIPT_DIR}/assets/wallpapers"/*; do
    if [[ -f "$wp" ]]; then
      copy_safe "$wp" "${HOME}/.config/omarchy/themes/sakurazuki/backgrounds/$(basename "$wp")"
    fi
  done
fi

if [[ -d "${SCRIPT_DIR}/assets/avatars" ]]; then
  for av in "${SCRIPT_DIR}/assets/avatars"/*; do
    if [[ -f "$av" ]]; then
      copy_safe "$av" "${HOME}/.config/omarchy/assets/$(basename "$av")"
    fi
  done
fi

if [[ -d "${SCRIPT_DIR}/assets/icons/Sakurazuki" ]]; then
  copy_safe "${SCRIPT_DIR}/assets/icons/Sakurazuki" "${HOME}/.local/share/icons/Sakurazuki"
  if command -v gtk-update-icon-cache &>/dev/null; then
    gtk-update-icon-cache -q -t -f "${HOME}/.local/share/icons/Sakurazuki" 2>/dev/null || true
  fi
fi

# ------------------------------------------------------------------------------
# 5. Deploy Hyprland Configuration Overrides
# ------------------------------------------------------------------------------
log_info "Deploying Hyprland look & feel and bindings..."
HYPR_SRC="${SCRIPT_DIR}/config/hypr"
HYPR_DST="${HOME}/.config/hypr"

for hf in looknfeel.conf hyprlock.conf autostart.conf bindings.conf; do
  if [[ -f "${HYPR_SRC}/${hf}" ]]; then
    copy_safe "${HYPR_SRC}/${hf}" "${HYPR_DST}/${hf}"
  fi
done

# ------------------------------------------------------------------------------
# 6. Deploy Terminal Configuration (Ghostty & Foot Screensaver)
# ------------------------------------------------------------------------------
if [[ -f "${SCRIPT_DIR}/config/ghostty/config" ]]; then
  log_info "Deploying Ghostty terminal styling..."
  copy_safe "${SCRIPT_DIR}/config/ghostty/config" "${HOME}/.config/ghostty/config"
fi

if [[ -f "${SCRIPT_DIR}/config/omarchy/foot/screensaver.ini" ]]; then
  log_info "Deploying screensaver terminal styling..."
  copy_safe "${SCRIPT_DIR}/config/omarchy/foot/screensaver.ini" "${HOME}/.config/omarchy/foot/screensaver.ini"
fi

# ------------------------------------------------------------------------------
# 6.1. Deploy Screensaver Assets & Binaries
# ------------------------------------------------------------------------------
if [[ -f "${SCRIPT_DIR}/assets/wallpapers/Screensaver.png" ]]; then
  log_info "Deploying screensaver ambient background asset..."
  copy_safe "${SCRIPT_DIR}/assets/wallpapers/Screensaver.png" "${HOME}/.config/omarchy/assets/Screensaver.png"
fi

if [[ -d "${SCRIPT_DIR}/bin" ]]; then
  log_info "Deploying custom screensaver scripts to ~/.local/bin..."
  mkdir -p "${HOME}/.local/bin"
  for bf in "${SCRIPT_DIR}/bin"/*; do
    if [[ -f "$bf" ]]; then
      copy_safe "$bf" "${HOME}/.local/bin/$(basename "$bf")"
      chmod +x "${HOME}/.local/bin/$(basename "$bf")" 2>/dev/null || true
    fi
  done
fi

# ------------------------------------------------------------------------------
# 7. Apply Theme & Reload Shell
# ------------------------------------------------------------------------------
if [[ "$DRY_RUN" == false ]]; then
  log_info "Refreshing Omarchy shell and theme..."
  if command -v omarchy-shell &>/dev/null; then
    omarchy-shell shell call omarchy.menu refresh "{}" 2>/dev/null || true
  fi
  if command -v omarchy-menu &>/dev/null; then
    omarchy-menu refresh 2>/dev/null || true
  fi
  if command -v omarchy &>/dev/null; then
    omarchy theme set sakurazuki 2>/dev/null || true
  fi
  log_success "Sakurazuki desktop theme installed successfully!"
  if [[ "$NO_BACKUP" == false ]]; then
    log_info "Original configuration backups saved in: $BACKUP_DIR"
  fi
else
  log_info "Dry run complete. No modifications were written to disk."
fi
