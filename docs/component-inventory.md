# Component Inventory — Michal × Sakurazuki

This document catalogues every customized component, file path, responsibility, and IPC integration in the **Michal × Sakurazuki** desktop environment.

---

## 1. Top Bar Components

### `michal.workspaces`
- **Location:** `config/omarchy/plugins/michal.workspaces/`
- **Core Files:** `Workspaces.qml`, `manifest.json`
- **Visual Design:**
  - Floating dark plum pill (`#E614111A`) with subtle border.
  - Cherry blossom prefix (`🌸`) acting as the interactive Main Menu launcher.
  - Kanji numeral workspace labels: `一`, `二`, `三`, `四`, `五`, `六`.
  - Dynamic states: Active (`#A87692`), Occupied (`rgba(168, 118, 146, 0.20)`), Hovered (`#D8D0DC`), Inactive (`#7D7185`).
- **Interaction:**
  - Left click on workspace: Switch workspace via `hyprctl dispatch hl.dsp.focus(...)`.
  - Scroll wheel: Cycle workspaces up/down.
  - Left click on `🌸`: Toggle main menu (`omarchy-menu toggle`).
  - Right click on `🌸`: Spawn terminal (`xdg-terminal-exec`).

### `michal.center-island`
- **Location:** `config/omarchy/plugins/michal.center-island/`
- **Core Files:** `CenterIsland.qml`, `CalendarModel.js`, `status.sh`, `manifest.json`
- **Visual Design:**
  - Compact rounded pill displaying live digital time (`HH:mm`), live weather condition icon, and temperature.
  - Date string format: `dddd · d MMMM`.
- **Interactive Popovers:**
  - **Calendar Popover:** Full monthly grid, interactive month switching, day indicator.
  - **Controls Popover:** Media playback controls, current track details, quick system switches.
- **IPC Interface:**
  - `omarchy-shell michal.center-island openCalendar`
  - `omarchy-shell michal.center-island toggleCalendar`
  - `omarchy-shell michal.center-island openControls`
  - `omarchy-shell michal.center-island toggleControls`

### `michal.system-island`
- **Location:** `config/omarchy/plugins/michal.system-island/`
- **Core Files:** `SystemIsland.qml`, `backend.py`, `manifest.json`
- **Visual Design:**
  - Multi-metric status cluster with Bluetooth (`󰂯`), Wi-Fi (`󰤨`), Audio (`󰕾`), Brightness (`󰍹`), and Battery (`󰁹` + percentage).
- **Interactive Popovers:**
  - **System Popover Tabs:**
    - `Bluetooth`: Device scanning, pairing status, connected device list.
    - `Wi-Fi`: Active SSID, signal strength, scan network list, inline password authentication.
    - `Audio`: Output volume slider, input volume slider, mute toggles.
    - `Display`: Brightness percentage slider, display profile switches.
    - `System`: Live CPU usage %, RAM utilization, battery health status.
  - **Quick Power Modal:** Floating central plum card with 4 discrete buttons: Lock, Screensaver, Restart, Shutdown.
- **IPC Interface:**
  - `omarchy-shell michal.system-island toggleBattery`
  - `omarchy-shell michal.system-island toggleWifi`
  - `omarchy-shell michal.system-island toggleBluetooth`
  - `omarchy-shell michal.system-island toggleAudio`
  - `omarchy-shell michal.system-island toggleDisplay`
  - `omarchy-shell michal.system-island togglePower`

---

## 2. Main Menu System

### `michal.menu`
- **Location:** `config/omarchy/plugins/michal.menu/`
- **Core Files:** `Menu.qml`, `MenuModel.js`, `BarWidget.qml`, `manifest.json`
- **Navigation & Categories:**
  1. **Apps (`apps`):** Dynamic grid of installed desktop applications with Arch icon badge indicator.
  2. **Learn (`learn`):** Keybindings cheat sheet, Omarchy manual, Hyprland docs, Arch Linux wiki, community Discord.
  3. **Appearance (`style`):** Theme switcher, wallpaper/background selector, window gaps toggle, workspace layout toggle.
  4. **Trigger (`trigger`):** Stay Awake, night light toggle, emoji picker, clipboard history, reminders, screenshots, color picker.
  5. **Setup (`setup`):** Display & monitor config, keybindings, input & touchpad, default browser, default terminal, default editor.
  6. **Install (`install`):** Curated package manager installer (development tools, browsers, productivity).
  7. **Remove (`remove`):** Clean uninstallation of installed software suites.
  8. **Update (`update`):** System update checks, pacman mirror refresh, firmware updates.
  9. **System (`system`):** Hardware specifications, disk space usage, system logs, session actions.
  10. **About (`about`):** Dedicated Michal × Sakurazuki system overview with avatar, Arch icon count pill, and categorized spec cards.
- **Menu Extensions:** `config/omarchy/extensions/omarchy-menu.jsonc`

---

## 3. Lock Screen

### `michal.lock`
- **Location:** `config/omarchy/plugins/michal.lock/`
- **Core Files:** `LockView.qml`, `Service.qml`, `manifest.json`
- **Visual Design:**
  - Deep plum frosted glass background with smooth blur passes.
  - Large white minimalist clock (`HH:mm`) and Japanese date formatting.
  - Circular avatar container with sakura plum border accent.
  - Password input field featuring Japanese placeholder `"パスワードを入力…"`.
  - PAM integration for secure authentication and fingerprint reader support.
- **Safe Preview IPC:**
  - `omarchy-shell lock preview` (Previews the lock screen without locking PAM)
  - `omarchy-shell lock hidePreview`

---

## 4. Compositor & Window Management

### Hyprland Overrides
- **Location:** `config/hypr/`
- **Look & Feel (`looknfeel.conf`):**
  - Gaps: `gaps_in = 6`, `gaps_out = 12`
  - Borders: Active border dual gradient (`rgba(a87692ee) rgba(d9a6c4ee) 45deg`), inactive border (`rgba(443043aa)`).
  - Window Corner Rounding: `rounding = 14`.
  - Shadows: Plum shadow `rgba(14111a77)` with render power 3.
  - Frosted Glass Blur: Size 6, passes 3, vibrancy 0.22.
  - Custom Bezier Curves: `sakuraEase` (`0.16, 1, 0.3, 1`) and `sakuraFade` (`0.25, 0.1, 0.25, 1`).

---

## 5. Terminal & GTK Aesthetics

### Ghostty Terminal
- **Location:** `config/ghostty/config`, `config/omarchy/themes/sakurazuki/ghostty.conf`
- **Palette:** 16-color Sakurazuki ANSI palette with `#14111A` background and `#D8D0DC` foreground.
- **Font:** JetBrainsMono Nerd Font.
- **Window:** Background opacity 0.94, background blur enabled, custom padding.

### Sakurazuki Icon Theme
- **Location:** `assets/icons/Sakurazuki/`
- **Inheritance:** WhiteSur-dark base with custom cherry-blossom tinted directory icons (`places/scalable/`).
