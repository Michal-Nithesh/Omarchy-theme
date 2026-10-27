# Sakurazuki System Audit & Theme Preservation Plan

**Date:** 2026-10-26  
**Target Environment:** Omarchy Linux (v4.0.6-1 "Quattro"), Arch Linux x86_64, Hyprland 0.56.2, Quickshell  
**Repository Root:** `/home/michal/Projects/Sakurazuki` (symlinked as `/home/michal/sakurazuki`)  
**Active Theme:** Sakurazuki (桜月 — *Cherry Blossom Moon*)  

---

## 1. Executive Summary

This audit catalogs the pre-existing desktop customization named **Sakurazuki**, assesses its component architecture, scripts, assets, and theme-switching integrations, and establishes isolation boundaries to guarantee that Sakurazuki remains 100% functional and intact while introducing the new **Night Owl** theme.

Sakurazuki is a cohesive desktop aesthetic based on a Japanese cherry blossom motif, blending a midnight plum background (`#14111A`) with sakura rose borders (`#A87692`), blossom pink highlights (`#D9A6C4`), and moonlight lavender accents (`#C2AEDF`).

---

## 2. Existing File and Directory Structure

### 2.1. Git Repository (`/home/michal/Projects/Sakurazuki`)

```
/home/michal/Projects/Sakurazuki/
├── assets/
│   ├── avatars/
│   │   ├── avatar_sakurazuki.png      # Sakurazuki avatar for menu and lockscreen
│   │   └── luffy_square.png           # Alternative profile avatar
│   ├── icons/
│   │   └── Sakurazuki/                # Custom WhiteSur-dark derivative icon theme
│   │       ├── index.theme
│   │       └── places/scalable/       # 40+ customized SVG folder icons with sakura tint
│   └── wallpapers/
│       ├── Sakurazuki Moonlit Valley Retreat.png  # Default mountain/valley landscape (2.2MB)
│       └── Screensaver.png            # Dimmed backdrop for terminal screensaver (1.2MB)
├── bin/
│   ├── omarchy-launch-screensaver     # Helper launcher with workspace 99 & wallpaper swap
│   └── omarchy-screensaver            # ttfx-powered terminal animation in Sakurazuki colors
├── config/
│   ├── ghostty/
│   │   └── config                     # Ghostty terminal configuration
│   ├── hypr/
│   │   ├── autostart.conf             # Autostart applications
│   │   ├── autostart.lua              # Lua-based autostart configuration
│   │   ├── bindings.conf              # Personal keybindings (apps, shortcuts, macOS-style)
│   │   ├── bindings.lua               # Lua-based keybinding definitions
│   │   ├── hypridle.conf              # Idle daemon timeouts (screensaver / lock)
│   │   ├── hyprland.conf              # Root compositor configuration
│   │   ├── hyprland.lua               # Root compositor Lua entrypoint
│   │   ├── hyprlock.conf              # Hyprlock screen locker layout & styling
│   │   ├── input.conf / input.lua     # Touchpad and keyboard input settings
│   │   ├── looknfeel.conf             # Look & feel: 14px rounding, borders, blur, shadows
│   │   ├── looknfeel.lua              # Lua look & feel: custom sakuraEase bezier curves
│   │   └── monitors.conf / monitors.lua # Monitor resolution, scaling (1.25), and refresh
│   └── omarchy/
│       ├── branding/
│       │   └── about.txt              # ASCII art branding for About modal
│       ├── extensions/
│       │   └── omarchy-menu.jsonc     # 10-category menu items and action bindings
│       ├── foot/
│       │   └── screensaver.ini        # Foot terminal styling dedicated to screensaver
│       ├── plugins/
│       │   ├── michal.bar/            # Custom status bar host plugin
│       │   ├── michal.center-island/  # Digital clock, calendar, weather, media controls
│       │   ├── michal.lock/           # Quickshell-based PAM lock screen
│       │   ├── michal.menu/           # Re-engineered 10-category application menu
│       │   ├── michal.system-island/  # Audio, Wi-Fi, BT, battery metrics & quick power
│       │   └── michal.workspaces/     # Kanji numerals (一 二 三 四 五 六) and 🌸 launcher
│       ├── shell.json                 # Quickshell shell layout & active plugin registration
│       └── themes/
│           └── sakurazuki/            # Theme directory recognized by Omarchy CLI
│               ├── aether.override.css
│               ├── alacritty.toml      # 16-color ANSI palette for Alacritty
│               ├── backgrounds/       # Symlinks/copies of Sakurazuki wallpapers
│               ├── btop.theme         # btop resource monitor color theme
│               ├── chromium.theme     # Chromium accent definition
│               ├── ghostty.conf       # 16-color palette and UI styling for Ghostty
│               ├── gtk-3.0/gtk.css    # GTK 3 theme overrides
│               ├── gtk-4.0/gtk.css    # GTK 4 theme overrides
│               ├── gtk.css            # Standard Omarchy GTK stylesheet
│               ├── hyprland.conf      # Hyprland active/inactive border color variables
│               ├── hyprlock.conf      # Hyprlock color tokens
│               ├── icons.theme        # Declares "Sakurazuki" icon theme
│               ├── kitty.conf         # Kitty terminal color configuration
│               ├── mako.ini           # Mako notification daemon styling
│               ├── neovim.lua         # Neovim color scheme integration
│               ├── preview/           # Preview images
│               ├── swayosd.css        # SwayOSD overlay styling
│               ├── vencord.theme.css  # Discord/Vencord custom CSS
│               ├── vscode.json        # VS Code theme reference
│               ├── walker.css         # Walker application launcher styling
│               ├── warp.yaml          # Warp terminal theme definition
│               ├── waybar.css         # Waybar theme stylesheet
│               └── wofi.css           # Wofi application launcher styling
├── docs/
│   ├── component-inventory.md         # Detailed component technical specifications
│   ├── customization.md               # Customization guide and palette definitions
│   ├── installation.md                # Deployment and installation documentation
│   ├── screenshots.md                 # Screenshot gallery index
│   └── troubleshooting.md             # Common issues and resolution steps
├── screenshots/                       # 18 high-resolution PNG captures of desktop UI
├── install.sh                         # Automated safe installer with timestamped backup
├── uninstall.sh                       # Safe uninstaller restoring pre-install state
├── LICENSE                            # MIT License
└── README.md                          # Repository overview and documentation
```

