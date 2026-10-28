import QtQuick 2.15
import QtQuick.Controls 2.15
import eclipsecalis.theme 1.0

Rectangle {
    id: thumbCard
    width: 180; height: 280
    radius: 8
    color: Theme.surface
    opacity: underMouse ? 1.0 : 0.95
    Behavior on opacity { duration: 150 }

    // Hover area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPressed: { thumbCard.border.color = Theme.primary }
        onReleased: { thumbCard.border.color = Theme.error }

        // Emit download toggled signal on click
        onClicked: {
            if (wallpaperService.downloadStatus === "downloading") return;
            // Emit signal that parent (WallhavenBrowser) will connect to
            if (onDownloadToggled) {
                onDownloadToggled(modelData.id, true);
            }
        }
    }

    // Resolution badge
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: modelData ? modelData.resolution : "Loading..."
        font.pointSize: 11
        font.bold: true
        color: Theme.onSurface
        anchors.bottomMargin: 4
        wrapMode: Text.Wrap
        Text.underColor: Theme.error
    }

    // Download status indicator
    Item {
        anchors.centerIn: parent
        visible: wallpaperService.downloadStatus === "downloading"
        // Spinner animation
        Behavior on opacity { duration: 200 }
    }

    // "Open on site" link
    Text {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.topMargin: 4
        font.pointSize: 10
        fontitalic: true
        color: Theme.error
        text: "open on site"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (modelData && modelData.path) {
                    Qt.openUrlSafest("https://wallhaven.cc/w/" + modelData.id);
                }
            }
        }
    }

    // Progress checkmark after download
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        visible: wallpaperService.downloadStatus === "downloaded" && modelData && modelData.id in wallpaperService.downloadedIds
        Text {
            anchors.centerIn: parent
            text: "✓"
            font.pointSize: 40
            color: Theme.primary
            opacity: 0.8
        }
    }
}