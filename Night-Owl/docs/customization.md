# Customization Guide — Night Owl Desktop

This guide explains how to customize Night Owl colors, adjust workspace indicators, modify the application menu, and tune desktop geometry.

---

## 1. Palette Tokens & Color Codes

Night Owl is built upon Sarah Drasner's original editor palette:

| Token Name | Hex Code | Role |
|---|---|---|
| **Background** | `#011627` | Deep dark navy workspace background & window base |
| **Foreground** | `#D6DEEB` | Primary body text and labels |
| **Cursor** | `#80A4C2` | Cursor and subtle indicators |
| **Selection** | `#1D3B53` | Selected list items and inactive borders |
| **Comments** | `#637777` | Muted secondary text and inactive workspace numbers |
| **Constants** | `#FF6363` | Warnings, urgent alerts |
| **Numbers** | `#F78C6C` | Numeric stats, CPU metrics |
| **Keywords** | `#C792EA` | Violet accent, menu category badges |
| **Functions** | `#82AAFF` | Blue accent, clock digits |
| **Strings** | `#ECC48D` | Warm accent, date labels |
| **Support** | `#ADDB67` | Green accent, connected status |
| **Variables** | `#7FDBCA` | Primary cyan/teal highlight, active workspace pill |
| **Invalid Syntax**| `#FF2C83` | Critical errors, battery low alerts |

---

## 2. Customizing Workspace Numbers

To customize workspace indicators, edit `config/omarchy/plugins/nightowl.workspaces/Workspaces.qml`:

```qml
function formatWorkspaceLabel(id) {
  return id < 10 ? ("0" + id) : String(id)
}
```

The sequence `01 02 03 04 05 06 07 08 09 10` is generated automatically. To adjust spacing or pill radius, modify `pillContainer`:

```qml
Rectangle {
  id: pillContainer
  radius: height / 2
  color: "#E6011627"
  border.color: Qt.rgba(29 / 255, 59 / 255, 83 / 255, 0.75)
}
```

---

## 3. Modifying Hyprland Look & Feel

Edit `config/hypr/looknfeel.conf`:
- **Window Gaps:** Change `gaps_in` (default 6) and `gaps_out` (default 12).
- **Corner Rounding:** Change `rounding` (default 10).
- **Border Gradients:** Modify `$nightowlActiveBorder` and `$nightowlInactiveBorder`.

---

## 4. Re-generating Wallpapers

To generate alternative resolutions or tweak wallpaper parameters:

```bash
cd config/omarchy/themes/night-owl/scripts
python3 generate_wallpapers.py
```
This regenerates `night-owl.png` and `night-owl-minimal.png` at 2560x1440.
