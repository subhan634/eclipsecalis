-- Per-workspace layout overrides (optional)
-- hl.workspace("1, layout:master")
-- hl.workspace("7, layout:dwindle, gaps:0")
-- Gaming workspace: no gaps, no rounding via windowrule on Steam/Lutris handled above

-- Per-workspace wallpaper mapping is handled by scripts/workspace-wallpaper.sh
-- triggered on workspace change via bind (below) and exec-once daemon
hl.bind("SUPER, 1, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 1")
hl.bind("SUPER, 2, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 2")
hl.bind("SUPER, 3, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 3")
hl.bind("SUPER, 4, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 4")
hl.bind("SUPER, 5, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 5")
hl.bind("SUPER, 6, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 6")
hl.bind("SUPER, 7, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 7")
hl.bind("SUPER, 8, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 8")
hl.bind("SUPER, 9, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 9")
hl.bind("SUPER, 0, exec, ~/.config/eclipsecalis/scripts/workspace-wallpaper.sh 10")
