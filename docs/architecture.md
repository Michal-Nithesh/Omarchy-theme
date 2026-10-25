# Omarchy Theme Collection Architecture

This document details the architectural design and structural separation of the **Omarchy Theme Collection** repository, housing both the **Sakurazuki** and **Night Owl** desktop environments.

---

## 1. Architectural Philosophy

The Omarchy theme collection is designed according to three fundamental principles:

1. **Complete Autonomy**: Each child sub-project (`Sakurazuki/` and `Night-Owl/`) is a fully functional, self-contained distribution containing its own configuration files, assets, plugins, installer, uninstaller, and documentation.
2. **Zero Intersite Pollution**: Neither theme depends on files located in the sibling theme's directory. Installing or uninstalling one theme does not alter or break the assets or configurations of the other.
3. **Seamless Coexistence**: Both themes install side-by-side into the Omarchy Linux desktop ecosystem (`~/.config/omarchy/themes/`, `~/.config/omarchy/plugins/`), and users can switch dynamically between them without configuration conflicts or manual intervention.

---

## 2. Directory Hierarchy

```
Omarchy/                                 <-- Parent Collection Root
├── README.md                            <-- Top-level showcase and quickstart
├── LICENSE                              <-- MIT License
├── .gitignore                           <-- Git repository ignore patterns
│
├── docs/                                <-- Collection-wide Architecture & Specs
│   ├── architecture.md                  <-- System design & integration (this file)
│   ├── installation.md                  <-- Unified installation & switching guide
│   ├── theme-comparison.md              <-- Deep side-by-side feature matrix
│   └── migration.md                     <-- Migration from legacy single-theme repo
│
├── Sakurazuki/                          <-- Sakurazuki Desktop Distribution
│   ├── README.md                        <-- Sakurazuki documentation & features
│   ├── install.sh                       <-- Autonomous installer
│   ├── uninstall.sh                     <-- Autonomous uninstaller
│   ├── bin/                             <-- Executables (screensaver, switcher)
│   ├── assets/                          <-- Wallpapers, icons, avatars
│   ├── config/                          <-- Configurations (Ghostty, Hypr, Omarchy)
│   │   ├── ghostty/
│   │   ├── hypr/
│   │   └── omarchy/
│   │       ├── branding/
│   │       ├── extensions/
│   │       ├── foot/
│   │       ├── plugins/                 <-- michal.* Quickshell plugins
│   │       ├── shell.json               <-- Sakurazuki shell layout definition
│   │       └── themes/sakurazuki/       <-- Theme tokens & application templates
│   ├── docs/                            <-- Sakurazuki component docs & audits
│   └── screenshots/                     <-- Desktop captures
│
└── Night-Owl/                           <-- Night Owl Desktop Distribution
    ├── README.md                        <-- Night Owl documentation & features
    ├── install.sh                       <-- Autonomous installer
    ├── uninstall.sh                     <-- Autonomous uninstaller
    ├── bin/                             <-- Executables (switcher binary)
    ├── assets/                          <-- Generated SVG/PNG wallpapers & preview
    ├── config/                          <-- Configurations (Ghostty, Hypr, Omarchy)
    │   ├── ghostty/
    │   ├── hypr/
    │   └── omarchy/
    │       ├── branding/
    │       ├── extensions/
    │       ├── plugins/                 <-- nightowl.workspaces plugin
    │       ├── shell.json               <-- Night Owl shell layout definition
    │       └── themes/night-owl/        <-- Theme tokens & application templates
    ├── docs/                            <-- Night Owl palette & implementation docs
    └── screenshots/                     <-- Desktop captures & visual preview
```

---

## 3. Component Breakdown & Boundaries

### 3.1. Sub-Project Independence
- **Sakurazuki** (`Sakurazuki/`):
  - Retains all original Japanese cherry blossom aesthetic configurations.
  - Deploys custom Quickshell plugins: `michal.bar`, `michal.center-island`, `michal.lock`, `michal.menu`, `michal.system-island`, and `michal.workspaces`.
  - Maintains `🌸 Sakurazuki` branding in menu headers and about pages.
  - Deploys Japanese Kanji numerals `一 二 三 四 五 六` for workspace visualization.
  - Deploys the ambient foot screensaver scripts (`omarchy-screensaver`, `omarchy-launch-screensaver`).

- **Night Owl** (`Night-Owl/`):
  - Implements the complete Sarah Drasner Night Owl color system (`#011627` navy background, `#7FDBCA` teal accents, `#82AAFF` blue functions).
  - Deploys a dedicated Quickshell workspace plugin: `nightowl.workspaces` with strict zero-padded Arabic numerals (`01` through `10`).
  - Maintains `🦉 Night Owl` branding in menu extensions and system banners.
  - Deploys vector-generated SVG/PNG wallpapers (`night-owl.png`, `night-owl-minimal.png`).
  - Deploys application styling across 18 desktop components (Hyprland, Waybar, Ghostty, Foot, Kitty, Alacritty, GTK 3/4, Mako, SwayOSD, VSCode, Neovim, Btop, Walker, Wofi, Chromium).

---

## 4. Shared Integration & Dynamic Switching Engine

To permit seamless switching without modifying the upstream Omarchy core packages, the collection leverages Omarchy's native hook architecture:

### 4.1. The Hook Pipeline (`~/.config/omarchy/hooks/theme-set.d/`)
When the user executes `omarchy theme set <theme-name>`, the core utility executes all scripts in `~/.config/omarchy/hooks/theme-set.d/`:

1. **Theme Switching Hook** (`omarchy-theme-switch.sh`):
   - Reads the new target theme name passed via argument `$1`.
   - When switching to **`night-owl`**:
     - Swaps `~/.config/omarchy/shell.json` to instantiate the `nightowl.workspaces` plugin.
     - Updates Hyprland border gradients via `hyprctl keyword general:col.active_border "rgba(7fdbcaff) rgba(82aaffff) 45deg"`.
     - Updates Hyprland inactive borders to `rgba(1d3b53cc)`.
     - Reloads `omarchy-shell` to render the `01`..`10` two-digit workspace bar immediately.
   - When switching to **`sakurazuki`**:
     - Swaps `~/.config/omarchy/shell.json` to instantiate `michal.workspaces`.
     - Updates Hyprland active borders to `rgba(ffb7c5ff) rgba(e06b8bff) 45deg`.
     - Updates Hyprland inactive borders to `rgba(282233cc)`.
     - Reloads `omarchy-shell` to render the `一`..`六` Kanji workspace bar immediately.

### 4.2. Hyprland Look & Feel Dynamic Binding
In Omarchy Linux, user-level overrides in `~/.config/hypr/looknfeel.lua` and `~/.config/hypr/looknfeel.conf` are evaluated by Hyprland. To ensure border colors never get stuck on a stale configuration:
- The configuration reads `~/.local/state/omarchy/current/theme.name` dynamically.
- Borders, shadows, and rounding automatically align with the active theme upon compositor reload or theme change.

---

## 5. Security & Stability Guarantees

- **No Overwriting of Personal Shells**: The installation scripts check for existing configurations and create timestamped backups in `~/.config/omarchy/backups/` before installing.
- **Dry-Run Safe**: Both sub-project installers provide a `--dry-run` flag so users can inspect every planned file copy before committing any changes to disk.
- **Atomic Rollback**: If uninstalled, each sub-project's `uninstall.sh` removes only its registered theme files and plugins, leaving user documents, system libraries, and companion themes completely undisturbed.
