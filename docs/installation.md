# Installation and Switching Guide

This guide covers installing, configuring, switching, and uninstalling the **Sakurazuki** and **Night Owl** desktop environments from the Omarchy Theme Collection.

---

## 1. System Requirements

The Omarchy Theme Collection targets **Arch Linux** running **Omarchy Linux (v4.0.0+)** with Hyprland and Quickshell.

### Required Software Packages:
- **Hyprland** (Wayland compositor)
- **Quickshell** / `omarchy-shell` (Desktop widget system, status bar, and islands)
- **Waybar** (Alternative or fallback status bar)
- **Ghostty** or **Foot** (Terminal emulators)
- **Hyprlock** & **Hypridle** (Screen locking and idle management)
- **Mako** or **SwayOSD** (Notifications and on-screen displays)
- **Python 3** (Scripting, backend islands, and palette processing)

---

## 2. Installing Night Owl

The Night Owl distribution is self-contained in `Night-Owl/`.

### 2.1. Inspect Installation (Dry Run)
Before modifying your system, run a dry run to verify the planned actions:
```bash
cd ~/Projects/Omarchy/Night-Owl
./install.sh --dry-run
```

### 2.2. Perform Installation
To install the theme, wallpapers, Quickshell workspace plugin, and switching hooks:
```bash
cd ~/Projects/Omarchy/Night-Owl
./install.sh
```

### 2.3. Installer Flags
| Flag | Description |
|---|---|
| `-d`, `--dry-run` | Show simulated deployment operations without writing files to disk |
| `-t`, `--theme-only` | Install only the theme files to `~/.config/omarchy/themes/night-owl` without modifying shell layouts |
| `-n`, `--no-backup` | Skip creating backup copies of existing configuration files |
| `-h`, `--help` | Display usage instructions and available options |

---

## 3. Installing Sakurazuki

Sakurazuki is self-contained in `Sakurazuki/`.

### 3.1. Inspect Installation (Dry Run)
```bash
cd ~/Projects/Omarchy/Sakurazuki
./install.sh --dry-run
```

### 3.2. Perform Installation
To install the full Japanese cherry blossom desktop (all Quickshell plugins, screensaver, wallpapers, and custom icon pack):
```bash
cd ~/Projects/Omarchy/Sakurazuki
./install.sh
```

### 3.3. Installer Flags
| Flag | Description |
|---|---|
| `-d`, `--dry-run` | Show simulated deployment operations without writing files to disk |
| `-t`, `--theme-only` | Install only the `sakurazuki` theme directory |
| `-n`, `--no-backup` | Skip configuration backups in `~/.config/omarchy/backups/` |
| `-h`, `--help` | Display help options |

---

## 4. Switching Between Themes

Once both themes are installed, switching between them is completely seamless and reversible. You can switch themes using any of three methods:

### Method A: Native Omarchy CLI (Recommended)
Switch directly using the built-in Omarchy command:
```bash
# Switch to Night Owl (01-10 numerals, #011627 navy, #7FDBCA teal borders)
omarchy theme set night-owl

# Switch to Sakurazuki (一-六 Kanji, #14111A dark, #FFB7C5 sakura borders)
omarchy theme set sakurazuki
```

### Method B: Dedicated Switcher Binary
The collection provides a helper binary installed to `~/.local/bin/omarchy-theme-switch`:
```bash
# Direct switch:
omarchy-theme-switch night-owl
omarchy-theme-switch sakurazuki

# Interactive selector:
omarchy-theme-switch
```

### Method C: Graphical Desktop Menu
1. Press `Super` or click the launcher button (`🌸` or `🦉`) on the left of the top bar.
2. Navigate to **Appearance** -> **Themes**.
3. Select **Night Owl** or **Sakurazuki**.
4. The desktop transitions instantly without requiring a logout or restart.

---

## 5. Post-Installation Verification

To ensure your installation is operating without errors, run these validation commands:

1. **Verify Hyprland Configuration**:
   ```bash
   hyprctl configerrors
   ```
   *(Expected output: empty, 0 errors)*

2. **Verify Theme Token Parsing**:
   ```bash
   omarchy-theme-color --file ~/.config/omarchy/themes/night-owl/colors.toml --all
   omarchy-theme-color --file ~/.config/omarchy/themes/sakurazuki/colors.toml --all
   ```
   *(Expected output: all 54 color tokens parsed successfully)*

3. **Verify Quickshell Plugins**:
   Check that both workspace plugins are registered:
   ```bash
   ls ~/.config/omarchy/plugins/nightowl.workspaces
   ls ~/.config/omarchy/plugins/michal.workspaces
   ```

---

## 6. Uninstallation

If you wish to remove either theme without affecting the other:

### 6.1. Uninstall Night Owl
```bash
cd ~/Projects/Omarchy/Night-Owl
./uninstall.sh
```
*Removes `~/.config/omarchy/themes/night-owl` and `~/.config/omarchy/plugins/nightowl.workspaces`.*

### 6.2. Uninstall Sakurazuki
```bash
cd ~/Projects/Omarchy/Sakurazuki
./uninstall.sh --yes
```
*Restores the previous configuration from backup or removes Sakurazuki-specific assets.*
