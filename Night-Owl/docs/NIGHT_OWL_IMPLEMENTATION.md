# Night Owl Theme Implementation Report

**Project:** Night Owl Desktop Customization for Omarchy Linux  
**Date:** 2026-10-26  
**Status:** Completed & Validated  

---

## 1. Overview & Architecture Decisions

The goal of this implementation was to create a complete, independent desktop theme named **Night Owl** inspired by Sarah Drasner's original Night Owl palette, while preserving the pre-existing **Sakurazuki** customization in its entirety.

### Key Architectural Decisions:
1. **Strict Theme Isolation:** 
   Night Owl is built inside its own directory `themes/night-owl/` within the repository and deployed into `~/.config/omarchy/themes/night-owl/`. None of Sakurazuki's original assets, wallpapers, plugins, or theme files were overwritten.
2. **Dedicated Zero-Padded Workspaces Plugin:**
   Rather than hardcoding Japanese Kanji numerals or forcing global modifications, a dedicated Quickshell bar plugin named `nightowl.workspaces` was authored. It renders two-digit zero-padded numerals (`01`, `02`, ..., `10`), the owl icon `🦉`, and teal/blue hover and active states.
3. **Dynamic Theme-Set Hook:**
   An automated hook (`~/.config/omarchy/hooks/theme-set.d/omarchy-theme-switch.sh`) executes on every `omarchy theme set <theme>` invocation. It dynamically swaps the active workspaces plugin in `shell.json`, updates live Hyprland window borders via `hyprctl keyword`, and synchronizes icon themes.
4. **Theme-Aware Compositor Configuration:**
   `~/.config/hypr/looknfeel.lua` and `~/.config/hypr/looknfeel.conf` were upgraded to inspect the active theme state (`theme.name`), ensuring that Hyprland reloads apply the exact theme borders (sakura rose gradient for Sakurazuki; teal/blue gradient for Night Owl).
5. **Comprehensive Component Coverage:**
   Night Owl provides full styling for Hyprland, Waybar, Quickshell, Ghostty, Foot, Alacritty, Kitty, Wofi, Walker, Mako, btop, SwayOSD, GTK 3/4, and Neovim.

---

## 2. Files Created and Modified

### 2.1. New Theme Structure (`themes/night-owl/`)

| File / Directory | Description |
|---|---|
| `colors.toml` | Canonical color definitions recognized by Omarchy CLI template compiler |
| `shell.toml` | Quickshell surface token definitions (bar, popups, notifications, lock, menu, polkit) |
| `hyprland.conf` | Hyprland border variables, 10px corner rounding, and dark drop shadows |
| `hyprland.lua` | Lua equivalent for Hyprland 0.56+ looknfeel |
| `hyprlock.conf` | Hyprlock lock screen color variables |
| `ghostty.conf` | Ghostty 16-color ANSI palette and opacity configuration |
| `foot.ini` | Foot terminal palette configuration |
| `alacritty.toml` | Alacritty terminal color configuration |
| `kitty.conf` | Kitty terminal color configuration |
| `waybar.css` | Waybar color definitions |
| `waybar/config.jsonc` | Complete Waybar module layout with `01`..`10` zero-padded workspaces |
| `waybar/style.css` | Comprehensive Waybar stylesheet with Night Owl visual identity |
| `gtk.css` | Global GTK 3/4 stylesheet with Night Owl surface and selection styling |
| `gtk-3.0/gtk.css` & `gtk-4.0/gtk.css` | Target GTK menu, dropdown, and listview styling |
| `icons.theme` | Declares `Yaru-blue-dark` as the system icon theme |
| `mako.ini` | Mako desktop notification daemon styling |
| `wofi.css` & `walker.css` | Wofi and Walker application launcher stylesheets |
| `swayosd.css` | SwayOSD on-screen display styling |
| `btop.theme` | btop system resource monitor theme |
| `neovim.lua` | Neovim `oxfist/night-owl.nvim` theme declaration |
| `vscode.json` | VS Code `sdras.night-owl` extension metadata |
| `plugins/nightowl.workspaces/` | Standalone Quickshell plugin implementing zero-padded Arabic numerals |
| `assets/wallpapers/` | Original 2560x1440 wallpapers (`night-owl.png` and `night-owl-minimal.png`) |
| `backgrounds/` | Deployed wallpaper symlinks for Omarchy theme background cycling |
| `scripts/generate_wallpapers.py` | Python vector generator for the original wallpapers |
| `scripts/omarchy-theme-switch.sh` | Automated theme hook script |
| `scripts/switch-theme.sh` | User-facing CLI theme switcher |
| `README.md` | Complete theme documentation and user guide |

