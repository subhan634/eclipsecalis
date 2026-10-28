# eclipsecalis

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Arch%20Linux-blue.svg)]()
[![WM](https://img.shields.io/badge/WM-Hyprland-58E1FF.svg)]()
[![Open Source](https://img.shields.io/badge/Open%20Source-%E2%9D%A4-red.svg)](https://github.com/subhan634/eclipsecalis)
[![Free](https://img.shields.io/badge/Price-Free-brightgreen.svg)]()

> A polished, fully open-source Arch Linux + Hyprland desktop environment. Dynamic theming from wallpaper, modular Quickshell UI, custom launcher, side panels.

## ✨ Features

- 🎨 Dynamic theming via matugen (wallpaper → full palette, light/dark toggle, hot-apply)
- 🖼️ Per-workspace wallpapers (static / gif / video)
- 🚀 Quickshell bar, launcher (apps / clipboard / emoji / math / urls / commands), notifications, OSD
- 📐 Left/right side panels (chatbot, booru, settings, keybinds; calendar, resources, crypto, weather)
- ⚙️ Hyprland Lua config, workspace rules, complete keybind set
- 🌐 **Wallhaven browser** with one-click download, thumbnail grid, search filters, and API key management

## 🚀 Quick Start

**One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/subhan634/eclipsecalis/main/install.py | python3
```

**Manual:**
```bash
git clone https://github.com/subhan634/eclipsecalis && cd eclipsecalis && python3 install.py
```

Update: `eclipsecalis update` · Doctor: `eclipsecalis doctor` · Uninstall: `eclipsecalis uninstall`

## ⌨️ Keybinds

```
┌────────────────────┬──────────────────────────────────────┐
│ SUPER + D          │ Open launcher                        │
│ SUPER + N          │ Right panel                          │
│ SUPER + M          │ Left panel                           │
│ SUPER + T          │ Theme toggle (light/dark)            │
│ SUPER + W          │ Wallpaper picker                     │
│ SUPER + SHIFT + W  │ Wallhaven browser toggle             │
│ Tab (inside picker)│ Switch Local / Wallhaven views       │
└────────────────────┴──────────────────────────────────────┘
```

Full keybind set: `config/hypr/config/binds.lua`

## 🌐 Wallhaven Browser

- **SUPER+W** opens the wallpaper selector with local wallpapers
- **SUPER+Shift+W** toggles the Wallhaven browser view
- **Tab** inside the selector switches between Local and Wallhaven views
- **No API key needed** for SFW wallpapers (default mode)
- **API key** unlocks sketchy/NSFW content (optional, stored in `~/.config/eclipsecalis/secrets.json` with chmod 600)
- Get your free API key: `eclipsecalis wallhaven api-key` (opens wallhaven.cc/settings/account)
- Download to `~/.config/eclipsecalis/wallpapers/custom/`

## 📜 License

MIT — free and open source. See [LICENSE](LICENSE).

## 🤝 Contributing

PRs welcome. Issues and feature requests on GitHub.