# Sakurazuki Desktop Theme Architecture

This document details the architectural design and system integration of the **Sakurazuki** desktop environment for **Omarchy Linux** and **Hyprland**.

---

## 1. Architectural Philosophy

The Sakurazuki desktop theme is designed according to three fundamental principles:

1. **Self-Contained Autonomy**: The theme is completely modular and self-contained within `Sakurazuki/`, containing its own configuration files, custom Quickshell plugins, assets, utilities, installer, and uninstaller.
2. **Native Omarchy Integration**: Sakurazuki leverages Omarchy's first-party extension and plugin framework (`~/.config/omarchy/plugins/`, `~/.config/omarchy/themes/sakurazuki/`) and Hyprland configuration overrides (`~/.config/hypr/`).
3. **Safe Deployment & Clean Rollback**: The installation scripts check for existing configurations and create timestamped backups in `~/.config/omarchy/backups/` before deploying. The uninstaller removes only Sakurazuki-managed files and restores previous backups.

---

## 2. Directory Hierarchy

```
Omarchy-theme/
├── README.md                            <-- Repository showcase & quick start
├── LICENSE                              <-- MIT License
├── .gitignore                           <-- Git repository ignore patterns
│
├── docs/                                <-- Architectural and installation documentation
│   ├── architecture.md                  <-- System design & integration (this file)
│   └── installation.md                  <-- Setup, deployment & uninstallation guide
│
└── Sakurazuki/                          <-- Sakurazuki Desktop Distribution
    ├── README.md                        <-- Detailed theme showcase & features
    ├── install.sh                       <-- Autonomous installer with backup support
    ├── uninstall.sh                     <-- Autonomous uninstaller with rollback
    ├── bin/                             <-- Screensaver & wake utility scripts
    │   ├── omarchy-launch-screensaver   <-- Screensaver workspace & overlay launcher
    │   ├── omarchy-screensaver          <-- Ambient terminal animation runner
    │   └── omarchy-system-wake          <-- Screen wake & bar recovery handler
    ├── assets/                          <-- Theme assets
    │   ├── avatars/                     <-- User profile avatars
    │   ├── icons/                       <-- Custom Sakurazuki SVG folder icon pack
    │   └── wallpapers/                  <-- High-resolution theme wallpapers
    ├── config/                          <-- Turnkey application and desktop configurations
    │   ├── ghostty/                     <-- Ghostty terminal styling
    │   ├── hypr/                        <-- Hyprland look & feel, bindings, rules
    │   └── omarchy/                     <-- Quickshell plugins, shell.json, theme tokens
    │       ├── branding/                <-- Menu branding and about metadata
    │       ├── extensions/              <-- Menu extensions (omarchy-menu.jsonc)
    │       ├── foot/                    <-- Foot screensaver terminal configuration
    │       ├── plugins/                 <-- michal.* Quickshell plugins
    │       │   ├── michal.bar/          <-- Main status bar
    │       │   ├── michal.center-island <-- Center clock, weather & controls
    │       │   ├── michal.lock/         <-- Lock screen
    │       │   ├── michal.menu/         <-- 10-category application launcher
    │       │   ├── michal.system-island <-- Hardware monitors & status island
    │       │   └── michal.workspaces/   <-- Kanji numerals (一 二 三 四 五 六)
    │       ├── shell.json               <-- Shell layout and widget definitions
    │       └── themes/sakurazuki/       <-- Theme palette & app config templates
    ├── docs/                            <-- Inventory, customization & troubleshooting
    └── screenshots/                     <-- Desktop captures & visual documentation
```

---

## 3. Component Breakdown

### 3.1. Desktop Interface & Quickshell Plugins
Sakurazuki implements its top bar and interactive islands using **Quickshell** (QML):
- **`michal.bar`**: The primary floating top bar hosting status widgets, tray, and island anchors.
- **`michal.workspaces`**: Traditional Japanese Kanji numerals (`一 二 三 四 五 六`) for workspace representation, with smooth active indicator states.
- **`michal.center-island`**: Floating center island housing the digital clock, calendar, weather widget, and quick utility controls.
- **`michal.system-island`**: Dedicated system telemetry island tracking CPU, memory, network, audio, and battery state.
- **`michal.menu`**: Custom 10-category application and system controls launcher.
- **`michal.lock`**: High-contrast lock screen with ambient background blur and clean credential input.

### 3.2. Window Management (Hyprland)
- **Look & Feel**: Defined in `looknfeel.conf` and `looknfeel.lua`.
  - Active borders: Sakura rose to blossom pink gradient (`rgba(a87692ee) rgba(d9a6c4ee) 45deg`).
  - Inactive borders: Frosted plum container borders (`rgba(443043aa)`).
  - Rounding: `14px` border radius with customized ambient shadows.
- **Bindings**: Quick application hotkeys in `bindings.conf` (browser, terminal, editor, Mission Control window switcher).

### 3.3. Ambient Screensaver
- **`omarchy-launch-screensaver`**: Moves to an empty dedicated workspace with instantaneous transitions, hides the status bar, and spawns the screensaver window.
- **`omarchy-screensaver`**: Runs terminal visual animations (`ttfx`) with the Sakurazuki color spectrum (`#D9A6C4`, `#A87692`, `#443043`, `#C2AEDF`) over `Screensaver.png`. Dismisses seamlessly on user input.

### 3.4. Sleep & Wake Recovery
- **`omarchy-system-wake`**: Ensures that upon resume from sleep or screen unlock, screensaver flags are cleaned up and the Quickshell status bar (`michal.bar`) is synced and visible immediately.

### 3.5. Application Theming
The theme bundle in `config/omarchy/themes/sakurazuki/` provides styling across:
- **Terminals**: Ghostty, Foot, Alacritty, Kitty
- **Editors**: Neovim, VSCode
- **System Tools**: Btop, Mako, SwayOSD, Walker, Wofi, Chromium, Vencord/Discord

---

## 4. Security & Stability Guarantees

- **Pre-Install Backups**: The installer checks for existing configuration files and creates timestamped backups in `~/.config/omarchy/backups/sakurazuki_pre_install_<timestamp>` before making changes.
- **Dry-Run Inspection**: The `./install.sh --dry-run` flag lets users inspect every planned file copy before committing any changes to disk.
- **Clean Uninstallation**: Running `./uninstall.sh` removes Sakurazuki's custom plugins, scripts, and theme files, then restores the original pre-install configuration.
