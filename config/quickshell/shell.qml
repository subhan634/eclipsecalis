import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens
        Bar { screen: modelData }
    }

    Launcher { id: launcher }
    LeftPanel { id: leftPanel }
    RightPanel { id: rightPanel }
    Osd { id: osd }
    NotificationServer { id: notifServer }
}
