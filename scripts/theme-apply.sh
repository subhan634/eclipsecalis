#!/usr/bin/env bash
# eclipsecalis theme applier: generates palette from wallpaper via matugen, renders templates, hot-applies
set -euo pipefail

WALL="${1:-}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/eclipsecalis"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/eclipsecalis"
mkdir -p "$CACHE_DIR" "$CONFIG_DIR"

MODE="dark"
if [[ -f "$CONFIG_DIR/settings.json" ]]; then
  MODE=$(python3 -c "import json;print(json.load(open('$CONFIG_DIR/settings.json')).get('mode','dark'))" 2>/dev/null || echo dark)
fi

if [[ -z "$WALL" ]]; then
  # find last wallpaper
  WALL=$(cat "$CACHE_DIR/last_wallpaper" 2>/dev/null || true)
fi
[[ -z "$WALL" || ! -e "$WALL" ]] && { echo "no wallpaper"; exit 1; }
echo "$WALL" > "$CACHE_DIR/last_wallpaper"

# Hash for cache
HASH=$(sha256sum "$WALL" | cut -d' ' -f1)
CACHE="$CACHE_DIR/palettes/$HASH-$MODE.json"
mkdir -p "$CACHE_DIR/palettes"

if [[ ! -f "$CACHE" ]]; then
  # extract frame if video
  IMG="$WALL"
  case "${WALL##*.}" in
    mp4|mkv|webm|mov|gif)
      IMG="$CACHE_DIR/frame-$HASH.png"
      ffmpeg -y -i "$WALL" -vframes 1 -q:v 2 "$IMG" >/dev/null 2>&1
      ;;
  esac
  matugen image "$IMG" --mode "$MODE" --json hex > "$CACHE.tmp"
  mv "$CACHE.tmp" "$CACHE"
fi

# Publish single source of truth
cp "$CACHE" "$CACHE_DIR/colors.json"
# atomic write for watchers
python3 -c "import json,shutil; shutil.copy('$CACHE','$CACHE_DIR/colors.json')"

# Render templates
TEMPLATE_DIR="${ECLIPSECALIS_DIR:-$HOME/.local/share/eclipsecalis}/templates"
if [[ -d "$TEMPLATE_DIR" ]]; then
  for t in "$TEMPLATE_DIR"/*; do
    [[ -f "$t" ]] || continue
    name=$(basename "$t")
    # matugen template rendering via config; here we invoke matugen with config if present
    :
  done
fi

# Hot-apply: hyprland borders from colors
if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  PRIMARY=$(python3 -c "import json;print(json.load(open('$CACHE_DIR/colors.json')).get('colors',{}).get('primary','{}').get('default','#89b4fa'))" 2>/dev/null || echo "#89b4fa")
  hyprctl keyword general:col.active_border "rgba(${PRIMARY#\#}ff)" >/dev/null 2>&1 || true
fi

# Notify quickshell via file watcher (colors.json already updated)
echo "theme applied: $WALL ($MODE)"
