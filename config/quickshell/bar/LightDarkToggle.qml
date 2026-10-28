import QtQuick
Rectangle {
    width: 28; height: 28; radius: 14; color: Theme.surfaceVariant
    Text { anchors.centerIn: parent; text: "◐"; color: Theme.onSurface }
    MouseArea { anchors.fill: parent; onClicked: { /* call eclipsecalis toggle */ } }
}
