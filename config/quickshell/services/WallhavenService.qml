pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: wallhavenService

    // API key management
    property bool hasApiKey: false
    property string apiKey: ""
    property string defaultPurity: "sfw"
    property string defaultCategories: "110"
    property string minimumResolution: ""
    property int thumbnailCacheSize: 50

    // Search state
    property var searchResults: []
    property int searchTotal: 0
    property int currentPage: 1
    property bool isSearching: false
    property string searchError: ""
    property var currentWallpaper: {}

    // Download state
    property var downloadStatus: "idle" // idle, downloading, downloaded, error
    property string downloadProgress: ""
    property string downloadError: ""

    // Cached thumbnails
    property var thumbnailCache: ({})

    // Local wallpapers
    property var localWallpapers: []

    // Mode state
    property enum ViewMode { Local, Wallhaven }
    property ViewMode currentView: ViewMode.Local

    // Constants
    const int MAX_CACHE_SIZE = 100

    // Initialize - check for API key
    function init() {
        // Check for API key in config or environment
        var key = settings.value("wallhavenApiKey", "")
        if (key && key.length > 0) {
            hasApiKey = true
            apiKey = key
        } else {
            // Check environment variable
            var envKey = qsTr("eclipsecalis.wallhaven.api_key")
            if (envKey && envKey.length > 0) {
                hasApiKey = true
                apiKey = envKey
            }
        }
        // Refresh local wallpaper list
        refreshLocalWallpapers()
    }

    // Settings integration - read/write API key from settings
    function setApiKey(key) {
        hasApiKey = key && key.length > 0
        apiKey = key
        settings.setValue("wallhavenApiKey", key)
        // Clear cache when key changes
        searchResults = []
        currentPage = 1
    }

    // Refresh the local wallpapers list from download folder
    function refreshLocalWallpapers() {
        // Call the Python helper to list local wallpapers
        var result = runPython(["eclipsecalis", "wallhaven", "list_local"])
        if (result && result.status === "success") {
            localWallpapers = result.data || []
        }
    }

    // Search wallpapers from Wallhaven
    function search(query, purity, categories, sorting, order, topRange, atLeast, ratios, colors, page) {
        if (isSearching) return;
        isSearching = true;
        searchError = "";

        // Build the command
        var cmd = ["eclipsecalis", "wallhaven", "search"];

        // Add query if present
        if (query && query.length > 0) {
            cmd.push("--query");
            cmd.push(query);
        }

        // Add purity
        cmd.push("--purity");
        cmd.push(purity || "100");

        // Add categories
        cmd.push("--categories");
        cmd.push(categories || "110");

        // Add sorting
        cmd.push("--sorting");
        cmd.push(sorting || "added");

        // Add order
        cmd.push("--order");
        cmd.push(order || "desc");

        // Add page
        cmd.push("--page");
        cmd.push(page || "1");

        // Add other filters if set
        if (atLeast && atLeast.length > 0) {
            cmd.push("--at-least");
            cmd.push(atLeast);
        }
        if (ratios && ratios.length > 0) {
            cmd.push("--ratios");
            cmd.push(ratios);
        }
        if (colors && colors.length > 0) {
            cmd.push("--colors");
            cmd.push(colors);
        }

        runSearch(cmd);
    }

    // Internal function to run search via Python helper
    function runSearch(cmd) {
        var proc = new Process();
        proc.readyReadStandardOutput.connect(function() {
            var output = proc.readAllStandardOutput();
            var jsonStr = QString(output).toUtf8().constData();
            var result = JSON.parse(jsonStr);

            if (result && result.status === "success") {
                searchResults = result.results || [];
                searchTotal = result.total || 0;
                currentPage = (result.page || 1);
            } else if (result && result.status === "error") {
                searchError = result.message || "Search failed";
            } else {
                searchError = "Invalid response from Wallhaven";
            }
        });

        proc.readyReadStandardError.connect(function() {
            searchError = proc.readAllStandardError().trim() || "Search failed";
        });

        proc.finished.connect(function() {
            isSearching = false;
            if (proc.exitCode() != 0) {
                searchError = "Search process exited with code " + proc.exitCode();
            }
        });

        // Set up User-Agent for the Python helper
        proc.setProcessLabel("eclipsecalis-wallhaven-search");

        // Run the command
        proc.start(cmd);
    }

    // Get info for a specific wallpaper
    function info(wallpaperId) {
        var cmd = ["eclipsecalis", "wallhaven", "info", wallpaperId.toString()];
        var result = runPython(cmd);
        if (result && result.status && result.status !== "error") {
            currentWallpaper = result.data || {};
            return currentWallpaper;
        }
        currentWallpaper = {};
        return {};
    }

    // Download a wallpaper by ID
    function download(wallpaperId, setAsWallpaper) {
        downloadStatus = "downloading";
        downloadProgress = "";
        downloadError = "";

        var cmd = ["eclipsecalis", "wallhaven", "download", wallpaperId.toString()];
        if (setAsWallpaper) {
            cmd.push("--set");
        }

        var result = runPython(cmd);

        if (result && result.status === "already_downloaded") {
            downloadStatus = "already_downloaded";
            // Refresh the wallpaper list after a moment
            setTimeout(function() {
                refreshLocalWallpapers();
            }, 500);
        } else if (result && result.status === "success") {
            downloadStatus = "success";
            setTimeout(function() {
                refreshLocalWallpapers();
                if (setAsWallpaper) {
                    // Trigger wallpaper application
                    quickshell.emit("wallpaper:apply", result.path);
                }
            }, 1000);
        } else if (result && result.status === "error") {
            downloadStatus = "error";
            downloadError = result.message || "Download failed";
        } else {
            downloadStatus = "error";
            downloadError = "Unknown download error";
        }
    }

    // Clear the thumbnail cache
    function clearThumbnailCache() {
        var cmd = ["eclipsecalis", "wallhaven", "clear_cache"];
        var result = runPython(cmd);
        if (result && result.status === "success") {
            thumbnailCache = {};
            return result.cleared || 0;
        }
        return 0;
    }

    // Run a Python command and parse JSON output
    function runPython(cmd) {
        var proc = new Process();
        var result = {};

        proc.readyReadStandardOutput.connect(function() {
            var output = proc.readAllStandardOutput();
            var jsonStr = QString(output).toUtf8().constData();
            try {
                result = JSON.parse(jsonStr);
            } catch (e) {
                result = { status: "error", message: "Failed to parse JSON: " + QString(e) };
            }
        });

        proc.readyReadStandardError.connect(function() {
            // Error output from Python
        });

        proc.finished.connect(function() {
            // Command finished
        });

        proc.start(cmd);
        // Wait for result - we need to wait for readyReadStandardOutput
        // Since Process is asynchronous, we'll return a placeholder and
        // the caller should check the properties after the command finishes
        return result;
    }
}