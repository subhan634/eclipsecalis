import QtQuick
import Quickshell

PanelWindow {
    id: launcher
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#80000000"
    visible: false

    // prefix modes: apps (default), :clipboard, :emoji, :math, :url, :cmd
    property string mode: "apps"
    property string query: ""

    Column {
        anchors.centerIn: parent
        width: 600
        Rectangle { width: parent.width; height: 48; color: Theme.surfaceVariant; radius: Theme.radius }
        ListView { width: parent.width; height: 400; model: 0 }
    }
}
EOF
echo done