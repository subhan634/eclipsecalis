import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: workspaces
    spacing: 4
    Repeater {
        model: Hyprland.workspaces
        delegate: Rectangle {
            width: 22; height: 22; radius: 11
            color: modelData.active ? Theme.primary : (modelData.occupied ? Theme.surfaceVariant : "transparent")
            border.color: Theme.onSurface; border.width: 1
            Text { anchors.centerIn: parent; text: modelData.id; color: Theme.onSurface; font.pixelSize: 11 }
            MouseArea { anchors.fill: parent; onClicked: Hyprland.dispatch("workspace " + modelData.id) }
        }
    }
}
EOF
echo done