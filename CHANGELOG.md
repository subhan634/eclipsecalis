# Changelog

## [0.1.1] - 2026-10-28
### Added
- Wallhaven browser integrated into wallpaper selector (SUPER+W)
- One-click wallpaper download from Wallhaven.cc
- WallhavenService singleton for API communication
- WallhavenBrowser QML component with thumbnail grid, filters, and download overlay
- API key management (stored in secrets.json, chmod 600)
- SFW-only mode by default; NSFW requires explicit API key opt-in
- Rate limiting (45 req/min) with friendly error messages
- Thumbnail caching to disk (~/.cache/eclipsecalis/wallhaven/)
- Atomic downloads with .part -> rename pattern
- Keybind: SUPER+Shift+W to toggle Wallhaven view
- Keybind: Tab inside selector to switch between Local and Wallhaven views

## [0.1.0] - 2026-10-28
### Added
- Initial release: Hyprland Lua config, dynamic theming via matugen, Quickshell UI skeleton, launcher, panels, installer, updater, CLI.