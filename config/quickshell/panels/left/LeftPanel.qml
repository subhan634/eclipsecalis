import QtQuick
import Quickshell

PanelWindow {
    id: leftPanel
    anchors { top: true; bottom: true; left: true }
    implicitWidth: 380
    visible: false
    color: Theme.surface
    // tabs: chatbot, booru, settings, keybinds
}
EOF
echo done