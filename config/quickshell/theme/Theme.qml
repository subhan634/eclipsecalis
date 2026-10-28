pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: theme

    // Reactive color tokens loaded from colors.json
    property var colors: ({})
    property color primary: colors.colors ? colors.colors.primary.default : "#89b4fa"
    property color secondary: colors.colors ? colors.colors.secondary.default : "#a6e3a1"
    property color tertiary: colors.colors ? colors.colors.tertiary.default : "#f9e2af"
    property color surface: colors.colors ? colors.colors.surface.default : "#1e1e2e"
    property color surfaceVariant: colors.colors ? colors.colors.surface_variant.default : "#313244"
    property color onSurface: colors.colors ? colors.colors.on_surface.default : "#cdd6f4"
    property color error: colors.colors ? colors.colors.error.default : "#f38ba8"
    property int radius: 12
    property int spacing: 8
    property string fontFamily: "JetBrainsMono Nerd Font"

    // Watch colors.json
    property var watcher: FileView {
        path: Qt.resolvedUrl("file://" + (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/eclipsecalis/colors.json")
        onFileChanged: {
            try { theme.colors = JSON.parse(text()) } catch (e) {}
        }
    }
}
EOF
echo done