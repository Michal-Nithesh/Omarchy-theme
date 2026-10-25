<div align="center">

# 🦉 Night Owl Desktop

### A Complete Developer-Focused Desktop Customization for Omarchy Linux & Hyprland
*Inspired by Sarah Drasner's Iconic Night Owl Color Palette*

[![OS: Omarchy Linux](https://img.shields.io/badge/OS-Omarchy%20Linux-7FDBCA?style=for-the-badge&logo=arch-linux&logoColor=011627)](https://omarchy.org/)
[![Compositor: Hyprland](https://img.shields.io/badge/WM-Hyprland%20Wayland-82AAFF?style=for-the-badge&logo=wayland&logoColor=white)](https://hyprland.org/)
[![UI: Quickshell](https://img.shields.io/badge/UI-Quickshell%20QML-C792EA?style=for-the-badge&logo=qt&logoColor=white)](https://quickshell.outfoxxed.me/)
[![Palette: Night Owl](https://img.shields.io/badge/Palette-Night%20Owl-011627?style=for-the-badge)](https://github.com/sdras/night-owl-vscode-theme)

<br/>

![Night Owl Desktop Preview](screenshots/preview.png)

</div>

---

## 🌌 Overview & Design Philosophy

**Night Owl** is an independent, complete desktop environment crafted for **Omarchy Linux** and **Hyprland**, built specifically for late-night software development, deep focus, and clean system workflows.

Grounding its identity in Sarah Drasner's original Night Owl palette, this customization delivers:
- **Midnight Navy Canvas (`#011627`):** Minimizes optical fatigue while keeping dark backgrounds rich and alive.
- **Teal / Cyan Indicators (`#7FDBCA`):** Restrained, high-visibility beacons for active workspaces, focused inputs, and primary buttons.
- **Function Blue (`#82AAFF`) & Keyword Violet (`#C792EA`):** Calm secondary accents for system clocks, interactive dropdowns, and category tags.
- **Zero-Padded Arabic Numerals:** Clean, modern workspace identifiers formatted as `01 02 03 04 05 06 07 08 09 10`.
- **Owl Icon Identity (`🦉`):** Quick application menu launcher and lock screen motif.

---

## 🎨 Canonical Color Palette

| Color | Token Name | Hex Code | Purpose & Desktop Role |
|:---:|:---|:---:|:---|
| <img src="https://via.placeholder.com/20/011627/011627.png" width="20" height="20" /> | **Background** | `#011627` | Deep dark navy workspace background & window base |
| <img src="https://via.placeholder.com/20/D6DEEB/D6DEEB.png" width="20" height="20" /> | **Foreground** | `#D6DEEB` | High-contrast readable body text, window titles |
| <img src="https://via.placeholder.com/20/80A4C2/80A4C2.png" width="20" height="20" /> | **Cursor** | `#80A4C2` | Cursor glyphs, subtle indicators |
| <img src="https://via.placeholder.com/20/1D3B53/1D3B53.png" width="20" height="20" /> | **Selection** | `#1D3B53` | Selected list rows, inactive window borders |
| <img src="https://via.placeholder.com/20/637777/637777.png" width="20" height="20" /> | **Comments** | `#637777` | Muted secondary text, inactive workspace numbers |
| <img src="https://via.placeholder.com/20/FF6363/FF6363.png" width="20" height="20" /> | **Constants** | `#FF6363` | Warnings, urgent workspace badges, session exit |
| <img src="https://via.placeholder.com/20/F78C6C/F78C6C.png" width="20" height="20" /> | **Numbers** | `#F78C6C` | Metric values, CPU/RAM utilization numbers |
| <img src="https://via.placeholder.com/20/C792EA/C792EA.png" width="20" height="20" /> | **Keywords** | `#C792EA` | Violet accents, menu highlights, secondary tags |
| <img src="https://via.placeholder.com/20/82AAFF/82AAFF.png" width="20" height="20" /> | **Functions** | `#82AAFF` | Blue accent, clock digits, secondary interactive highlights |
| <img src="https://via.placeholder.com/20/ECC48D/ECC48D.png" width="20" height="20" /> | **Strings** | `#ECC48D` | Warm accent, date labels, calendar markers |
| <img src="https://via.placeholder.com/20/ADDB67/ADDB67.png" width="20" height="20" /> | **Support** | `#ADDB67` | Green accent, Wi-Fi connected, battery full |
| <img src="https://via.placeholder.com/20/7FDBCA/7FDBCA.png" width="20" height="20" /> | **Variables** | `#7FDBCA` | Primary cyan/teal highlight, active workspace pill |
| <img src="https://via.placeholder.com/20/FF2C83/FF2C83.png" width="20" height="20" /> | **Invalid Syntax**| `#FF2C83` | Critical errors, battery low alerts |

---

## 🔢 Workspace Numbering

Night Owl enforces zero-padded two-digit numbering across all indicators:

`01  02  03  04  05  06  07  08  09  10`

- **Active Workspace:** Solid `#7FDBCA` pill with bold `#011627` text.
- **Occupied Workspaces:** Translucent teal tint (`rgba(127, 219, 202, 0.18)`).
- **Hovered Workspaces:** Translucent blue tint (`rgba(130, 170, 255, 0.28)`).
- **Inactive Workspaces:** Subtle muted gray-blue text (`#637777`) on transparent background.
- **Urgent Workspaces:** Warning accent `#FF6363` with dark navy text.
- **Launcher Button:** Night Owl glyph `🦉` triggering the application menu.

---

## ⚡ Quick Start

### 1. Install Night Owl
```bash
cd Night-Owl
./install.sh
```

To preview changes before applying:
```bash
./install.sh --dry-run
```

### 2. Switch Themes at Any Time
```bash
# Using native Omarchy command
omarchy theme set night-owl

# Using the theme switcher helper
./bin/omarchy-theme-switch night-owl
```

### 3. Revert to Sakurazuki
```bash
omarchy theme set sakurazuki
```

### 4. Uninstall Night Owl
```bash
./uninstall.sh
```

---

## 📂 Project Structure

- `assets/`: 2560x1440 wallpapers (`night-owl.png` and `night-owl-minimal.png`) and vector preview files.
- `bin/`: CLI switching and utility scripts (`omarchy-theme-switch`).
- `config/ghostty/`: Terminal emulator configuration.
- `config/hypr/`: Hyprland look & feel, 10px rounding, borders, drop shadows, and hyprlock configuration.
- `config/omarchy/plugins/nightowl.workspaces/`: Standalone zero-padded workspaces Quickshell widget.
- `config/omarchy/themes/night-owl/`: Complete Omarchy theme bundle (colors.toml, shell.toml, Waybar, GTK 3/4, btop, Mako, Wofi, Walker).
- `docs/`: Technical specifications, implementation report, and palette contrast audits.
- `screenshots/`: Preview captures.
