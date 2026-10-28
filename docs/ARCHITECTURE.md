# Architecture — eclipsecalis

## Overview

eclipsecalis is a single product: an Arch Linux + Hyprland desktop environment.
All UI is Quickshell (QML). Theming is driven by matugen from the current wallpaper.
One Python installer/updater. One CLI (`eclipsecalis`).

## Data flow

```
wallpaper change (workspace or global)
  -> scripts/wallpaper-apply.sh
  -> matugen image <wallpaper>  (extracts frame if video via ffmpeg)
  -> writes ~/.cache/eclipsecalis/colors.json
  -> templates/ rendered to config targets (kitty, gtk, qt, btop, cava, hypr borders)
  -> Quickshell FileView watches colors.json -> Theme singleton updates -> all widgets reactive
  -> hyprctl keyword for borders/shadows
```

## Directories

- `config/hypr/` — Lua modules: monitors, binds, animations, input, windowrules, workspacerules, autostart, env, plus `custom/` override dir (never overwritten by updater).
- `config/quickshell/` — `shell.qml` bootstrap; `theme/Theme.qml`; `services/` singletons; `bar/`, `launcher/`, `panels/{left,right}/`, `widgets/`.
- `config/kitty/` — templated config with live color reload.
- `templates/` — matugen templates consumed by the theme engine.
- `scripts/` — wallpaper, theme-apply, screenshot, record, clipboard, keybinds-export.
- `installer/` — Python modules: ui, packages, steps, checks, backup.
- `bin/eclipsecalis` — CLI.

## Single source of truth

`~/.cache/eclipsecalis/colors.json` is the only color source. Quickshell watches it.
All other targets (GTK CSS, qt6ct, kitty) are rendered from `templates/` by `scripts/theme-apply.py`.

## Per-workspace wallpapers

Mapping stored in `~/.config/eclipsecalis/workspaces.json`: `{ "1": {wallpaper, mode}, ... }`.
On workspace change, Hyprland execs `scripts/workspace-wallpaper.sh <ws>` which switches
wallpaper (crossfade where possible) and triggers theme regeneration (cached by wallpaper hash).

## Light/dark toggle

`eclipsecalis toggle` (and keybind + bar button) flips `mode` in `~/.config/eclipsecalis/settings.json`,
regenerates palette with matugen `--mode dark|light`, re-renders all targets, hot-applies.
No shell restart. Target perceived latency < 300 ms.

## Quickshell module layout

- `shell.qml` — ShellRoot, instantiates Bar per monitor, Launcher, panels, OSD, notifications.
- `theme/Theme.qml` — singleton exposing color tokens, spacing, typography, radius.
- `services/` — Wallpaper, Weather, Crypto, Mpris, Network, Battery, Notifications, Settings, Workspaces, Theme (file watcher).
- `widgets/` — reusable components (Button, Card, Icon, etc.).
- `bar/` — Bar.qml + widget components.
- `launcher/` — Launcher.qml with prefix modes.
- `panels/left/`, `panels/right/`.

## Settings

`~/.config/eclipsecalis/settings.json` — all user options. Quickshell Settings service reads/writes.
Installer writes defaults. Updater preserves user overrides in `custom/` and `settings.json`.

## Migrations

`migrations/NNN_*.py` run by updater in order, tracked by `~/.local/state/eclipsecalis/migrations.json`.
