import QtQuick
import Quickshell

PanelWindow {
    id: rightPanel
    anchors { top: true; bottom: true; right: true }
    implicitWidth: 380
    visible: false
    color: Theme.surface
    // tabs: calendar, notifications, media, resources, crypto, weather
}
EOF
echo done