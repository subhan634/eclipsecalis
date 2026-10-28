import QtQuick 2.15
import QtQuick.Controls 2.15
import eclipsecalis.theme 1.0

Column {
    id: filterBar
    spacing: 6
    implicitWidth: Math.max(preferredWidth, 200)

    // Sorting dropdown
    ComboBox {
        id: sortingCombo
        title: qsTr("Sorting")
        model: ["toplist", "hot", "views", "favorites", "date_added", "random"]
        currentIndex: 0
        // When sorting changes, emit signal
        onActivated: {
            if (onSortingChanged) {
                onSortingChanged(model.data(index).toLower());
            }
        }
    }

    // Purity toggle row
    Row {
        spacing: 8
        anchors.top: sortingCombo.bottom
        anchors.topMargin: 4

        ToggleButton {
            text: qsTr("SFW")
            checked: wallhavenService.defaultPurity === "sfw"
            enabled: wallhavenService.hasApiKey || true
            onClicked: {
                if (clicked) {
                    wallhavenService.defaultPurity = "sfw";
                    if (onPurityChanged) onPurityChanged("sfw");
                }
            }
        }

        ToggleButton {
            text: qsTr("Sketchy")
            checked: wallhavenService.defaultPurity === "sketchy"
            enabled: wallhavenService.hasApiKey
            onClicked: {
                if (clicked) {
                    wallhavenService.defaultPurity = "sketchy";
                    if (onPurityChanged) onPurityChanged("sketchy");
                }
            }
        }

        // NSFW toggle only shown with API key
        ToggleButton {
            text: qsTr("NSFW")
            checked: wallhavenService.defaultPurity === "nsfw"
            enabled: wallhavenService.hasApiKey
            onClicked: {
                if (clicked) {
                    wallhavenService.defaultPurity = "nsfw";
                    if (onPurityChanged) onPurityChanged("nsfw");
                }
            }
        }
    }

    // Minimum resolution field
    Row {
        spacing: 8
        anchors.top: purityRow.bottom
        anchors.topMargin: 4

        Label { text: qsTr("Min resolution:"); font.pointSize: 10 }
        ComboBox {
            id: resolutionCombo
            title: qsTr("Resolution")
            model: ["current", "1920x1080", "3840x2160", "3840x1600", "2560x1440"]
            currentIndex: 0
            onActivated: {
                if (onMinResolutionChanged) {
                    onMinResolutionChanged(resolutionCombo.currentText);
                }
            }
        }
    }

    // Explicitly create named rows for signal connections
    property string sortingChanged: ""
    property string purityChanged: ""
    property string minResolutionChanged: ""

    Row {
        id: purityRow
        visible: wallhavenService.hasApiKey
        spacing: 8
    }
}