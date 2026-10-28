import QtQuick
import Quickshell

PanelWindow {
    id: rightPanel
    anchors { top: true; bottom: true; right: true }
    implicitWidth: 400; visible: false; color: Theme.surface
    property int tab: 0  // 0 calendar,1 notifications,2 media,3 resources,4 crypto,5 weather
    Column {
        anchors.fill: parent
        Row {
            Repeater {
                model: ["Cal","Notif","Media","Res","Crypto","Weather"]
                delegate: Rectangle {
                    width: 60; height: 36; color: rightPanel.tab===index ? Theme.primary : Theme.surfaceVariant
                    Text { anchors.centerIn: parent; text: modelData; color: Theme.onSurface; font.pixelSize: 11 }
                    MouseArea { anchors.fill: parent; onClicked: rightPanel.tab = index }
                }
            }
        }
    }
}
EOF
echo done