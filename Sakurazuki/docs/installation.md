# Installation Guide — Michal × Sakurazuki

This guide details the prerequisites, automatic installation, manual installation steps, and uninstallation procedure for the **Sakurazuki** desktop environment.

---

## Prerequisites

Sakurazuki is designed for **Omarchy Linux** running **Hyprland** and **Quickshell**.

Ensure the following core components are installed:

| Tool | Recommended Version | Purpose |
|---|---|---|
| **Omarchy Linux** | 4.0+ | Underlying OS base and shell infrastructure |
| **Hyprland** | 0.50+ | Wayland compositor and window manager |
| **Quickshell** | Latest | QML-based desktop shell runtime |
| **Python** | 3.10+ | Backend metrics provider for System Island |
| **Grim & Slurp** | Latest | Wayland screenshot utilities |
| **JetBrainsMono Nerd Font** | Latest | Primary UI and terminal typography |
| **Ghostty** | 1.1+ | Terminal emulator |

---

## Automated Installation

The fastest and safest way to deploy Sakurazuki is via `install.sh`:

```bash
git clone https://github.com/Michal-Nithesh/Sakurazuki.git
cd Sakurazuki
./install.sh
```

### Script Flags

- **Dry Run:** Test what files will be copied without making modifications:
  ```bash
  ./install.sh --dry-run
  ```
- **No Backup:** Skip generating timestamped backups in `~/.config/omarchy/backups`:
  ```bash
  ./install.sh --no-backup
  ```
- **Force:** Overwrite existing configurations without prompting:
  ```bash
  ./install.sh --force
  ```

---

## Manual Installation Steps

If you prefer deploying components individually:

### 1. Quickshell Plugins
Copy the 5 core Sakurazuki plugins to your Omarchy plugins directory:
```bash
cp -r config/omarchy/plugins/michal.* ~/.config/omarchy/plugins/
```

### 2. Shell Configuration & Extensions
Deploy the menu routes and shell configuration:
```bash
cp config/omarchy/extensions/omarchy-menu.jsonc ~/.config/omarchy/extensions/
cp config/omarchy/shell.json ~/.config/omarchy/shell.json
cp config/omarchy/branding/about.txt ~/.config/omarchy/branding/about.txt
```

### 3. Theme & Assets
Copy the theme stylesheet, wallpapers, and avatars:
```bash
cp -r config/omarchy/themes/sakurazuki ~/.config/omarchy/themes/
mkdir -p ~/.config/omarchy/assets
cp assets/avatars/* ~/.config/omarchy/assets/
mkdir -p ~/.config/omarchy/themes/sakurazuki/backgrounds
cp assets/wallpapers/* ~/.config/omarchy/themes/sakurazuki/backgrounds/
```

### 4. Icon Theme
Deploy the Sakurazuki folder and mimetype icons:
```bash
cp -r assets/icons/Sakurazuki ~/.local/share/icons/
gtk-update-icon-cache -q -t -f ~/.local/share/icons/Sakurazuki
```

### 5. Hyprland & Lock Screen
Deploy Hyprland look and feel:
```bash
cp config/hypr/looknfeel.conf ~/.config/hypr/looknfeel.conf
cp config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf
```

### 6. Reload Shell
Reload Quickshell and apply the theme:
```bash
omarchy-shell shell call omarchy.menu refresh "{}"
omarchy theme set sakurazuki
```

---

## Uninstallation & Reversion

To revert Sakurazuki and restore pre-existing configuration:

```bash
./uninstall.sh
```

The script automatically detects the pre-install backup created during initial installation, removes Sakurazuki-added components (custom plugins, theme directory, assets, icons, and screensaver scripts), and restores your original setup using `cp -a`. If multiple backups exist from previous re-installations, it intelligently selects and recommends the original pre-install backup.