### 2.2. Installed User Configuration (`~/.config/`)

- `~/.config/omarchy/themes/sakurazuki/`: Installed copy of the Sakurazuki theme.
- `~/.config/omarchy/plugins/michal.*/`: Deployed custom Quickshell plugins.
- `~/.config/omarchy/shell.json`: Layout referencing `michal.bar`, `michal.workspaces`, `michal.center-island`, `michal.system-island`, `michal.menu`, `michal.lock`.
- `~/.config/omarchy/extensions/omarchy-menu.jsonc`: Installed menu definitions.
- `~/.config/hypr/`: Hyprland configuration files (`looknfeel.conf`, `looknfeel.lua`, `bindings.conf`, `hyprlock.conf`).
- `~/.config/ghostty/config`: Imports `~/.local/state/omarchy/current/theme/ghostty.conf`.
- `~/.config/foot/foot.ini`: Imports `~/.local/state/omarchy/current/theme/foot.ini`.
- `~/.config/alacritty/alacritty.toml`: Imports `~/.local/state/omarchy/current/theme/alacritty.toml`.
- `~/.config/gtk-3.0/settings.ini` & `gtk-4.0/settings.ini`: Points to `Sakurazuki` icon theme.
- `~/.local/share/icons/Sakurazuki/`: Deployed icon theme.
- `~/.local/state/omarchy/current/`: Active theme state (`theme` directory, `background` symlink, `theme.name`).

---

## 3. Current Customizations & Components

