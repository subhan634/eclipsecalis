-- Monitors: auto-detect; edit or override in custom/monitors.lua
hl.monitor = hl.monitor or {}
-- Default: preferred resolution, auto position, 1x scale
hl.monitor("", "preferred", "auto", 1)
-- Fractional scaling example (uncomment):
-- hl.monitor("eDP-1", "2560x1440@120", "0x0", 1.5)
