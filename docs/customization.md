# Customization Guide — Michal × Sakurazuki

This guide explains how to customize and personalize your Sakurazuki desktop, adjust color tokens, add new menu items, and modify UI behaviors.

---

## 1. Palette Tokens & Color Codes

Sakurazuki is built upon the following color palette:

| Token Name | Hex Code | Purpose |
|---|---|---|
| **Background** | `#14111A` | Main desktop background and base surface |
| **Secondary Background** | `#211925` | Cards, sidebars, and elevated containers |
| **Surface** | `#2A1B2A` | Floating popovers and dropdown cards |
| **Sakura Rose** | `#A87692` | Active borders, focused tags, primary accents |
| **Blossom Pink** | `#D9A6C4` | Highlight text, gradient stops, badges |
| **Moonlight Lavender**| `#C2AEDF` | Clock digits, secondary icons, subtle highlights|
| **Primary Text** | `#F0DCEB` | High-contrast readable body text |
| **Secondary Text** | `#B8A3BB` | Subtitles, labels, descriptions |
| **Muted Text** | `#88758F` | Placeholders, inactive items, timestamps |
| **Border** | `#443043` | Crisp, dark plum borders |

### Changing Colors
- **GTK Applications:** Edit `config/omarchy/themes/sakurazuki/gtk.css`.
- **Terminal Palette:** Edit `config/omarchy/themes/sakurazuki/ghostty.conf` or `alacritty.toml`.
- **Hyprland Borders & Shadows:** Edit `config/hypr/looknfeel.conf` (`$sakuraActiveBorder` and `$sakuraInactiveBorder`).

---

## 2. Modifying Main Menu Categories & Items

The menu is dynamically constructed through two layers:
1. Built-in system categories defined in `config/omarchy/plugins/michal.menu/MenuModel.js`.
2. User extensions declared in `config/omarchy/extensions/omarchy-menu.jsonc`.

### Adding a Custom Menu Item
To add a new entry to the menu, open `config/omarchy/extensions/omarchy-menu.jsonc` and append your item:

```jsonc
{
  "setup.my-custom-tool": {
    "icon": "󰘦",
    "label": "My Custom Tool",
    "description": "Launch my personal automation script",
    "action": "bash -c '~/my-script.sh'"
  }
}
```

Then reload the menu:
```bash
omarchy-menu refresh
```

---

## 3. Customizing Workspace Kanji Labels

To change or extend the Kanji workspace symbols, open `config/omarchy/plugins/michal.workspaces/Workspaces.qml`:

```qml
readonly property var kanjiNumbers: ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
```

You can replace them with Roman numerals, Japanese zodiac symbols, or custom icons:
```qml
readonly property var kanjiNumbers: ["", "Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ"]
```

---

## 4. Setting Wallpapers & Avatars

### Changing Wallpaper
Place your desired image into `~/.config/omarchy/themes/sakurazuki/backgrounds/` and set it via Omarchy:
```bash
omarchy theme background "My Wallpaper.png"
```

### Changing Avatar
Replace `~/.config/omarchy/assets/avatar_sakurazuki.png` with a square or circular transparent PNG (recommended size: `256x256` or `512x512`).

---

## 5. Adjusting Hyprland Animations & Window Gaps

Edit `config/hypr/looknfeel.conf`:
- **Gaps:** Modify `gaps_in = 6` (inner gap between windows) and `gaps_out = 12` (outer margin from screen edge).
- **Rounding:** Modify `rounding = 14` for window corner radius.
- **Blur Intensity:** Adjust `size` and `passes` in the `decoration { blur { ... } }` block.
- **Transitions:** Adjust `sakuraEase` bezier speeds in the `animations { ... }` block.