| Component | Responsibility | Current Sakurazuki Implementation |
|---|---|---|
| **Compositor (Hyprland)** | Window management & effects | Dual gradient border (`rgba(a87692ee) rgba(d9a6c4ee) 45deg`), inactive border (`rgba(443043aa)`), 14px corner rounding, `sakuraEase` bezier (`0.16, 1, 0.3, 1`), frosted glass blur (passes 3, size 6). |
| **Status Bar (Quickshell)** | Bar layout & islands | `michal.bar` hosting `michal.workspaces` (Kanji numerals `一` to `六`, `🌸` launcher), `michal.center-island` (clock, calendar, media, weather), `michal.system-island` (BT, Wi-Fi, audio, battery, power modal). |
| **Status Bar (Waybar)** | Alternative bar | Compatibility `waybar.css` defining `@define-color background #14111A; @define-color foreground #D8D0DC;`. |
| **Terminal (Ghostty/Foot)** | Command-line interface | Ghostty font JetBrainsMono Nerd Font size 8, opacity 0.94, background blur, importing dynamic `theme/ghostty.conf`. Foot screensaver with `screensaver.ini`. |
| **App Launcher (Quickshell / Wofi / Walker)** | Search & application launch | `michal.menu` with 10 categories (Apps, Learn, Appearance, Trigger, Setup, Install, Remove, Update, System, About). Fallback styling in `wofi.css` and `walker.css`. |
| **Notifications** | Desktop alerts | Handled by `omarchy-shell` notifications module governed by `shell.toml` (`[notifications]`). Fallback styling in `mako.ini`. |
| **Lock Screen** | Session authentication | `michal.lock` (Quickshell PAM locker with avatar framing and Japanese date/placeholder) and `hyprlock.conf` (Hyprlock standalone configuration). |
| **Screensaver** | Idle animation | `omarchy-launch-screensaver` switches to workspace 99, displays `Screensaver.png`, and runs `ttfx` matrix/rain animations in sakura colors. |
| **Icons & Cursors** | UI symbology | `Sakurazuki` icon theme (WhiteSur-dark base with pink-tinted folder SVGs) and `capitaine-cursors`. |
| **Wallpaper** | Desktop backdrop | `Sakurazuki Moonlit Valley Retreat.png`. |

---

## 4. Omarchy Theme-Switching Mechanics

Omarchy (Quattro 4.0.6-1) provides a standardized theme lifecycle via `omarchy theme set <theme-name>`:

1. **Discovery:** Checks `/usr/share/omarchy/themes/<theme-name>` and `~/.config/omarchy/themes/<theme-name>`.
2. **Staging:** Builds a clean directory at `~/.local/state/omarchy/current/next-theme/`, copying the official theme first and overlaying user theme files on top.
3. **Template Compilation:** If `colors.toml` is present, `omarchy-theme-set-templates` populates dynamic configs (`ghostty.conf`, `foot.ini`, `alacritty.toml`, `kitty.conf`, `neovim.lua`, `shell.toml`, `hyprland.lua`, `waybar.css`, etc.) from `$OMARCHY_PATH/default/themed/*.tpl`, without overwriting existing files in the theme folder.
4. **Atomic Swap:** Replaces `~/.local/state/omarchy/current/theme` with `next-theme` and writes `theme.name`.
5. **Background Update:** Sets symlink `~/.local/state/omarchy/current/background` to an image in the theme's `backgrounds/` folder and broadcasts transition via Quickshell IPC.
6. **Subsystem Broadcast:** Signals `omarchy-shell` to reload `shell.toml` and `colors.toml`, restarts terminals, refreshes GTK settings via `omarchy-theme-set-gnome` (reading `icons.theme`), and invokes `omarchy-hook theme-set <theme-name>`.

---

## 5. Potential Conflicts & Compatibility Concerns

1. **Hyprland Look & Feel Overrides:**
   - `~/.config/hypr/looknfeel.lua` and `looknfeel.conf` contain hardcoded Sakurazuki border colors (`rgba(a87692ee)` and `rgba(d9a6c4ee)`).
   - If left static, switching to Night Owl would leave the window borders pink/plum instead of teal/cyan.
   - *Resolution:* Make `looknfeel.lua` and `looknfeel.conf` theme-aware so that when `theme.name` is `night-owl`, it applies Night Owl active borders (`#7FDBCA` / `#82AAFF`) and inactive borders (`#1D3B53`), while preserving the exact Sakurazuki borders when `theme.name` is `sakurazuki`.

