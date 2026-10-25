# Component Inventory — Night Owl Desktop

This document catalogues every customized component, file path, responsibility, and visual identity mapping in the **Night Owl** desktop environment.

---

## 1. Top Bar Components

### `nightowl.workspaces`
- **Location:** `config/omarchy/plugins/nightowl.workspaces/`
- **Core Files:** `Workspaces.qml`, `manifest.json`
- **Visual Design:**
  - Floating dark navy pill (`#E6011627`) with crisp border (`#1D3B53`).
  - Owl launcher button (`🦉`) triggering the main application menu (`omarchy.menu`).
  - Zero-padded Arabic numeral workspace labels: `01`, `02`, `03`, `04`, `05`, `06`, `07`, `08`, `09`, `10`.
  - Dynamic interactive states:
    - **Active:** Solid `#7FDBCA` teal background with bold `#011627` dark text.
    - **Occupied:** Translucent teal tint (`rgba(127, 219, 202, 0.18)`) with `#D6DEEB` text.
    - **Hovered:** Translucent function blue (`rgba(130, 170, 255, 0.28)`) with `#FFFFFF` text.
    - **Inactive:** Transparent background with muted `#637777` comments gray-blue text.
    - **Urgent:** Solid `#FF6363` warning red with `#011627` text.
- **Interactions:**
  - Left click on workspace: Switches workspace via `hyprctl dispatch hl.dsp.focus(...)`.
  - Scroll wheel: Cycles workspaces up/down.
  - Left click on `🦉`: Toggles application menu.
  - Right click on `🦉`: Spawns terminal (`xdg-terminal-exec`).

---

## 2. Waybar Configuration

- **Location:** `config/omarchy/themes/night-owl/waybar/`
- **Core Files:** `config.jsonc`, `style.css`, `waybar.css`
- **Features:**
  - Zero-padded workspace mapping (`format-icons`: `1` -> `"01"`, `2` -> `"02"`, ..., `10` -> `"10"`).
  - `#011627` dark navy background with 0.94 opacity.
  - Styled modules for CPU (`#C792EA`), Memory (`#82AAFF`), Wi-Fi (`#ADDB67`), Audio (`#82AAFF`), Battery (`#7FDBCA`), and Clock (`#82AAFF`).

---

## 3. Compositor & Window Management (Hyprland)

- **Location:** `config/hypr/` and `config/omarchy/themes/night-owl/`
- **Look & Feel:**
  - Active Border: Dual gradient `rgba(7fdbcaee) rgba(82aaffee) 45deg` (`#7FDBCA` to `#82AAFF`).
  - Inactive Border: Subtle navy border `rgba(1d3b53aa)` (`#1D3B53`).
  - Window Corner Rounding: `rounding = 10`.
  - Drop Shadows: Navy shadow `rgba(01162799)` with range 20 and render power 3.
  - Frosted Glass Blur: Size 6, passes 3, vibrancy 0.20.
  - Custom Beziers: `nightowlEase` (`0.16, 1, 0.3, 1`) and `nightowlFade` (`0.25, 0.1, 0.25, 1`).

---

## 4. Terminal Configurations

- **Ghostty:** `config/ghostty/config` and `themes/night-owl/ghostty.conf`
  - 16-color Night Owl ANSI palette, background `#011627`, foreground `#D6DEEB`, selection `#1D3B53`, cursor `#80A4C2`.
- **Foot:** `themes/night-owl/foot.ini`
- **Alacritty & Kitty:** `themes/night-owl/alacritty.toml`, `themes/night-owl/kitty.conf`

---

## 5. Lock Screen & Desktop Notifications

- **Hyprlock:** `config/hypr/hyprlock.conf` with 84px white digital clock, date label `🦉 $(date +"%A, %B %d")`, and `#7FDBCA` password input border.
- **Quickshell Notifications:** `shell.toml` (`[notifications]`) with `#0B253A` background, `#7FDBCA` countdown bar.
- **Mako:** `themes/night-owl/mako.ini`.

---

## 6. GTK & System Applications

- **GTK Stylesheets:** `gtk.css`, `gtk-3.0/gtk.css`, `gtk-4.0/gtk.css`.
- **Icon Theme:** `Yaru-blue-dark` declared in `icons.theme`.
- **System Monitor:** `btop.theme` with Night Owl color hierarchy.
- **OSD:** `swayosd.css` for volume/brightness overlays.
