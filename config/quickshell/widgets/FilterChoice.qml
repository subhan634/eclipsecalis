import QtQuick 2.15
import QtQuick.Controls 2.15
import eclipsecalis.theme 1.0

Rectangle {
    id: filterChoice
    width: parent ? parent.width : 100
    height: 32
    radius: 16
    color: isSelected ? Theme.primary : Theme.surfaceVariant
    immediate : false

    Text {
        anchors.centerIn: parent
        text: label
        font.pointSize: 11
        font.bold: isSelected
        color: isSelected ? Theme.onSurfaceBackgroundColor : Theme.onSurface
    }

    Signal toggled
}