2. **Workspace Numbering & Widgets:**
   - Sakurazuki's `michal.workspaces` hardcodes Kanji numbers (`一`, `二`, ...), a cherry blossom launcher (`🌸`), and plum colors.
   - Night Owl strictly requires zero-padded Arabic numerals (`01`, `02`, ..., `10`), active highlight `#7FDBCA`, and an owl or neutral launcher.
   - *Resolution:* 
     - Provide a dedicated, standalone `nightowl.workspaces` plugin implementing zero-padded Arabic numerals (`01` through `10`), Night Owl states, and an owl launcher (`🦉`).
     - Provide a dedicated `shell.json` configuration for Night Owl.
     - Implement a seamless, automated theme-set hook script in `~/.config/omarchy/hooks/theme-set.d/` that switches the active workspaces widget and shell profile cleanly between Sakurazuki and Night Owl without breaking either theme.
     - Also configure Waybar `config.jsonc` and `style.css` / `waybar.css` with zero-padded numerals `01` to `10`.

3. **Icon Themes:**
   - Sakurazuki uses the custom `Sakurazuki` folder icon theme.
   - Night Owl looks best with a dark navy/blue system icon set such as `Yaru-blue-dark` or `WhiteSur-dark`.
   - *Resolution:* Night Owl specifies its own `icons.theme` file pointing to `Yaru-blue-dark` (or `WhiteSur-dark`), so `omarchy-theme-set-gnome` switches icon themes automatically without touching Sakurazuki's icon assets.

4. **Terminal Configuration:**
   - Ghostty, Foot, Alacritty, and Kitty all dynamically include `~/.local/state/omarchy/current/theme/<terminal-file>`.
   - As long as Night Owl provides complete terminal theme configurations, terminal styling transitions automatically upon theme switch.

5. **Screensaver Scripts:**
   - `omarchy-launch-screensaver` references `Screensaver.png` and `sakuraEase`.
   - Night Owl can supply its own night-owl screensaver backdrop or allow the screensaver to adapt safely.

---

## 6. List of Files That Must Remain Unchanged

The following files constitute Sakurazuki's core identity and must not be overwritten or modified:

1. `assets/avatars/avatar_sakurazuki.png` & `luffy_square.png`
2. `assets/icons/Sakurazuki/*` (entire directory and all 40+ SVGs)
3. `assets/wallpapers/Sakurazuki Moonlit Valley Retreat.png`
4. `assets/wallpapers/Screensaver.png`
6. `config/omarchy/themes/sakurazuki/*` (all files in the Sakurazuki theme)
7. `config/omarchy/plugins/michal.workspaces/*` (original Kanji workspaces plugin)
8. `config/omarchy/plugins/michal.center-island/*`
9. `config/omarchy/plugins/michal.system-island/*`
10. `config/omarchy/plugins/michal.menu/*`
11. `config/omarchy/plugins/michal.lock/*`
12. `config/omarchy/plugins/michal.bar/*`
13. `config/omarchy/extensions/omarchy-menu.jsonc`
14. `config/omarchy/branding/about.txt`
15. `config/omarchy/foot/screensaver.ini`
16. `docs/component-inventory.md`
17. `docs/customization.md`
18. `docs/installation.md`
19. `docs/screenshots.md`
20. `docs/troubleshooting.md`
21. `screenshots/*` (all original screenshots)
22. `install.sh` & `uninstall.sh` (Sakurazuki standalone scripts)
23. `README.md` & `LICENSE` (Sakurazuki repository root documents)

---

## 7. Isolation Strategy for Night Owl

To maintain complete independence between the two themes:

1. **Independent Theme Directory:**
   - Repository location: `themes/night-owl/`
   - Installed location: `~/.config/omarchy/themes/night-owl/`
2. **Night Owl Dedicated Plugins:**
   - Standalone `nightowl.workspaces` plugin implementing zero-padded Arabic numerals (`01` through `10`) with Night Owl interactive colors.
3. **Theme-Aware Hyprland Look & Feel:**
   - Make `looknfeel.conf` and `looknfeel.lua` query `theme.name` dynamically, guaranteeing that Sakurazuki retains its exact sakura gradient border and Night Owl receives its crisp teal/cyan/blue gradient border.
4. **Automated Reversible Switching:**
   - Integrate with `omarchy theme set <theme>` via an idempotent hook in `~/.config/omarchy/hooks/theme-set.d/omarchy-theme-switch.sh`.
   - Provide a dedicated switching helper `bin/omarchy-theme-switch` (or `themes/night-owl/scripts/switch-theme.sh`).
5. **No Regressions Guarantee:**
   - Switching back to Sakurazuki restores every single visual and behavioral detail of Sakurazuki without manual intervention.
