import QtQuick
import Quickshell

PanelWindow {
    id: bar
    property var screen
    anchors { top: true; left: true; right: true }
    implicitHeight: 36
    color: Theme.surface

    Row {
        anchors.fill: parent
        Workspaces {}
        Item { Layout.fillWidth: true }
        NetworkUsage {}
        Weather {}
        MediaControls {}
        SystemTray {}
        BatteryVolumeBrightness {}
        Clock {}
        LightDarkToggle {}
    }
}
EOF
# placeholder component stubs
for c in Workspaces NetworkUsage Weather MediaControls SystemTray BatteryVolumeBrightness Clock LightDarkToggle; do
  echo "import QtQuick
Rectangle { color: 'transparent'; implicitWidth: 80; implicitHeight: 36 }" > config/quickshell/bar/$c.qml
done
echo done