### 2.2. New Root / Utility Files

| File | Description |
|---|---|
| `bin/omarchy-theme-switch` | Workspace executable for switching between Sakurazuki and Night Owl |
| `docs/SAKURAZUKI_AUDIT.md` | Pre-implementation system audit and file inventory |
| `docs/NIGHT_OWL_PALETTE.md` | Canonical palette specification, derived colors, and contrast analysis |
| `docs/NIGHT_OWL_IMPLEMENTATION.md` | This technical implementation report |
| `themes/night-owl/assets/preview.png` | Comprehensive theme visual composition preview |

### 2.3. Modified Configuration Files (Shared Environment)

| File | Modification Details | Safety & Reversibility |
|---|---|---|
| `~/.config/hypr/looknfeel.lua` | Made active border color dynamic based on `theme.name`. Retains exact Sakurazuki colors when `sakurazuki` is active. | Idempotent; preserves all other gaps, animations, and shadows. |
| `~/.config/hypr/looknfeel.conf` | Pointed `$activeBorder` to `$activeBorderColor` with Sakurazuki fallback. | Idempotent; preserves compositor behavior. |
| `~/.config/omarchy/hooks/theme-set.d/omarchy-theme-switch.sh` | Installed automation hook in Omarchy's official hooks directory. | Cleanly isolates theme-specific UI changes. |
| `~/.config/omarchy/plugins/nightowl.workspaces/` | Installed custom workspaces plugin alongside `michal.workspaces`. | Coexists without modifying `michal.workspaces`. |

---

## 3. Shared Components & Isolation Verification

- **Sakurazuki Files Intact:**
  All 23 core files and directories cataloged in `docs/SAKURAZUKI_AUDIT.md` remain completely untouched.
- **No Shared Component Bleed:**
  - Ghostty reads `theme/ghostty.conf` from the active theme state.
  - Foot reads `theme/foot.ini` from the active theme state.
  - GTK reads `icons.theme` from the active theme state.
  - The bar workspace widget toggles cleanly between `michal.workspaces` (Sakurazuki Kanji) and `nightowl.workspaces` (Night Owl `01`..`10`).
- **Compositor Stability:**
  Neither theme restarts Hyprland or disrupts running graphical applications during theme switches.

---

## 4. Validation Results

| Test Case | Method | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| **Bash Syntax Check** | `bash -n` on all shell scripts | Exit code 0, no syntax errors | Exit code 0, zero errors | **PASS** |
| **JSON Validation** | `python3 -m json.tool` | Valid JSON / JSONC syntax | All manifest and config files parsed cleanly | **PASS** |
| **TOML Validation** | `tomllib` in Python | Valid TOML structure | `colors.toml`, `shell.toml`, `alacritty.toml` valid | **PASS** |
| **Omarchy Color Extraction** | `omarchy-theme-color --file colors.toml --all` | Generates full key-value table | 54 tokens parsed successfully | **PASS** |
| **Hyprland Syntax Check** | `hyprctl configerrors` | No syntax errors reported | Zero errors reported | **PASS** |
| **Theme Discovery** | `omarchy theme list` | Lists both Sakurazuki and Night Owl | Both themes displayed in list | **PASS** |
| **Switch to Night Owl** | `omarchy theme set night-owl` | Applies teal borders, zero-padded `01`..`10`, navy wallpaper | All components transitioned successfully | **PASS** |
| **Restore Sakurazuki** | `omarchy theme set sakurazuki` | Restores sakura borders, Kanji `一`..`六`, plum wallpaper | Fully restored with zero regressions | **PASS** |
| **CLI Switcher Tool** | `omarchy-theme-switch current/night-owl/sakurazuki` | Smooth CLI transitions | Toggled both themes seamlessly | **PASS** |

---

## 5. Known Limitations & Follow-Up Recommendations

1. **Third-Party Electron Applications:**
   Some standalone Electron applications (e.g. Discord without Vencord, or Slack) bundle their own hardcoded CSS themes. For those apps, applying Night Owl requires using third-party CSS injectors or webapp custom styles.
2. **Waybar vs. Quickshell:**
   In Omarchy v4 ("Quattro"), Quickshell (`omarchy-shell`) is the primary desktop bar. Waybar is fully configured and ready in `themes/night-owl/waybar/` should the user run Waybar directly.
3. **Screensaver ttfx Palette:**
   `omarchy-screensaver` supports an ambient backdrop and ttfx animations. If desired in future updates, an owl-shaped ASCII art asset can be added to `~/.config/omarchy/branding/screensaver-nightowl.txt`.
