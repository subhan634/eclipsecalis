local mod = "SUPER"

hl.bind = hl.bind or {}

-- Apps
hl.bind(mod .. ", Return, exec, kitty")
hl.bind(mod .. ", B, exec, xdg-open https://")
hl.bind(mod .. ", E, exec, thunar")
hl.bind(mod .. ", D, exec, quickshell ipc call launcher toggle")
hl.bind(mod .. " SHIFT, E, exec, quickshell ipc call launcher emoji")
hl.bind(mod .. ", N, exec, quickshell ipc call panel right toggle")
hl.bind(mod .. ", M, exec, quickshell ipc call panel left toggle")
hl.bind(mod .. ", V, exec, quickshell ipc call clipboard toggle")
hl.bind(mod .. ", W, exec, quickshell ipc call wallpaper open")
hl.bind(mod .. ", L, exec, hyprlock")
hl.bind(mod .. ", T, exec, eclipsecalis toggle")
hl.bind(mod .. ", F, fullscreen, 1")
hl.bind(mod .. ", Q, killactive")
hl.bind(mod .. " SHIFT, Q, exit")
hl.bind(mod .. ", Space, togglefloating")
hl.bind(mod .. ", P, pseudo")
hl.bind(mod .. ", J, togglesplit")

-- Workspaces
for i = 1, 10 do
  hl.bind(mod .. ", " .. i, "workspace", i)
  hl.bind(mod .. " SHIFT, " .. i, "movetoworkspace", i)
end
hl.bind(mod .. ", mouse_down, workspace, e+1")
hl.bind(mod .. ", mouse_up, workspace, e-1")
hl.bind(mod .. " CTRL, right, workspace, e+1")
hl.bind(mod .. " CTRL, left, workspace, e-1")

-- Special workspace (scratchpad terminal)
hl.bind(mod .. ", grave, togglespecialworkspace, magic")
hl.bind(mod .. " SHIFT, grave, movetoworkspace, special:magic")

-- Window focus
hl.bind(mod .. ", left, movefocus, l")
hl.bind(mod .. ", right, movefocus, r")
hl.bind(mod .. ", up, movefocus, u")
hl.bind(mod .. ", down, movefocus, d")
hl.bind(mod .. " SHIFT, left, movewindow, l")
hl.bind(mod .. " SHIFT, right, movewindow, r")
hl.bind(mod .. " SHIFT, up, movewindow, u")
hl.bind(mod .. " SHIFT, down, movewindow, d")

-- Resize
hl.bind(mod .. " CTRL, right, resizeactive, 40 0")
hl.bind(mod .. " CTRL, left, resizeactive, -40 0")
hl.bind(mod .. " CTRL, up, resizeactive, 0 -40")
hl.bind(mod .. " CTRL, down, resizeactive, 0 40")

-- Media
hl.bind("", "XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
hl.bind("", "XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
hl.bind("", "XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
hl.bind("", "XF86AudioPlay, exec, playerctl play-pause")
hl.bind("", "XF86AudioNext, exec, playerctl next")
hl.bind("", "XF86AudioPrev, exec, playerctl previous")
hl.bind("", "XF86MonBrightnessUp, exec, brightnessctl set 5%+")
hl.bind("", "XF86MonBrightnessDown, exec, brightnessctl set 5%-")

-- Screenshots
hl.bind("", "Print, exec, ~/.config/eclipsecalis/scripts/screenshot.sh region")
hl.bind(mod .. ", Print, exec, ~/.config/eclipsecalis/scripts/screenshot.sh full")
hl.bind(mod .. " SHIFT, Print, exec, ~/.config/eclipsecalis/scripts/screenrecord.sh toggle")

-- Mouse binds
hl.bindm(mod .. ", mouse:272, movewindow")
hl.bindm(mod .. ", mouse:273, resizewindow")
