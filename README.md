# ii-material-sddm

An SDDM login theme built with **Material Design 3**, inspired by the `ii` lockscreen from [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) — a set of usability-first Hyprland dotfiles.

![preview](preview.png)

---

## Features

- Material Design 3 color system with full customization via `colors.json`
- Analog clock with large display
- Blurred wallpaper background with configurable overlay
- Bottom toolbar with session selector, user selector and system actions
- Virtual keyboard support
- Multi-language support via `translations.js`
- Qt6 / SDDM 0.21+

---

## Dependencies

- `sddm` ≥ 0.21
- `qt6-declarative`
- `qt6-5compat` (for blur effects)
- Font: **Google Sans Flex** (optional, falls back to system font)

---

## Installation

### Manual

```bash
git clone https://github.com/ToRvaLDz/ii-material-sddm
sudo cp -r ii-material-sddm /usr/share/sddm/themes/
```

Then set the theme in `/etc/sddm.conf`:

```ini
[Theme]
Current=ii-material-sddm
```

### Arch Linux (AUR)

```bash
yay -S ii-material-sddm-git
```

### Script

```bash
git clone https://github.com/ToRvaLDz/ii-material-sddm
cd ii-material-sddm
chmod +x install.sh
sudo ./install.sh
```

---

## Configuration

Edit `theme.conf` to customize the theme:

```ini
[General]
Background=Backgrounds/default.jpg
ColorsFile=colors.json
BlurRadius=100
BlurEnabled=true
BlurExtraZoom=1.1
BlurOverlayOpacity=0.3
ClockFontFamily=Google Sans Flex
ClockFontSize=90
ClockFontWeight=350
FontFamily=Google Sans Flex Medium
FontSize=15
```

### Matugen integration (automatic colors + wallpaper)

The theme automatically reads colors and wallpaper from [matugen](https://github.com/InioX/matugen) if you use it.

**Colors** are loaded at runtime from:
```
~/.local/state/quickshell/user/generated/colors.json
```

**Wallpaper** is loaded from:
```
~/.local/state/quickshell/user/generated/wallpaper/path.txt
```

After installing, run the sync script whenever you change your wallpaper:

```bash
sudo sddm-matugen-sync
```

This copies the current colors and wallpaper into the SDDM theme directory so they're available before login. To automate it, add the command to your wallpaper-change script or matugen hook.

You can override the default paths in `theme.conf`:

```ini
WallpaperPathFile=/path/to/wallpaper/path.txt
WallpaperConfig=/path/to/config.json
```

### Colors (manual)

Colors are defined in `colors.json` using the Material Design 3 color token system. You can generate a custom palette with tools like [Material Theme Builder](https://material-foundation.github.io/material-theme-builder/) or [matugen](https://github.com/InioX/matugen).

---

## Credits

- Lockscreen design inspired by the `ii` theme from [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)

---

## License

GPL-3.0
