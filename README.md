# eclipsecalis

Polished Arch Linux + Hyprland desktop environment. Dynamic theming from wallpaper, modular Quickshell UI, custom launcher, side panels.

## Quick Start

Method 1 (one-liner):
```
curl -fsSL https://raw.githubusercontent.com/subhan634/eclipsecalis/main/install.py | python3
```

Method 2 (manual):
```
git clone https://github.com/subhan634/eclipsecalis && cd eclipsecalis && python3 install.py
```

Update: `eclipsecalis update`. Doctor: `eclipsecalis doctor`.

## Features

- Dynamic theming via matugen (wallpaper -> full palette, light/dark toggle, hot-apply)
- Per-workspace wallpapers (static/gif/video)
- Quickshell bar, launcher (apps/clipboard/emoji/math/urls/commands), notifications, OSD
- Left/right side panels (chatbot, booru, settings, keybinds; calendar, resources, crypto, weather)
- Hyprland Lua config, workspace rules, complete keybind set

## Keybinds

See `config/hypr/config/binds.lua`. SUPER+D launcher, SUPER+N right panel, SUPER+M left panel, SUPER+T theme toggle, SUPER+W wallpaper.

## License

MIT
