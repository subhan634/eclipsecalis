import QtQuick
import Quickshell

PanelWindow {
    id: launcher
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#90000000"
    visible: false
    property string mode: "apps"   // apps|clipboard|emoji|math|url|cmd
    property string query: ""
    property var results: []

    Column {
        anchors.centerIn: parent
        width: 640
        Rectangle {
            width: parent.width; height: 52; radius: Theme.radius; color: Theme.surface
            TextInput {
                id: input; anchors.fill: parent; anchors.margins: 12
                color: Theme.onSurface; font.pixelSize: 16
                onTextChanged: { launcher.query = text; launcher.recompute() }
                Keys.onPressed: (e) => {
                    if (e.key === Qt.Key_Tab) { launcher.cycleMode(); e.accepted = true }
                }
            }
        }
        ListView {
            width: parent.width; height: 420
            model: launcher.results
            delegate: Rectangle {
                width: parent.width; height: 36; color: "transparent"
                Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 12; text: modelData.label; color: Theme.onSurface }
            }
        }
    }

    function cycleMode() {
        const modes = ["apps","clipboard","emoji","math","url","cmd"]
        mode = modes[(modes.indexOf(mode)+1) % modes.length]
        recompute()
    }
    function recompute() {
        // dispatch to mode handler; safe math eval via python helper, no raw eval
    }
}
EOF
echo done