import QtQuick
import Quickshell

PanelWindow {
    id: leftPanel
    anchors { top: true; bottom: true; left: true }
    implicitWidth: 400; visible: false; color: Theme.surface
    property int tab: 0  // 0 chatbot,1 image browser,2 settings,3 keybinds
    Column {
        anchors.fill: parent
        Row {
            Repeater {
                model: ["Chat","Images","Settings","Keys"]
                delegate: Rectangle {
                    width: 90; height: 36; color: leftPanel.tab===index ? Theme.primary : Theme.surfaceVariant
                    Text { anchors.centerIn: parent; text: modelData; color: Theme.onSurface }
                    MouseArea { anchors.fill: parent; onClicked: leftPanel.tab = index }
                }
            }
        }
        StackLayout { /* tab content placeholders */ }
    }
}
EOF
echo done