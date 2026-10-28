pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
QtObject {
    id: weather
    property string location: "auto"
    property real temp: 0
    property string condition: ""
    property var cache: ({})
    // Open-Meteo: https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&current_weather=true
    function refresh() {
        // fetch via Process/curl; cache by location+hour
    }
}
