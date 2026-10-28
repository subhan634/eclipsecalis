#!/usr/bin/env bash
# eclipsecalis wallpaper applier: switches wallpaper (static/gif/video) and triggers theme regen
set -euo pipefail

WS="${1:-global}"
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eclipsecalis"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/eclipsecalis"
mkdir -p "$STATE_DIR" "$CACHE_DIR"

MAP="$STATE_DIR/workspaces.json"
[[ -f "$MAP" ]] || echo '{}' > "$MAP"

# Resolve wallpaper for workspace
WALL=""
MODE="static"
if [[ "$WS" == "global" ]]; then
  WALL=$(python3 -c "import json,sys; d=json.load(open('$MAP')); print(d.get('global',{}).get('wallpaper',''))" 2>/dev/null || true)
else
  WALL=$(python3 -c "import json,sys; d=json.load(open('$MAP')); print(d.get('$WS',{}).get('wallpaper',''))" 2>/dev/null || true)
  MODE=$(python3 -c "import json,sys; d=json.load(open('$MAP')); print(d.get('$WS',{}).get('mode','static'))" 2>/dev/null || echo static)
fi

# Fallback to default wallpaper
if [[ -z "$WALL" || ! -e "$WALL" ]]; then
  WALL=$(find "${XDG_CONFIG_HOME:-$HOME/.config}/eclipsecalis/wallpapers" -type f 2>/dev/null | head -1)
fi
[[ -z "$WALL" ]] && { echo "no wallpaper found"; exit 0; }

# Kill previous animated wallpaper
pkill -f mpvpaper 2>/dev/null || true

case "$MODE" in
  video|animated)
    mpvpaper -o "--loop --hwdec=auto --no-audio --panscan=1.0" '*' "$WALL" &
    ;;
  gif)
    # mpvpaper handles gif too
    mpvpaper -o "--loop --hwdec=auto --no-audio" '*' "$WALL" &
    ;;
  *)
    # static: use awww if available else hyprpaper
    if command -v awww >/dev/null 2>&1; then
      awww img "$WALL" --transition-type fade --transition-duration 0.6
    else
      hyprctl hyprpaper preload "$WALL" 2>/dev/null || true
      hyprctl hyprpaper wallpaper ",$WALL" 2>/dev/null || true
    fi
    ;;
esac

# Regenerate theme (cached by hash)
exec "$(dirname "$0")/theme-apply.sh" "$WALL"
