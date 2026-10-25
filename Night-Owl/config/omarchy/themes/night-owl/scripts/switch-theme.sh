#!/usr/bin/env bash
# ==============================================================================
#  Omarchy Theme Switcher Helper (Sakurazuki <-> Night Owl)
# ==============================================================================

set -euo pipefail

usage() {
  cat <<HELP
Usage: $0 [sakurazuki | night-owl | current]

Options:
  sakurazuki   Switch to the Sakurazuki desktop theme (Kanji workspaces, sakura accents)
  night-owl    Switch to the Night Owl desktop theme (01..10 workspaces, teal accents)
  current      Display the currently active theme

HELP
  exit 0
}

TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
  usage
fi

case "$TARGET" in
  "current"|"status")
    CURRENT=$(omarchy theme current 2>/dev/null || cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || echo "Unknown")
    echo "Currently active theme: $CURRENT"
    exit 0
    ;;
  "sakurazuki"|"Sakurazuki")
    echo "🌸 Switching to Sakurazuki theme..."
    omarchy theme set sakurazuki
    echo "✓ Sakurazuki theme applied successfully!"
    ;;
  "night-owl"|"nightowl"|"Night Owl")
    echo "🦉 Switching to Night Owl theme..."
    omarchy theme set night-owl
    echo "✓ Night Owl theme applied successfully!"
    ;;
  *)
    echo "Error: Unknown theme '$TARGET'." >&2
    usage
    ;;
esac
