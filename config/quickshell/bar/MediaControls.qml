import QtQuick
import Quickshell.Mpris
Row {
    Repeater {
        model: Mpris.players
        delegate: Row {
            Text { text: modelData.trackTitle + " - " + modelData.trackArtist; color: Theme.onSurface; font.pixelSize: 12 }
            // play/pause/next/seek
        }
    }
}
