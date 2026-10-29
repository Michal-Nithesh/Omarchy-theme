# Installation & Setup Guide

This guide covers installing, configuring, and uninstalling the **Sakurazuki** desktop environment on **Omarchy Linux** and **Hyprland**.

---

## 1. System Requirements

Sakurazuki is designed for **Arch Linux** running **Omarchy Linux (v4.0.0+)** with Hyprland and Quickshell.

### Required Packages:
- **Hyprland** (Wayland compositor)
- **Quickshell** / `omarchy-shell` (Desktop status bar, widgets, and floating islands)
- **Ghostty** or **Foot** (Terminal emulators)
- **Hyprlock** (Screen locking)
- **Python 3** (Backend data provider for system island telemetry)
- **Grim** & **Slurp** (Screen capture utilities)
- **ttfx** (Optional, for terminal screensaver animations)

---

## 2. Installation

The Sakurazuki distribution is self-contained within `Sakurazuki/`.

### 2.1. Inspect Installation (Dry Run)
Before modifying your system, run a dry run to verify all planned file operations:
```bash
cd ~/Projects/Omarchy/Sakurazuki
./install.sh --dry-run
```

### 2.2. Perform Installation
To install the full theme (Quickshell plugins, wallpapers, custom icon pack, terminal configs, and screensaver scripts):
```bash
cd ~/Projects/Omarchy/Sakurazuki
./install.sh
```

### 2.3. Installer Flags
| Flag | Description |
|---|---|
| `-d`, `--dry-run` | Show simulated deployment operations without writing files to disk |
| `--no-backup` | Skip creating backup copies of existing configuration files |
| `-f`, `--force` | Overwrite existing configuration files without prompting |
| `-h`, `--help` | Display usage instructions and options |

---

## 3. Activation

The installer automatically activates Sakurazuki upon completion. To re-apply or activate Sakurazuki manually at any time, run:
```bash
omarchy theme set sakurazuki
```

---

## 4. Uninstallation & Rollback

To revert your desktop back to its original state and restore pre-install configuration backups:
```bash
cd ~/Projects/Omarchy/Sakurazuki
./uninstall.sh
```

### Uninstaller Options:
| Option | Description |
|---|---|
| `-b`, `--backup <dir>` | Specify an explicit backup directory to restore |
| `-y`, `--yes` | Skip the confirmation prompt |
| `-h`, `--help` | Display help options |

The uninstaller removes Sakurazuki's custom plugins (`michal.*`), screensaver scripts, wallpapers, icon pack, and theme directory, and cleanly restores the pre-install backup saved in `~/.config/omarchy/backups/`.

---

## 5. Verification & Troubleshooting

### Check Active Plugins
Verify that Sakurazuki's custom plugins are loaded in Quickshell:
```bash
omarchy-shell shell listPlugins | grep -E "michal\."
```
You should see:
- `michal.bar`
- `michal.center-island`
- `michal.system-island`
- `michal.workspaces`
- `michal.menu`
- `michal.lock`

### Refresh the Desktop Shell
If any widget needs a refresh:
```bash
omarchy restart shell
```

### Reload Hyprland
To reload Hyprland window rules and appearance:
```bash
hyprctl reload
```
