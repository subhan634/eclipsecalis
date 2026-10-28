"""eclipsecalis installer packages."""
OFFICIAL = [
    "hyprland", "hyprpaper", "hyprlock", "hypridle", "hyprpicker",
    "quickshell", "kitty", "fish", "pipewire", "pipewire-pulse", "wireplumber",
    "bluez", "bluez-utils", "networkmanager", "grim", "slurp", "wl-clipboard",
    "cliphist", "brightnessctl", "playerctl", "jq", "python", "python-rich",
    "matugen", "mpvpaper", "ffmpeg", "btop", "fastfetch", "cava",
    "noto-fonts", "noto-fonts-emoji", "ttf-jetbrains-mono-nerd",
    "qt5ct", "qt6ct", "kvantum", "gtk3", "gtk4", "polkit-kde-agent",
    "xdg-desktop-portal-hyprland",
]
AUR = ["paru", "hyprshot", "awww"]
CATEGORIES = {"core": OFFICIAL[:10], "theming": ["matugen", "mpvpaper", "awww"]}
