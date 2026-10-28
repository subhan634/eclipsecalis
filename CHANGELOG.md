# Changelog

## [0.1.0] - 2026-10-28
### Added
- Initial release: Hyprland Lua config, dynamic theming via matugen, Quickshell UI skeleton, launcher, panels, installer, updater, CLI.
EOF
# verify a sample of package names
for p in hyprland quickshell matugen mpvpaper kitty fish; do
  pacman -Si "$p" >/dev/null 2>&1 && echo "OK official: $p" || echo "MISSING official: $p"
done
echo "---aur (paru may not be installed)---"
command -v paru >/dev/null 2>&1 && paru -Si awww 2>/dev/null | head -1 || echo "paru not available; skip aur check"