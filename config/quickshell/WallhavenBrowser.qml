import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import eclipsecalis.theme 1.0

// Wallhaven Browser main component
// Usage: WallhavenBrowser { } - instantiated in wallpaper selector

// Properties provided:
// - searchQuery: string - current search text
// - currentPage: int - current page number
// - searchResults: var - array of wallpaper objects
// - searchTotal: int - total results count
// - isSearching: bool - whether a search is in progress
// - searchError: string - error message if search failed
// - downloadStatus: string - download status (idle, downloading, downloaded, error)
// - downloadProgress: string - download progress text
// - downloadError: string - download error message
// - localWallpapers: var - list of local wallpaper dicts
// - hasApiKey: bool - whether API key is configured
// - currentView: enum - Wallhaven or Local

// Signals:
// - searchChanged: emitted when search parameters change
// - downloadToggled: emitted when download is triggered
// - wallpaperApplied: emitted when a wallpaper is set

Rectangle {
    id: root
    width: 800; height: 600
    focus: true

    // View mode: Wallhaven or Local
    property WallhavenBrowserRoot.ViewMode currentView: ViewMode.Wallhaven
    enum ViewMode { Wallhaven, Local }

    // ============ Search/State Properties ============

    // Search query text (bound to search field)
    property string searchQuery: ""

    // Current page number
    property int currentPage: 1

    // Search results from Wallhaven API
    property var searchResults: []

    // Total number of search results
    property int searchTotal: 0

    // Whether a search is in progress
    property bool isSearching: false

    // Error message from search
    property string searchError: ""

    // Current selected wallpaper (for download/set)
    property var currentWallpaper: {}

    // Download status
    property string downloadStatus: "idle"
    property string downloadProgress: ""
    property string downloadError: ""

    // Local wallpapers list
    property var localWallpapers: []

    // API key availability
    property bool hasApiKey: false

    // ============ Filter State ============

    // Selected category bit string (110=General, 010=Anime, 001=People)
    property string selectedCategory: "110"

    // Default purity setting
    property string defaultPurity: "sfw"

    // Minimum resolution setting
    property string minimumResolution: ""

    // ============ Signals ============

    // Emitted when search parameters change
    signal searchChanged(string query, string purity, string categories,
                        string sorting, string order, string topRange,
                        string atLeast, string ratios, string colors, int page)

    // Emitted when download is triggered
    signal downloadToggled(int wallpaperId, bool setAsWallpaper)

    // Emitted when a wallpaper is applied
    signal wallpaperApplied()

    // ============ User Interface ============

    Column {
        anchors.fill: parent
        spacing: 0

        // Header bar
        Row {
            anchors topMargin: 8
            anchors leftMargin: 8
            anchors rightMargin: 8
            height: 32
            visible: root.currentView === WallhavenBrowserRoot.ViewMode.Wallhaven

            Text {
                text: qsTr("Wallhaven Browser")
                font.pointSize: 14
                font.bold: true
                color: Theme.onSurface
            }

            Spacer {}

            // Close button (switch to local view)
            Button {
                text: qsTr("Local")
                font.pointSize: 10
                flat: true
                onClicked: {
                    root.currentView = WallhavenBrowserRoot.ViewMode.Local;
                }
            }
        }

        // Toolbar with filters
        Row {
            anchors topMargin: 46
            anchors leftMargin: 8
            anchors rightMargin: 8
            height: 80
            visible: root.currentView === WallhavenBrowserRoot.ViewMode.Wallhaven

            // Search box
            TextField {
                id: searchField
                placeholderText: qsTr("Search wallpapers...")
                text: root.searchQuery
                implicitWidth: 200
                height: 32
                onTextChanged: {
                    if (searchField.text !== root.searchQuery) {
                        root.searchQuery = searchField.text;
                        root.searchChanged();
                    }
                }
                onSubmitted: {
                    root.searchChanged();
                }
            }

            // Category filter chips (inline, simplified)
            Row {
                id: categoryRow
                anchors right: searchField.left
                anchors.rightMargin: 8
                visible: false  // simplified - can be expanded later
                spacing: 4
                Repeater {
                    model: 3
                    delegate: Rectangle {
                        id: catChip
                        width: 60; height: 28
                        radius: 14
                        color: root.selectedCategory === ["110", "010", "001"][index] ? Theme.primary : Theme.surfaceVariant
                        Text {
                            anchors.centerIn: parent
                            text: ["General", "Anime", "People"][index]
                            font.pointSize: 10
                            font.bold: root.selectedCategory === ["110", "010", "001"][index]
                            color: root.selectedCategory === ["110", "010", "001"][index] ? Theme.onSurfaceBackgroundColor : Theme.onSurface
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.selectedCategory = ["110", "010", "001"][index];
                                root.searchChanged();
                            }
                        }
                    }
                }
            }

            // Filter buttons (purity, resolution) - simplified
            Row {
                id: filterRow
                anchors right: categoryRow ? categoryRow.left : searchField.left
                anchors.rightMargin: 8
                spacing: 4
                visible: false
            }
        }

        // Thumbnail grid
        ScrollView {
            anchors topMargin: 130
            anchors leftMargin: 8
            anchors rightMargin: 8
            anchors bottom: parent.bottom
            flickableDirection: Flickable.Vertical

            GridLayout {
                id: gridLayout
                anchors fill: parent
                columns: Math.max(Math.floor((parent.width - 16) / 190), 1)
                cellWidth: 180
                cellHeight: 280
                horizontalSpacing: 8
                verticalSpacing: 8
                padding: 4

                // Empty state when no results
                Component.onCompleted: {
                    if (root.isSearching && root.searchResults.length === 0) {
                        // Show skeleton loading items
                        for (var i = 0; i < 8; i++) {
                            appendSkeleton();
                        }
                    } else if (root.searchResults.length === 0 && !root.isSearching && !root.searchError) {
                        emptyState.visible = true;
                    }
                }

                function appendSkeleton() {
                    var skeleton = gridLayout.itemAt(gridLayout.count - 1);
                    return skeleton;
                }

                // Skeleton item for loading
                Repeater {
                    model: root.isSearching ? 8 : 0
                    delegate: ThumbCard {
                        modelData: { id: 0, resolution: "Loading...", canDownload: false }
                        downloadStatus: root.downloadStatus
                        downloadedIds: root.downloadedIds
                    }
                }

                // Empty state
                Rectangle {
                    id: emptyState
                    anchors.centerIn: parent
                    width: 200; height: 100
                    visible: !root.isSearching && root.searchResults.length === 0 && !root.searchError
                    radius: 8
                    color: Theme.surface
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("No wallpapers found")
                        font.pointSize: 14
                        color: Theme.onSurface
                    }
                    Text {
                        anchors bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Try different search terms or check your API key")
                        font.pointSize: 10
                        color: Theme.error
                    }
                }

                // Thumbnail cards
                Repeater {
                    model: root.searchResults.length
                    delegate: ThumbCard {
                        id: thumbCard
                        modelData: root.searchResults[index]
                        downloadStatus: root.downloadStatus
                        downloadedIds: root.downloadedIds

                        // Handle download click - emit signal
                        onDownloadToggled: {
                            root.downloadToggled(modelData.id, true);
                        }

                        // Visual feedback based on download status
                        onDownloadStatusChanged: {
                            // Update checkmark visibility
                        }
                    }
                }
            }
        }
    }
}