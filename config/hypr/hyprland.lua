-- eclipsecalis Hyprland entry point (Lua, Hyprland >= 0.55)
-- Modular: each config/*.lua defines one concern. custom/*.lua is user overrides (never overwritten by updater).

local cfg = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local root = cfg .. "/hypr"

dofile(root .. "/config/env.lua")
dofile(root .. "/config/monitors.lua")
dofile(root .. "/config/input.lua")
dofile(root .. "/config/decoration.lua")
dofile(root .. "/config/animations.lua")
dofile(root .. "/config/layouts.lua")
dofile(root .. "/config/binds.lua")
dofile(root .. "/config/windowrules.lua")
dofile(root .. "/config/workspacerules.lua")
dofile(root .. "/config/autostart.lua")

-- User overrides (optional)
local f = io.open(root .. "/custom/init.lua", "r")
if f then f:close(); dofile(root .. "/custom/init.lua") end
