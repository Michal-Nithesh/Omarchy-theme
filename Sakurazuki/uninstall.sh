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
C_LAVENDER="\033[38;2;194;174;223m"
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

# Function to detect if a backup directory contains Sakurazuki artifacts
# (e.g. created on a system that already had Sakurazuki installed)
is_clean_backup() {
  local dir="$1"
  [[ -d "$dir" ]] || return 1
  if [[ -d "$dir/.config/omarchy/themes/sakurazuki" ]] || \
     [[ -d "$dir/.config/omarchy/plugins/michal.menu" ]] || \
     [[ -d "$dir/.config/omarchy/plugins/michal.bar" ]] || \
     [[ -d "$dir/.config/omarchy/plugins/michal.system-island" ]] || \
     [[ -f "$dir/.local/bin/omarchy-launch-screensaver" ]]; then
    return 1 # Contains Sakurazuki files from a re-install
  fi
  return 0 # Clean pre-install backup
}

# Locate backup if not explicitly provided
if [[ -z "$BACKUP_DIR" ]]; then
  BACKUP_LIST=()
  if [[ -d "${HOME}/.config/omarchy/backups" ]]; then
    while IFS= read -r b; do
      [[ -n "$b" && -d "$b" ]] && BACKUP_LIST+=("$b")
    done < <(find "${HOME}/.config/omarchy/backups" -maxdepth 1 -type d -name "sakurazuki_pre_install_*" 2>/dev/null | sort)

    # If no pre-install backups were found, also check for any reinstall backups
    if [[ ${#BACKUP_LIST[@]} -eq 0 ]]; then
      while IFS= read -r b; do
        [[ -n "$b" && -d "$b" ]] && BACKUP_LIST+=("$b")
      done < <(find "${HOME}/.config/omarchy/backups" -maxdepth 1 -type d -name "sakurazuki_reinstall_*" 2>/dev/null | sort)
    fi
  fi

  if [[ ${#BACKUP_LIST[@]} -eq 1 ]]; then
    BACKUP_DIR="${BACKUP_LIST[0]}"
    log_info "Detected pre-install backup: $(basename "$BACKUP_DIR")"
  elif [[ ${#BACKUP_LIST[@]} -gt 1 ]]; then
    # Multiple backups found (e.g. from running install multiple times)
    # Identify the best candidate (oldest clean backup, or oldest backup overall)
    RECOMMENDED_INDEX=0
    for i in "${!BACKUP_LIST[@]}"; do
      if is_clean_backup "${BACKUP_LIST[$i]}"; then
        RECOMMENDED_INDEX="$i"
        break
      fi
    done

    if [[ "$AUTO_CONFIRM" == true ]]; then
      BACKUP_DIR="${BACKUP_LIST[$RECOMMENDED_INDEX]}"
      log_info "Detected multiple backups (${#BACKUP_LIST[@]}). Automatically selecting original pre-install backup:"
      log_info "  -> $(basename "$BACKUP_DIR")"
    else
      echo -e "\n${C_LAVENDER}Multiple backups were found in ~/.config/omarchy/backups/:${C_RESET}"
      for i in "${!BACKUP_LIST[@]}"; do
        b="${BACKUP_LIST[$i]}"
        b_name="$(basename "$b")"
        tag=""
        if is_clean_backup "$b"; then
          tag="${C_GREEN}[Original clean backup]${C_RESET}"
        else
          tag="${C_YELLOW}[Contains Sakurazuki files from re-install]${C_RESET}"
        fi
        if [[ "$i" -eq "$RECOMMENDED_INDEX" ]]; then
          echo -e "  $((i+1))) ${b_name} ${tag} ${C_BOLD}${C_SAKURA}(Recommended)${C_RESET}"
        else
          echo -e "  $((i+1))) ${b_name} ${tag}"
        fi
      done

      echo -ne "\n${C_YELLOW}Select backup to restore [1-${#BACKUP_LIST[@]}, default: $((RECOMMENDED_INDEX+1))]: ${C_RESET}"
      read -r choice
      choice="${choice:-$((RECOMMENDED_INDEX+1))}"
      if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#BACKUP_LIST[@]} )); then
        BACKUP_DIR="${BACKUP_LIST[$((choice-1))]}"
      else
        log_warn "Invalid selection. Defaulting to recommended backup: $(basename "${BACKUP_LIST[$RECOMMENDED_INDEX]}")"
        BACKUP_DIR="${BACKUP_LIST[$RECOMMENDED_INDEX]}"
      fi
      log_info "Selected backup: $(basename "$BACKUP_DIR")"
    fi
  fi
else
  if [[ ! -d "$BACKUP_DIR" ]]; then
    log_error "Specified backup directory does not exist: $BACKUP_DIR"
    exit 1
  fi
fi

# ------------------------------------------------------------------------------
# 1. Restore configuration from backup
# ------------------------------------------------------------------------------
if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
  log_info "Restoring files from backup: $BACKUP_DIR..."
  cp -a "${BACKUP_DIR}/." "${HOME}/"
  log_success "Files restored from backup."
else
  log_warn "No pre-install backup directory found."

  # Revert shell.json if a .bak is present
  if [[ -f "${HOME}/.config/omarchy/shell.json.bak" ]]; then
    mv "${HOME}/.config/omarchy/shell.json.bak" "${HOME}/.config/omarchy/shell.json"
    log_info "Restored shell.json.bak"
  fi
fi

# ------------------------------------------------------------------------------
# 2. Clean up Sakurazuki additions (prevent leaving orphaned files)
# ------------------------------------------------------------------------------
log_info "Cleaning up Sakurazuki theme files, plugins, and custom additions..."

# Remove custom plugins
for p in michal.workspaces michal.center-island michal.system-island michal.menu michal.lock michal.bar; do
  if [[ -d "${HOME}/.config/omarchy/plugins/${p}" ]]; then
    rm -rf "${HOME}/.config/omarchy/plugins/${p}"
    log_info "Removed plugin: ${p}"
  fi
done

# Remove Sakurazuki theme directory
if [[ -d "${HOME}/.config/omarchy/themes/sakurazuki" ]]; then
  rm -rf "${HOME}/.config/omarchy/themes/sakurazuki"
  log_info "Removed Sakurazuki theme directory."
fi

# Remove wallpapers and assets added by Sakurazuki
rm -f "${HOME}/.config/omarchy/assets/Screensaver.png"
rm -f "${HOME}/.config/omarchy/assets/avatar_sakurazuki.png"
rm -f "${HOME}/.config/omarchy/assets/luffy_square.png"

# Remove custom utility scripts in ~/.local/bin
rm -f "${HOME}/.local/bin/omarchy-launch-screensaver"
rm -f "${HOME}/.local/bin/omarchy-screensaver"
rm -f "${HOME}/.local/bin/omarchy-system-wake"

# Remove screensaver terminal styling
rm -f "${HOME}/.config/omarchy/foot/screensaver.ini"
rmdir "${HOME}/.config/omarchy/foot" 2>/dev/null || true

# Remove Sakurazuki icon theme
if [[ -d "${HOME}/.local/share/icons/Sakurazuki" ]]; then
  rm -rf "${HOME}/.local/share/icons/Sakurazuki"
  log_info "Removed Sakurazuki icon theme."
fi

# Clean up extensions and branding if they were introduced by Sakurazuki
# (if they exist in the backup, restoring the backup above already restored the user's pre-install versions)
if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
  if [[ ! -f "${BACKUP_DIR}/.config/omarchy/extensions/omarchy-menu.jsonc" ]]; then
    rm -f "${HOME}/.config/omarchy/extensions/omarchy-menu.jsonc"
  fi
  if [[ ! -f "${BACKUP_DIR}/.config/omarchy/branding/about.txt" ]]; then
    rm -f "${HOME}/.config/omarchy/branding/about.txt"
  fi
else
  rm -f "${HOME}/.config/omarchy/extensions/omarchy-menu.jsonc"
  rm -f "${HOME}/.config/omarchy/branding/about.txt"
fi

# ------------------------------------------------------------------------------
# 3. Revert active Omarchy theme if currently set to Sakurazuki
# ------------------------------------------------------------------------------
if [[ -f "${HOME}/.local/state/omarchy/current/theme.name" ]]; then
  CURRENT_THEME="$(cat "${HOME}/.local/state/omarchy/current/theme.name" 2>/dev/null || true)"
  if [[ "$CURRENT_THEME" == "sakurazuki" ]]; then
    log_info "Active theme is set to 'sakurazuki'. Reverting to default theme..."
    REVERTED_THEME=false
    for fallback in "Tokyo Night" "Catppuccin" "Aether" "Nord"; do
      if omarchy theme set "$fallback" 2>/dev/null; then
        log_success "Theme reverted to $fallback."
        REVERTED_THEME=true
        break
      fi
    done
    if [[ "$REVERTED_THEME" == false ]]; then
      log_warn "Could not automatically switch theme. Please run: omarchy theme set <theme>"
    fi
  fi
fi

# ------------------------------------------------------------------------------
# 4. Refresh icon cache and reload Omarchy shell
# ------------------------------------------------------------------------------
if command -v gtk-update-icon-cache &>/dev/null; then
  gtk-update-icon-cache -q -t -f "${HOME}/.local/share/icons" 2>/dev/null || true
fi

if command -v omarchy-restart-shell &>/dev/null; then
  log_info "Restarting Omarchy shell to apply restored configuration..."
  omarchy-restart-shell 2>/dev/null || true
elif command -v omarchy-shell &>/dev/null; then
  omarchy-shell shell rescanPlugins 2>/dev/null || omarchy-shell shell ping 2>/dev/null || true
fi

log_success "Sakurazuki uninstalled successfully."
