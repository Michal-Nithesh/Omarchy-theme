# Omarchy Desktop Theme Collection

```text
   ____                             _             
  / __ \____ ___  ____ ___________ / /_  __  __   
 / / / / __ `__ \/ __ `/ ___/ ___// __ \/ / / /   
/ /_/ / / / / / / /_/ / /  / /__ / / / / /_/ /    
\____/_/ /_/ /_/\__,_/_/   \___//_/ /_/\__, /     
                                      /____/      
          Multi-Theme Desktop Distributions
```

A curated suite of desktop themes designed for **Omarchy Linux**, **Arch Linux**, and **Hyprland**, offering deep visual harmony, bespoke Quickshell widget integrations, and seamless instant theme switching.

---

## 🌟 The Themes

```carousel
![Night Owl Preview](file:///home/michal/Projects/Omarchy/Night-Owl/assets/preview/preview.png)
<!-- slide -->
![Sakurazuki Preview](file:///home/michal/Projects/Omarchy/Sakurazuki/screenshots/desktop/desktop-overview.png)
```

| Theme | Aesthetic Inspiration | Dominant Palette | Workspace Style | Launcher Icon |
|---|---|---|---|:---:|
| [**Sakurazuki**](file:///home/michal/Projects/Omarchy/Sakurazuki/README.md) | Japanese Cherry Blossom Moonlight | `#14111A` Plum & `#FFB7C5` Sakura Pink | Traditional Kanji (`一 二 三 四 五 六`) | `🌸` |
| [**Night Owl**](file:///home/michal/Projects/Omarchy/Night-Owl/README.md) | Sarah Drasner's Night Owl IDE Theme | `#011627` Midnight Navy & `#7FDBCA` Teal | Zero-Padded Arabic (`01 02 03 ... 10`) | `🦉` |

---

## ⚡ Quick Start

### 1. Install Night Owl
```bash
cd ~/Projects/Omarchy/Night-Owl
./install.sh
```

### 2. Install Sakurazuki
```bash
cd ~/Projects/Omarchy/Sakurazuki
./install.sh
```

### 3. Switch Themes On-The-Fly
Switch reversibly with a single command without logging out:
```bash
# Switch to Night Owl (01-10 numbering, navy & teal focus)
omarchy theme set night-owl

# Switch to Sakurazuki (Kanji numbering, blossom pink focus)
omarchy theme set sakurazuki
```
*Or use the interactive selector: `omarchy-theme-switch`*

---

## 📁 Repository Structure

```
Omarchy/
├── Sakurazuki/                 # Sakurazuki Desktop Distribution
│   ├── README.md               # Theme details and features
│   ├── install.sh              # Independent installer
│   ├── uninstall.sh            # Independent uninstaller
│   ├── bin/                    # Screensaver & utility scripts
│   ├── assets/                 # Wallpapers, avatars, custom icon pack
│   ├── config/                 # Hyprland, Ghostty, and Quickshell plugins
│   ├── docs/                   # Audits, inventory, and customization notes
│   └── screenshots/            # Showcase desktop captures
│
├── Night-Owl/                  # Night Owl Desktop Distribution
│   ├── README.md               # Theme details and palette notes
│   ├── install.sh              # Independent installer
│   ├── uninstall.sh            # Independent uninstaller
│   ├── bin/                    # Theme switching utilities
│   ├── assets/                 # Wallpapers and preview composition
│   ├── config/                 # Hyprland, Ghostty, and nightowl.workspaces plugin
│   ├── docs/                   # Implementation specs and color tokens
│   └── screenshots/            # High-resolution theme previews
│
├── docs/                       # Architectural & Comparative Documentation
│   ├── architecture.md         # System design and sub-project isolation
│   ├── installation.md         # Unified setup, CLI flags, and switching
│   ├── theme-comparison.md     # Side-by-side feature and color matrix
│   └── migration.md            # Upgrading from legacy single-theme repo
│
├── README.md                   # Top-level collection guide
├── LICENSE                     # MIT License
└── .gitignore                  # Git repository ignore patterns
```

---

## 🎨 Theme Highlights

### 🌸 Sakurazuki
- **Ethereal Moonlight Ambiance**: Dark amethyst/plum backdrop (`#14111A`) illuminated by cherry blossom pink (`#FFB7C5`) and rose highlights (`#E06B8B`).
- **Kanji Workspaces**: Native Quickshell status bar displaying Japanese Kanji numerals (`一 二 三 四 五 六`).
- **Island Architecture**: Dedicated Quickshell plugins including `michal.bar`, `michal.center-island`, `michal.system-island`, `michal.lock`, and `michal.menu`.
- **Ambient Screensaver**: Built-in CLI screensaver daemon launching full-screen terminal animations on idle.
- **Custom Icon Pack**: Tailored folder and desktop icon suite themed to the Sakurazuki color spectrum.

### 🦉 Night Owl
- **Sarah Drasner Visual Identity**: Faithfully adapted from the official Night Owl editor color system, tailored for a developer-focused, low-strain Linux desktop experience.
- **Two-Digit Zero-Padded Workspaces**: Strict `01 02 03 04 05 06 07 08 09 10` sequence in both Waybar and the custom `nightowl.workspaces` Quickshell plugin.
- **Developer Color Semantics**: Midnight navy (`#011627`), mint teal accents (`#7FDBCA`), and indigo functions (`#82AAFF`) with coral alerts (`#FF6363`).
- **Comprehensive Application Theming**: Turnkey configurations for Hyprland, Waybar, Ghostty, Foot, Kitty, Alacritty, GTK 3/4, Mako, SwayOSD, Neovim, VSCode, Btop, Walker, Wofi, and Chromium.
- **Dynamic Compositor Hooking**: Real-time border gradient and shell layout switching via Omarchy's `theme-set.d` hook engine.

---

## 📖 Documentation Index

- [Architecture & Design](file:///home/michal/Projects/Omarchy/docs/architecture.md)
- [Installation & Switching Guide](file:///home/michal/Projects/Omarchy/docs/installation.md)
- [Side-by-Side Theme Comparison](file:///home/michal/Projects/Omarchy/docs/theme-comparison.md)
- [Migration Guide](file:///home/michal/Projects/Omarchy/docs/migration.md)
- [Sakurazuki Component Inventory](file:///home/michal/Projects/Omarchy/Sakurazuki/docs/component-inventory.md)
- [Night Owl Implementation Specification](file:///home/michal/Projects/Omarchy/Night-Owl/docs/NIGHT_OWL_IMPLEMENTATION.md)
- [Night Owl Palette Definition](file:///home/michal/Projects/Omarchy/Night-Owl/docs/NIGHT_OWL_PALETTE.md)

---

## 📜 License

This project is licensed under the MIT License — see the [LICENSE](file:///home/michal/Projects/Omarchy/LICENSE) file for details.
