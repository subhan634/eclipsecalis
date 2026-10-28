-- Window rules (Hyprland 0.55+ Lua syntax)
local rules = {
  { match = { class = "firefox" },      workspace = 2,  silent = true },
  { match = { class = "chromium" },     workspace = 2,  silent = true },
  { match = { class = "Brave-browser" },workspace = 2,  silent = true },
  { match = { class = "Code" },         workspace = 3,  silent = true },
  { match = { class = "kitty" },       workspace = 3,  silent = true },
  { match = { class = "Alacritty" },   workspace = 3,  silent = true },
  { match = { class = "Spotify" },     workspace = 4,  silent = true },
  { match = { class = "btop" },        workspace = 5,  silent = true },
  { match = { class = "discord" },     workspace = 6,  silent = true },
  { match = { class = "vesktop" },     workspace = 6,  silent = true },
  { match = { class = "TelegramDesktop" }, workspace = 6, silent = true },
  { match = { class = "Steam" },       workspace = 7,  silent = true },
  { match = { class = "lutris" },      workspace = 7,  silent = true },
  { match = { class = "Thunar" },      workspace = 8,  silent = true },
  { match = { class = "Nautilus" },    workspace = 8,  silent = true },
}

for _, r in ipairs(rules) do
  local m = r.match or {}
  local parts = {}
  for k, v in pairs(m) do parts[#parts+1] = k .. ":" .. v end
  local expr = table.concat(parts, " ")
  if r.workspace then
    hl.windowrule("workspace " .. r.workspace .. (r.silent and " silent" or ""), expr)
  end
end

-- Floating rules
hl.windowrule("float, class:^(pavucontrol|nm-connection-editor|blueman-manager)$")
hl.windowrule("float, title:^(Open File|Save File|Choose Files)$")
hl.windowrule("size 900 600, class:^(pavucontrol)$")
hl.windowrule("center, class:^(pavucontrol)$")

-- Opacity
hl.windowrule("opacity 0.95 0.9, class:^(kitty|Alacritty)$")
hl.windowrule("opacity 1.0 1.0, fullscreen:1")
hl.windowrule("opacity 1.0 1.0, focus:0")

-- XWayland
hl.windowrule("xwayland, class:^(.*\\.exe)$")
hl.windowrule("nofocus, class:^(.*\\.exe)$, floating:1")
