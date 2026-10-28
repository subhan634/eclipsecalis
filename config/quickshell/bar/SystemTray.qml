import QtQuick
import Quickshell
Row { Repeater { model: SystemTray.items; delegate: Image { source: modelData.icon; width: 18; height: 18 } } }
