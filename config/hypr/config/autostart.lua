hl.exec_once = hl.exec_once or {}
local execs = {
  "quickshell -c ~/.config/quickshell/eclipsecalis",
  "hypridle",
  "hyprpaper",
  "~/.config/eclipsecalis/scripts/wallpaper-daemon.sh",
  "/usr/lib/polkit-kde-authentication-agent-1",
  "nm-applet --indicator",
  "blueman-applet",
  "wl-paste --type text --watch cliphist store",
  "wl-paste --type image --watch cliphist store",
  "~/.config/eclipsecalis/scripts/autostart-apps.sh",
}
for _, c in ipairs(execs) do hl.exec_once(c) end
