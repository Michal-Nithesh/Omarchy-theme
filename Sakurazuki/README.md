<div align="center">

# 🌸 Michal × Sakurazuki 桜月

### A Modern Japanese Cherry Blossom Desktop for Omarchy Linux & Hyprland

[![OS: Omarchy Linux](https://img.shields.io/badge/OS-Omarchy%20Linux-947598?style=for-the-badge&logo=arch-linux&logoColor=white)](https://omarchy.org/)
[![Compositor: Hyprland](https://img.shields.io/badge/WM-Hyprland%20Wayland-A87692?style=for-the-badge&logo=wayland&logoColor=white)](https://hyprland.org/)
[![UI: Quickshell](https://img.shields.io/badge/UI-Quickshell%20QML-C2AEDF?style=for-the-badge&logo=qt&logoColor=white)](https://quickshell.outfoxxed.me/)
[![License: MIT](https://img.shields.io/badge/License-MIT-D9A6C4?style=for-the-badge)](LICENSE)

<br/>

![Desktop Overview](screenshots/desktop/desktop-overview.png)

</div>

---

## ⛩️ Overview & Design Philosophy

**Sakurazuki** (桜月 — *Cherry Blossom Moon*) is a personalized, minimalist desktop customization crafted for **Omarchy Linux** and **Hyprland**. 

Inspired by peaceful Japanese spring nights, Sakurazuki fuses a rich midnight plum base with sakura blossom pink accents and moonlight lavender highlights. Every component—from the custom Kanji workspace numbers and dynamic status islands down to the 10-category main menu and high-contrast lock screen—has been tailored for seamless everyday usability, fluid performance, and aesthetic elegance.

---

## 🎨 Color Palette

| Color Swatch | Name | Hex Code | Role & Usage |
|:---:|:---|:---:|:---|
| <img src="https://via.placeholder.com/20/14111A/14111A.png" width="20" height="20" /> | **Midnight Plum** | `#14111A` | Base desktop background, main window surfaces |
| <img src="https://via.placeholder.com/20/211925/211925.png" width="20" height="20" /> | **Deep Plum** | `#211925` | Card backgrounds, elevated surfaces, sidebars |
| <img src="https://via.placeholder.com/20/2A1B2A/2A1B2A.png" width="20" height="20" /> | **Frosted Plum** | `#2A1B2A` | Popovers, dropdown menus, modal backdrops |
| <img src="https://via.placeholder.com/20/A87692/A87692.png" width="20" height="20" /> | **Sakura Rose** | `#A87692` | Active borders, focused tags, primary interactive accents |
| <img src="https://via.placeholder.com/20/D9A6C4/D9A6C4.png" width="20" height="20" /> | **Blossom Pink** | `#D9A6C4` | Highlight text, gradient stops, badge indicators |
| <img src="https://via.placeholder.com/20/C2AEDF/C2AEDF.png" width="20" height="20" /> | **Moonlight Lavender** | `#C2AEDF` | Clock digits, secondary icons, subtle highlights |
| <img src="https://via.placeholder.com/20/F0DCEB/F0DCEB.png" width="20" height="20" /> | **Sakura White** | `#F0DCEB` | High-contrast readable body text |
| <img src="https://via.placeholder.com/20/B8A3BB/B8A3BB.png" width="20" height="20" /> | **Secondary Text** | `#B8A3BB` | Subtitles, labels, descriptions |
| <img src="https://via.placeholder.com/20/88758F/88758F.png" width="20" height="20" /> | **Muted Lavender** | `#88758F` | Placeholders, inactive items, timestamps |
| <img src="https://via.placeholder.com/20/443043/443043.png" width="20" height="20" /> | **Plum Border** | `#443043` | Fine container borders, dividers |

---

## 📸 Visual Showcase

### Top Bar & Interactive Islands

![Top Bar Detail](screenshots/islands/top-bar-full.png)

<div align="center">

| Kanji Workspaces (`一 二 三 四 五 六`) | Center Island (Time & Weather) | System Island (Metrics) |
|:---:|:---:|:---:|
| ![Workspaces](screenshots/islands/workspaces-kanji.png) | ![Center Island](screenshots/islands/center-island.png) | ![System Island](screenshots/islands/system-island.png) |

| Expanded Calendar Popover | Media & System Controls | Central Quick Power Modal |
|:---:|:---:|:---:|
| ![Calendar](screenshots/islands/center-island-calendar.png) | ![Controls](screenshots/islands/center-island-controls.png) | ![Power Modal](screenshots/islands/power-modal.png) |

</div>

---

### Main Menu (10 Categories)

The unified **Michal × Sakurazuki Menu** provides fast, responsive keyboard- and mouse-friendly navigation across 10 functional domains:

<div align="center">

| 01. Apps | 02. Learn |
|:---:|:---:|
| ![Apps](screenshots/menu/01-apps.png) | ![Learn](screenshots/menu/02-learn.png) |

| 03. Appearance | 04. Trigger |
|:---:|:---:|
| ![Appearance](screenshots/menu/03-appearance.png) | ![Trigger](screenshots/menu/04-trigger.png) |

| 05. Setup | 06. Install |
|:---:|:---:|
| ![Setup](screenshots/menu/05-setup.png) | ![Install](screenshots/menu/06-install.png) |

| 07. Remove | 08. Update |
|:---:|:---:|
| ![Remove](screenshots/menu/07-remove.png) | ![Update](screenshots/menu/08-update.png) |

| 09. System | 10. About (Specs & Overview) |
|:---:|:---:|
| ![System](screenshots/menu/09-system.png) | ![About](screenshots/menu/10-about.png) |

</div>

---

### Applications & Lock Screen

<div align="center">

| Ghostty Terminal (`fastfetch`) | Nautilus File Manager (GTK Theme) | Sakurazuki Lock Screen |
|:---:|:---:|:---:|
| ![Ghostty](screenshots/apps/ghostty-terminal.png) | ![Nautilus](screenshots/apps/nautilus-file-manager.png) | ![Lock Screen](screenshots/lock/lock-screen.png) |

</div>

---

## 🧩 Component Architecture

Sakurazuki is built modularly on top of Omarchy Linux and Quickshell:

- **`michal.workspaces`:** Top-left bar widget featuring Japanese Kanji numeral badges (`一` through `六`) and an interactive cherry blossom launcher button (`🌸`).
- **`michal.center-island`:** Centered digital clock, live local weather indicator, and popovers for a full monthly calendar and media playback controls.
- **`michal.system-island`:** Top-right cluster displaying Bluetooth, Wi-Fi, Audio volume, Display brightness, and Battery status. Features an expandable 5-tab settings popover and a centered 4-button Power modal.
- **`michal.menu`:** Re-engineered Omarchy menu with dynamic application discovery, categorized actions, fuzzy search, and a personal branding overview.
- **`michal.lock`:** Modern session lock screen with high-contrast typography, PAM password authentication, and custom circular avatar framing.
- **Hyprland Look & Feel:** 14px window corner rounding, 45-degree dual gradient sakura borders, frosted glass blur, and custom cubic bezier transitions (`sakuraEase`).

---

## ⚡ Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/Michal-Nithesh/Sakurazuki.git
cd Sakurazuki
```

### 2. Run the Safe Installer
The installer creates automatic timestamped backups of any pre-existing configuration before deploying:
```bash
./install.sh
```

To test before installing:
```bash
./install.sh --dry-run
```

### 3. Uninstallation
To revert your configuration back to its original state:
```bash
./uninstall.sh
```

---

## ⌨️ Useful Keybindings

| Keybinding | Action |
|---|---|
| `SUPER + RETURN` | Open Ghostty terminal |
| `SUPER + B` | Launch default web browser |
| `SUPER + SHIFT + F` | Open Nautilus file manager |
| `SUPER + C` | Launch Visual Studio Code / Editor |
| `SUPER + Q` | Close active window |
| `SUPER + TAB` | Switch windows (Mission Control style) |
| `SUPER + 1..6` | Switch to workspace 1 through 6 |
| `SUPER + SHIFT + 1..6`| Move active window to workspace 1 through 6 |

---

## 📚 Documentation Index

- [Installation & Prerequisites Guide](docs/installation.md)
- [Component Inventory & IPC Hooks](docs/component-inventory.md)
- [Customization & Color Guide](docs/customization.md)
- [Troubleshooting & FAQ](docs/troubleshooting.md)
- [Complete Screenshot Gallery](docs/screenshots.md)

---

## 📄 License & Credits

- **Desktop Author & Customization:** Michal Nithesh
- **Theme Name:** Sakurazuki 桜月
- **Base System:** [Omarchy Linux](https://omarchy.org/) by Basecamp
- **Compositor:** [Hyprland](https://hyprland.org/) by Vaxry
- **Shell Engine:** [Quickshell](https://quickshell.outfoxxed.me/) by Outfoxxed
- **License:** [MIT License](LICENSE)
