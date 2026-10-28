#!/usr/bin/env bash
set -euo pipefail
# Export hyprland keybinds to JSON for the keybind help panel
hyprctl binds -j 2>/dev/null || echo '[]'
