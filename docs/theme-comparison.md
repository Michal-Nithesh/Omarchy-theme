# Theme Comparison: Sakurazuki vs. Night Owl

A comprehensive comparison matrix between the two flagship desktop themes included in the **Omarchy Theme Collection**.

---

## 1. At a Glance Comparison

| Feature | Sakurazuki | Night Owl |
|---|---|---|
| **Aesthetic Origin** | Japanese Cherry Blossom Moonlight | Sarah Drasner's Night Owl Theme |
| **Primary Atmosphere** | Ethereal, floral, dark cherry blossom | Deep navy, developer-focused, technical clarity |
| **Dominant Background** | `#14111A` (Deep plum / dark violet) | `#011627` (Deep midnight navy) |
| **Primary Text** | `#F5EEF8` (Soft pink-tinted white) | `#D6DEEB` (Crisp off-white / silver) |
| **Primary Accent** | `#FFB7C5` (Sakura blossom pink) | `#7FDBCA` (Vibrant cyan / mint teal) |
| **Secondary Accent** | `#E06B8B` (Cherry rose) | `#82AAFF` (Steel blue / indigo) |
| **Error / Attention** | `#E26D5C` (Terracotta red) | `#FF6363` / `#FF2C83` (Vibrant coral / magenta) |
| **Workspace Indicators** | Japanese Kanji (`一 二 三 四 五 六`) | Zero-padded Arabic (`01 02 03 04 05 ... 10`) |
| **Launcher Emblem** | `🌸` (Cherry Blossom) | `🦉` (Night Owl) |
| **Hyprland Active Border**| `rgba(ffb7c5ff) rgba(e06b8bff) 45deg` | `rgba(7fdbcaff) rgba(82aaffff) 45deg` |
| **Hyprland Inactive Border** | `rgba(282233cc)` (Muted plum) | `rgba(1d3b53cc)` (Muted navy) |
| **Quickshell Workspace Plugin** | `michal.workspaces` | `nightowl.workspaces` |
| **Icon Theme** | Custom `Sakurazuki` folder/system pack | `Yaru-blue-dark` |
| **Screensaver Feature** | Foot terminal screensaver script included | Core compositor idle lock integration |

---

## 2. Color Palette Token Mapping

Both themes define semantic tokens compatible with the Omarchy theming engine:

| Semantic Token | Sakurazuki Hex | Night Owl Hex | Visual Purpose |
|---|---|---|---|
| `background` | `#14111A` | `#011627` | Main desktop & terminal background |
| `surface` | `#1E1A26` | `#0b2942` | Cards, popovers, bars, and panels |
| `surface_bright` | `#2D2738` | `#1d3b53` | Hovered surfaces and elevated components |
| `selection` | `#3D334D` | `#1d3b53` | Text selection and highlighted items |
| `foreground` | `#F5EEF8` | `#D6DEEB` | Primary typography and headings |
| `muted` | `#8C8299` | `#637777` | Inactive captions, comments, placeholders |
| `accent` | `#FFB7C5` | `#7FDBCA` | Primary focus indicators and active elements |
| `accent_secondary` | `#E06B8B` | `#82AAFF` | Secondary buttons and functional highlights |
| `border` | `#3D334D` | `#1d3b53` | Window borders and UI separators |
| `border_active` | `#FFB7C5` | `#7FDBCA` | Active window focus highlight |
| `error` | `#E26D5C` | `#FF6363` | Warnings, critical prompts, alert badges |
| `success` | `#85E89D` | `#ADDB67` | Success badges, battery charged state |

---

## 3. Workspace Presentation Architecture

One of the most noticeable visual differences between Sakurazuki and Night Owl is the treatment of workspace indicators:

### Sakurazuki Workspace Indicators
- **Numbering System**: Traditional Japanese Kanji numerals.
- **Sequence**: `一` (1), `二` (2), `三` (3), `四` (4), `五` (5), `六` (6).
- **Active State**: Highlighted with a luminous pink pill (`#FFB7C5`) on a deep plum background (`#14111A`).
- **Inactive State**: Soft muted lavender (`#8C8299`).
- **Implementation**: Handled by the custom Quickshell plugin `michal.workspaces`.

### Night Owl Workspace Indicators
- **Numbering System**: Strict zero-padded two-digit Arabic numerals.
- **Sequence**: `01` `02` `03` `04` `05` `06` `07` `08` `09` `10`.
- **Active State**: Vibrant cyan pill (`#7FDBCA`) with dark navy numeral typography (`#011627`).
- **Inactive State**: Subtle steel blue-gray (`#5f7e97`) inside translucent navy badges.
- **Implementation**: Handled by the standalone Quickshell plugin `nightowl.workspaces` (`Night-Owl/config/omarchy/plugins/nightowl.workspaces/`).

---

## 4. Desktop Branding and Identity

### Desktop Menu & App Drawer
- **Sakurazuki**:
  - Launcher button: `🌸 Sakurazuki`
  - About banner: Cherry blossom art with Japanese title aesthetic
  - Header badge: Pink blossom motif
- **Night Owl**:
  - Launcher button: `🦉 Night Owl`
  - About banner: Minimalist developer owl mascot with Sarah Drasner palette attribution
  - Header badge: Midnight owl motif

### Window Manager Borders (Hyprland)
- **Sakurazuki**:
  - Dynamic gradient rotating from soft blossom pink (`#FFB7C5`) to deep cherry rose (`#E06B8B`) at 45 degrees.
  - Inactive borders: dark plum (`#282233`).
- **Night Owl**:
  - Dynamic gradient rotating from mint teal (`#7FDBCA`) to steel indigo (`#82AAFF`) at 45 degrees.
  - Inactive borders: muted navy blue (`#1D3B53`).

---

## 5. Application Coverage Matrix

Both distributions include templates across all major Linux desktop applications:

| Application | Sakurazuki Configuration | Night Owl Configuration |
|---|---|---|
| **Hyprland** | `config/hypr/looknfeel.conf` | `config/hypr/looknfeel.conf` |
| **Waybar** | `config/omarchy/themes/sakurazuki/waybar.css` | `config/omarchy/themes/night-owl/waybar.css` |
| **Ghostty** | `config/ghostty/config` | `config/ghostty/config` |
| **Foot** | `config/omarchy/foot/screensaver.ini` | `config/omarchy/themes/night-owl/foot.ini` |
| **Alacritty** | `config/omarchy/themes/sakurazuki/alacritty.toml`| `config/omarchy/themes/night-owl/alacritty.toml` |
| **Kitty** | `config/omarchy/themes/sakurazuki/kitty.conf` | `config/omarchy/themes/night-owl/kitty.conf` |
| **GTK 3.0 / 4.0** | `config/omarchy/themes/sakurazuki/gtk.css` | `config/omarchy/themes/night-owl/gtk.css` |
| **Mako / SwayOSD**| `mako.ini` & `swayosd.css` | `mako.ini` & `swayosd.css` |
| **Neovim** | `neovim.lua` (Sakura colorscheme) | `neovim.lua` (Night Owl colorscheme) |
| **VSCode** | `vscode.json` (Sakurazuki palette) | `vscode.json` (Sarah Drasner official tokens) |
| **Btop** | `btop.theme` | `btop.theme` |
| **Launchers** | `wofi.css`, `walker.css` | `wofi.css`, `walker.css` |
| **Lock Screen** | `michal.lock` Quickshell plugin + `hyprlock.conf` | Dedicated `hyprlock.conf` + Quickshell lock |
