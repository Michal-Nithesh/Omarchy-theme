#!/usr/bin/env bash
# ==============================================================================
#  Omarchy Theme Switch Automation Hook
#  Seamlessly coordinates plugins, borders, and UI states between themes
# ==============================================================================

set -euo pipefail

THEME="${1:-}"

if [[ -z "$THEME" ]]; then
  exit 0
fi

THEME_NORMALIZED=$(echo "$THEME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
SHELL_CONFIG="$HOME/.config/omarchy/shell.json"

case "$THEME_NORMALIZED" in
  "night-owl")
    # 1. Switch Quickshell workspaces widget to Night Owl zero-padded numerals (01..10)
    if [[ -f "$SHELL_CONFIG" ]] && grep -q '"michal.workspaces"' "$SHELL_CONFIG"; then
      sed -i 's/"michal.workspaces"/"nightowl.workspaces"/g' "$SHELL_CONFIG"
    fi

    # 2. Update live Hyprland window borders to Night Owl cyan/blue gradient
    if command -v hyprctl &>/dev/null; then
      hyprctl keyword general:col.active_border "rgba(7fdbcaee) rgba(82aaffee) 45deg" 2>/dev/null || true
      hyprctl keyword general:col.inactive_border "rgba(1d3b53aa)" 2>/dev/null || true
      hyprctl keyword group:col.border_active "rgba(7fdbcaee) rgba(82aaffee) 45deg" 2>/dev/null || true
      hyprctl keyword group:col.border_inactive "rgba(1d3b53aa)" 2>/dev/null || true
    fi

    # 3. Set GNOME icon theme to Yaru-blue-dark
    if command -v gsettings &>/dev/null && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
      gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue-dark" 2>/dev/null || true
    fi
    ;;

  "sakurazuki")
    # 1. Restore Quickshell workspaces widget to Sakurazuki Kanji numerals (一..六)
    if [[ -f "$SHELL_CONFIG" ]] && grep -q '"nightowl.workspaces"' "$SHELL_CONFIG"; then
      sed -i 's/"nightowl.workspaces"/"michal.workspaces"/g' "$SHELL_CONFIG"
    fi

    # 2. Restore live Hyprland window borders to Sakurazuki sakura gradient
    if command -v hyprctl &>/dev/null; then
      hyprctl keyword general:col.active_border "rgba(a87692ee) rgba(d9a6c4ee) 45deg" 2>/dev/null || true
      hyprctl keyword general:col.inactive_border "rgba(443043aa)" 2>/dev/null || true
      hyprctl keyword group:col.border_active "rgba(a87692ee) rgba(d9a6c4ee) 45deg" 2>/dev/null || true
      hyprctl keyword group:col.border_inactive "rgba(443043aa)" 2>/dev/null || true
    fi

    # 3. Restore GNOME icon theme to Sakurazuki
    if command -v gsettings &>/dev/null && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
      gsettings set org.gnome.desktop.interface icon-theme "Sakurazuki" 2>/dev/null || true
    fi
    ;;
esac
