pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: bw
    property real up: 0
    property real down: 0
    property var history: []
    property string iface: ""

    property var proc: Process {
        command: ["bash", "-c", "cat /proc/net/dev"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                // parse; pick first non-lo interface
            }
        }
    }
    // simplified: timer-driven
    property var timer: Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: { /* update up/down from /proc/net/dev delta */ }
    }
}
EOF
echo done