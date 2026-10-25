# Repository Migration Guide

This document explains the transition from the single-theme **Sakurazuki** repository into the unified **Omarchy Theme Collection** architecture.

---

## 1. Background & Motivation

Initially, the repository was structured as a standalone project dedicated exclusively to the **Sakurazuki** customization:
- Root files contained Sakurazuki configurations directly in `config/`, `assets/`, `install.sh`, and `uninstall.sh`.
- The repository was nested under `~/Projects/Sakurazuki/Sakurazuki/`.

To introduce **Night Owl** as an equal, first-class desktop environment without polluting or breaking Sakurazuki, the repository was restructured into a multi-theme parent distribution named **Omarchy**:

```
Legacy (Single Theme)                      Modern (Multi-Theme Collection)
---------------------                      -------------------------------
~/Projects/Sakurazuki/                     ~/Projects/Omarchy/
├── assets/                                ├── Sakurazuki/
├── config/                                │   ├── assets/
├── install.sh                             │   ├── config/
└── uninstall.sh                           │   ├── install.sh
                                           │   └── uninstall.sh
                                           ├── Night-Owl/
                                           │   ├── assets/
                                           │   ├── config/
                                           │   ├── install.sh
                                           │   └── uninstall.sh
                                           ├── docs/
                                           └── README.md
```

---

## 2. Backward Compatibility & Symlinks

To ensure zero breakage for existing user scripts, desktop aliases, and tool configurations that referenced legacy paths, standard filesystem compatibility links have been created:

| Legacy Path | Modern Target | Purpose |
|---|---|---|
| `~/sakurazuki` | `~/Projects/Omarchy/Sakurazuki` | Preserves direct access to Sakurazuki assets & scripts |
| `~/Projects/Sakurazuki` | `~/Projects/Omarchy` | Preserves developer bookmarks and terminal shortcuts |
| `~/Projects/Omarchy-Theme` | `~/Projects/Omarchy` | Preserves transitional branch references |

If your terminal or startup scripts execute commands such as:
```bash
cd ~/sakurazuki && ./install.sh
```
They will continue to function seamlessly without modification.

---

## 3. Migration Steps for Existing Users

If you previously installed Sakurazuki and wish to update to the modern multi-theme setup:

### Step 1: Navigate to the Collection Root
```bash
cd ~/Projects/Omarchy
```

### Step 2: Verify Existing Sakurazuki Installation
Run the Sakurazuki installer in dry-run mode to confirm that all existing components match the new repository structure:
```bash
cd ~/Projects/Omarchy/Sakurazuki
./install.sh --dry-run
```

### Step 3: Install the Night Owl Theme
Deploy the new Night Owl theme and the unified theme-switching hook:
```bash
cd ~/Projects/Omarchy/Night-Owl
./install.sh
```

### Step 4: Test Theme Switching
Verify that you can switch between both themes on the fly:
```bash
# Switch to Night Owl:
omarchy theme set night-owl

# Switch back to Sakurazuki:
omarchy theme set sakurazuki
```

---

## 4. Troubleshooting Post-Migration

### Missing Screensaver or Switcher Commands
If commands like `omarchy-theme-switch` or `omarchy-screensaver` are not found:
Ensure `~/.local/bin` is in your `$PATH`. You can verify by running:
```bash
echo $PATH | grep -q "$HOME/.local/bin" && echo "PATH is valid" || echo "Add ~/.local/bin to PATH"
```

### Hyprland Borders Not Changing on Theme Switch
If Hyprland borders appear fixed on one color palette:
Verify that `~/.config/omarchy/hooks/theme-set.d/omarchy-theme-switch.sh` is executable:
```bash
chmod +x ~/.config/omarchy/hooks/theme-set.d/omarchy-theme-switch.sh
```
This hook automatically calls `hyprctl keyword general:col.active_border` whenever `omarchy theme set <name>` is triggered.
