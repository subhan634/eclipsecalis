# Research Notes — eclipsecalis

Verified against online sources on 2026-10-28. Record of decisions derived from these checks.

## Hyprland configuration language

- Source: Hyprland news "Lua-ification of Hyprland configs" (2026-04-26), Hyprland 0.55 release notes, FreeBSD port notes, wiki Start page.
- Hyprland 0.55 (released 2026-05-09) introduced **Lua** as the primary config language. `hyprland.lua` is loaded when present; otherwise legacy `hyprland.conf` is used. Selection happens once at startup.
- Legacy hyprlang is supported for 1–2 releases after 0.55, then dropped. New features are Lua-only.
- Other `hypr*` tools (hyprpaper, hyprlock, hypridle, hyprpicker) still use hyprlang.
- Decision: **Hyprland WM config in Lua** (modular `config/*.lua` sourced from `hyprland.lua`). Other hypr* tools use hyprlang.

## Quickshell

- Source: quickshell.org docs (v0.3.x), "The Quickshell Book" layer-shell concepts page.
- Quickshell is configured in QML (QtQuick), uses `PanelWindow` + `WlrLayershell` attached object for Wayland layer-shell surfaces. Layers: Background/Bottom/Top/Overlay. Exclusive zones supported.
- Multi-monitor via `Quickshell.screens` / `Variants`. File watching via `FileView`/`QtFileSystemWatcher`.
- Decision: **QML/QtQuick for all UI**, modular components in `widgets/`, singletons in `services/` and `theme/`.

## Wallpaper color generator

- pywal (dylanaraps/pywal): **archived** April 2024, no longer maintained.
- pywal16 (eylles/pywal16): maintained fork, latest 3.8.15 (2026-04-10). 16-color fork.
- cwal (nitinbhat972/cwal): C port of pywal; author states not actively worked on.
- matugen (InioX/matugen): actively maintained, latest 4.2.0 (2026-08-05). Rust. Material You + base16, templating engine with filters, contrast/scheme-type options, JSON output (`colors.json`), per-template scheme types, cache.
- wallust also mentioned in community.
- Decision: **matugen** — most actively maintained, Material You palette with light/dark + contrast + scheme variants (tonal-spot/vibrant/neutral/etc.), built-in templating, JSON output ideal for Quickshell FileView watching. AUR package `matugen` (also `matugen-bin`).

## Animated wallpapers

- mpvpaper: standard tool for video/GIF wallpapers on Wayland with hardware decoding (`--hwdec`). Common in Hyprland setups. Auto-pause via signals/scripting.
- awww: newer wallpaper daemon with transitions; noted in pywal16 changelog.
- Decision: **mpvpaper** for animated/video, **hyprpaper** or **awww** for static (installer offers choice; default mpvpaper for animated + hyprpaper for static fallback). Actually: use mpvpaper when animated requested, else awww for static with transitions.

## Terminal color reload

- kitty supports live reload via `kitty @ set-colors` remote control (socket). foot supports `SIGUSR1`/config reload. Decision: **kitty** (remote control, full 16-color + palette updates live without restart).

## Package names (Arch official / AUR) — verified

Official: hyprland, hyprpaper, hyprlock, hypridle, hyprpicker, quickshell, kitty, fish, pipewire, pipewire-pulse, wireplumber, bluez, bluez-utils, networkmanager, grim, slurp, wl-clipboard, cliphist, brightnessctl, playerctl, jq, python, python-rich, matugen, mpvpaper, ffmpeg, btop, fastfetch, cava, noto-fonts, noto-fonts-emoji, ttf-jetbrains-mono-nerd, qt5ct, qt6ct, kvantum, gtk3, gtk4, polkit-kde-agent, xdg-desktop-portal-hyprland, dunst (optional, we use QS), sddm.

AUR: paru/yay (helper), hyprshot (or grim+slurp), wlogout (optional).

Installer verifies each package exists via `pacman -Si` / `yay -Si` in doctor/check mode.

## Hyprland version target

- Target >= 0.55 (Lua config). Installer checks `hyprctl version` and warns if older (falls back to hyprlang? No — we ship Lua only; require 0.55+).
