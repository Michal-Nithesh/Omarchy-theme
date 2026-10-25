# Troubleshooting Guide — Michal × Sakurazuki

This guide addresses common questions, edge cases, and troubleshooting steps when deploying or configuring the Sakurazuki desktop.

---

## 1. Empty Main Menu Categories

### Symptom
Opening a category displays: *"Nothing here yet — Check your search terms or choose another category."*

### Cause & Resolution
1. **JSONC Syntax Errors:** Check `~/.config/omarchy/extensions/omarchy-menu.jsonc` for invalid trailing commas or unquoted keys.
2. **Quickshell Model Desync:** Reload the menu parser cache via CLI:
   ```bash
   omarchy-menu refresh
   ```
3. **Verify Route Existence:** Test summoning specific routes directly:
   ```bash
   omarchy-menu summon apps
   omarchy-menu summon learn
   omarchy-menu summon style
   ```

---

## 2. Missing Icons or Unicode Symbols in Bar / Menu

### Symptom
Icons display as empty rectangles, question marks, or broken squares (e.g. `󰂯`, `󰤨`, `🌸`).

### Cause & Resolution
Ensure **JetBrainsMono Nerd Font** and an emoji font (such as **Noto Color Emoji**) are properly installed on your system:
```bash
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts-emoji
fc-cache -fv
```

---

## 3. Lock Screen Fails to Authenticate

### Symptom
The lock screen loads correctly, but pressing Enter after typing your password returns an error or does nothing.

### Cause & Resolution
The custom `michal.lock` plugin integrates with Linux PAM. Ensure `/etc/pam.d/omarchy-lock-password` exists and has appropriate read permissions:
```bash
ls -l /etc/pam.d/omarchy-lock-password
```
To preview the lock screen safely without engaging PAM:
```bash
omarchy-shell lock preview
# Hide preview
omarchy-shell lock hidePreview
```

---

## 4. Quickshell Not Reflecting Changes

### Symptom
Edits to `.qml` or `.js` files do not take effect in the active shell.

### Cause & Resolution
Quickshell compiles QML into memory. To force a complete shell restart:
```bash
omarchy-shell shell restart
```
Or kill and respawn the Quickshell process:
```bash
killall quickshell && quickshell -c ~/.config/omarchy/shell.json &
```

---

## 5. Folder Icons Reverting to Adwaita / Default

### Symptom
Nautilus or Thunar displays default blue or grey folder icons instead of Sakurazuki plum folders.

### Cause & Resolution
Rebuild your GTK icon theme cache:
```bash
gtk-update-icon-cache -q -t -f ~/.local/share/icons/Sakurazuki
```
Verify your GTK 3/4 settings file specifies `gtk-icon-theme-name = Sakurazuki`.

---

## 6. Weather Not Updating on Center Island

### Symptom
Center island displays `--°` with a loading indicator.

### Cause & Resolution
Center island queries `wttr.in` via `status.sh` or background curl. Check your network connectivity and run `status.sh` directly to inspect API response:
```bash
~/.config/omarchy/plugins/michal.center-island/status.sh
```
