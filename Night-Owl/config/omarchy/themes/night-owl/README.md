# 🦉 Night Owl Desktop Theme for Omarchy Linux & Hyprland

A complete, developer-focused desktop customization inspired by Sarah Drasner's original **Night Owl** color palette.

Designed for late-night programming sessions, deep focus, and clean system workflows, Night Owl pairs deep midnight-navy backgrounds with crisp cyan/teal interactive highlights, function-blue accents, and zero-padded Arabic numerals for all workspace indicators.

---

## 🎨 Color Palette

| Token Name | Hex Code | Role in Desktop Experience |
|---|---|---|
| **Background** | `#011627` | Deep dark navy workspace background & window base |
| **Foreground** | `#D6DEEB` | High-contrast readable body text, window titles |
| **Cursor** | `#80A4C2` | Cursor glyphs, subtle indicators |
| **Selection** | `#1D3B53` | Selected list rows, inactive window borders |
| **Comments** | `#637777` | Muted secondary text, inactive workspace labels |
| **Constants** | `#FF6363` | Warnings, urgent workspace badges, session exit |
| **Numbers** | `#F78C6C` | Metric values, CPU/RAM utilization numbers |
| **Keywords** | `#C792EA` | Violet accents, menu highlights, secondary tags |
| **Functions** | `#82AAFF` | Blue accent, clock time, secondary interactive highlights |
| **Strings** | `#ECC48D` | Warm accent, date labels, calendar markers |
| **Support** | `#ADDB67` | Green accent, Wi-Fi connected, battery full |
| **Variables** | `#7FDBCA` | Primary cyan/teal highlight, active workspace pill |
| **Invalid Syntax**| `#FF2C83` | Critical errors, battery low alerts |

---

## 🔢 Workspace Numbering

Night Owl implements **zero-padded Arabic numerals** across all workspace widgets and status bars:

`01 02 03 04 05 06 07 08 09 10`

- **Active Workspace:** Highlighted in bold with a solid `#7FDBCA` teal background and dark navy text (`#011627`).
- **Occupied Workspaces:** Translucent teal tint (`rgba(127, 219, 202, 0.18)`) with light foreground text.
- **Hovered Workspaces:** Restrained blue tint (`rgba(130, 170, 255, 0.28)`).
- **Inactive Workspaces:** Subtle muted gray-blue text (`#637777`) on transparent background.
- **Urgent Workspaces:** Attention accent `#FF6363` with dark navy text.
- **Launcher Button:** Perched Owl glyph `🦉` opening the application menu.

---

## 🧩 Supported Components

1. **Hyprland Compositor:**
   - Dual gradient active window border (`rgba(7fdbcaee) rgba(82aaffee) 45deg`).
   - Inactive border (`rgba(1d3b53aa)`).
   - 10px window corner rounding, 20px dark navy drop shadow.
   - Smooth 3-pass frosted glass blur.
2. **Quickshell Top Bar:**
   - `nightowl.workspaces` bar widget with `01`..`10` numbering.
   - Center digital clock, system metrics, and quick power modal.
3. **Waybar:**
   - Full native styling in `waybar/style.css` and `waybar/config.jsonc`.
   - Zero-padded workspace icons `01` through `10`.
   - Styled CPU, memory, battery, pulseaudio, network, bluetooth, and clock.
4. **Terminals:**
   - **Ghostty:** Custom 16-color ANSI palette, opacity 0.94, background blur.
   - **Foot:** Dedicated `foot.ini` configuration.
   - **Alacritty & Kitty:** Full palette definitions.
5. **Application Launchers:**
   - **Quickshell Menu:** Themed search, categories, and action rows.
   - **Wofi & Walker:** Custom stylesheets (`wofi.css`, `walker.css`).
6. **Notification Daemon:**
   - Handled via `shell.toml` (`[notifications]`) with `#0B253A` background, `#7FDBCA` border and countdown bar.
   - Fallback configuration in `mako.ini`.
7. **Lock Screen:**
   - Quickshell PAM locker and standalone `hyprlock.conf` with Night Owl color variables.
8. **GTK & File Manager (Nautilus):**
   - Dark theme preference (`color-scheme prefer-dark`, `Adwaita-dark`).
   - GTK 3 & 4 stylesheets with Night Owl selection and surface colors.
9. **Wallpapers:**
   - Original nocturnal vector art (`night-owl.png` and `night-owl-minimal.png`) at 2560x1440.
10. **System Monitor & OSD:**
    - `btop.theme` for btop resource monitor.
    - `swayosd.css` for volume/brightness OSD notifications.

---

## ⚡ Installation & Activation

### 1. Activate Night Owl via Omarchy CLI
```bash
omarchy theme set night-owl
```

### 2. Using the Interactive Switcher
```bash
# Using the theme switcher script
./scripts/switch-theme.sh night-owl

# Or using the workspace CLI binary
omarchy-theme-switch night-owl
```

---

## 🌸 Switching Back to Sakurazuki

Sakurazuki is completely preserved as an independent theme. To switch back at any time:

```bash
omarchy theme set sakurazuki
```
Or:
```bash
omarchy-theme-switch sakurazuki
```

Switching back immediately restores:
- Japanese Kanji workspace numbers (`一`, `二`, `三`, `四`, `五`, `六`)
- Cherry blossom launcher button (`🌸`)
- Sakura rose gradient window borders (`#A87692` / `#D9A6C4`)
- Midnight plum background (`#14111A`) and sakura wallpaper
- Sakurazuki icon theme and Ghostty color scheme

---

## 📦 Dependencies & Limitations

- **Compositor:** Hyprland 0.52+ (tested on 0.56.2)
- **Status Shell:** Quickshell (Omarchy Quattro 4.0.6+) or Waybar
- **Icons:** `Yaru-blue-dark` (recommended and pre-configured) or `WhiteSur-dark`
- **Fonts:** `JetBrainsMono Nerd Font` (default)
- **Limitations:** Applications that hardcode their own internal color schemes (such as certain Electron apps without theme integration) may require app-specific theme extensions.
