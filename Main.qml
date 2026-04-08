import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import "Components"
import "translations.js" as Tr

Item {
    id: root
    width: Screen.width
    height: Screen.height

    // ---- Color properties (defaults, overridden by colors.conf) ----
    property color colBackground: "#121314"
    property color colOnBackground: "#e3e2e2"
    property color colSurfaceContainer: "#1f2020"
    property color colSurfaceContainerHigh: "#292a2b"
    property color colOnSurface: "#e3e2e2"
    property color colOnSurfaceVariant: "#c7c6c7"
    property color colPrimary: "#bac9d1"
    property color colOnPrimary: "#253239"
    property color colPrimaryContainer: "#3b494f"
    property color colOnPrimaryContainer: "#d6e5ed"
    property color colSecondary: "#c0c8cc"
    property color colSecondaryContainer: "#40484c"
    property color colOnSecondaryContainer: "#dce4e9"
    property color colTertiary: "#b4cad5"
    property color colTertiaryContainer: "#354a53"
    property color colOnTertiaryContainer: "#cfe6f2"
    property color colError: "#ffb4ab"
    property color colShadow: "#000000"
    property color colOutline: "#919091"
    property color colOutlineVariant: "#464747"
    property color colLayer0: "#121314"
    property color colLayer1: "#1b1c1c"
    property color colOnLayer1: "#c7c6c7"
    property color colSubtext: "#919091"

    // ---- Config properties ----
    property string wallpaperPath: config.Background || "Backgrounds/default.jpg"
    property int blurRadius: parseInt(config.BlurRadius) || 100
    property bool blurEnabled: config.BlurEnabled !== "false"
    property real blurExtraZoom: parseFloat(config.BlurExtraZoom) || 1.1
    property real blurOverlayOpacity: parseFloat(config.BlurOverlayOpacity) || 0.3
    property string clockFontFamily: config.ClockFontFamily || "Google Sans Flex"
    property int clockFontSize: parseInt(config.ClockFontSize) || 90
    property int clockFontWeight: parseInt(config.ClockFontWeight) || 350
    property string fontFamily: config.FontFamily || "Google Sans Flex Medium"
    property int fontSize: parseInt(config.FontSize) || 15

    // ---- Language (for reactive bindings) ----
    property string lang: config.Language || Qt.locale().name

    // ---- State ----
    property int currentUserIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property string currentUserName: userModel.lastUser || getUserName(currentUserIndex)
    property int currentSessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    // ---- Toolbar appear animation ----
    property real toolbarScale: 0.9
    property real toolbarOpacity: 0

    // ---- Virtual keyboard state ----
    property bool virtualKeyboardVisible: false
    property bool hasPhysicalKeyboard: true

    Behavior on toolbarScale {
        NumberAnimation {
            duration: 500
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.38, 1.21, 0.22, 1.00, 1, 1]
        }
    }
    Behavior on toolbarOpacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
        }
    }

    Component.onCompleted: {
        Tr.setLanguage(config.Language || Qt.locale().name)
        try { loadColors() } catch(e) { console.log("loadColors error:", e) }
        try { loadWallpaper() } catch(e) { console.log("loadWallpaper error:", e) }
        root.hasPhysicalKeyboard = detectPhysicalKeyboard()
        if (!root.hasPhysicalKeyboard) {
            root.virtualKeyboardVisible = true
        }
        // Set preferred keyboard layout based on detected language
        try {
            var preferredLang = (config.Language || Qt.locale().name).substring(0, 2).toLowerCase()
            if (keyboard.layouts && keyboard.layouts.length > 1) {
                for (var i = 0; i < keyboard.layouts.length; i++) {
                    if (keyboard.layouts[i].shortName.toLowerCase() === preferredLang) {
                        keyboard.currentLayout = i
                        break
                    }
                }
            }
        } catch(e) {}
        toolbarScale = 1
        toolbarOpacity = 1
        passwordField.forceActiveFocus()
    }

    // ---- Wallpaper loading ----
    // Legge il path del wallpaper da un file plain-text (default: matugen path.txt).
    // Sovrascrivibile con WallpaperPathFile in theme.conf.
    function loadWallpaper() {
        var user = root.currentUserName || "torvalds"
        var home = "/home/" + user

        var plainPath = (config.WallpaperPathFile || "").trim()
        if (plainPath === "")
            plainPath = home + "/.local/state/quickshell/user/generated/wallpaper/path.txt"

        var text = readFileContent(plainPath).trim()
        if (text !== "")
            root.wallpaperPath = text
    }

    // ---- Color loading from matugen JSON ----
    function readFileContent(path) {
        try {
            var xhr = new XMLHttpRequest()
            xhr.open("GET", path.startsWith("/") ? "file://" + path : Qt.resolvedUrl(path), false)
            xhr.send()
            if ((xhr.status === 200 || xhr.status === 0) && xhr.responseText.trim() !== "")
                return xhr.responseText
        } catch(e) {}
        return ""
    }

    function loadColors() {
        // Try matugen generated colors first (live from user's state)
        var user = root.currentUserName || "torvalds"
        var matugenPath = "/home/" + user + "/.local/state/quickshell/user/generated/colors.json"
        var text = readFileContent(matugenPath)

        // Fallback to theme-local colors file
        if (text === "") {
            var colorsFile = config.ColorsFile || "colors.json"
            text = readFileContent(colorsFile)
        }

        if (text !== "") {
            if (text.trim().startsWith("{")) {
                parseColorsJson(text)
            } else {
                parseColorsIni(text)
            }
        }
    }

    function parseColorsJson(text) {
        var json = JSON.parse(text)
        var map = {
            "background": "colBackground",
            "on_background": "colOnBackground",
            "surface_container": "colSurfaceContainer",
            "surface_container_high": "colSurfaceContainerHigh",
            "on_surface": "colOnSurface",
            "on_surface_variant": "colOnSurfaceVariant",
            "primary": "colPrimary",
            "on_primary": "colOnPrimary",
            "primary_container": "colPrimaryContainer",
            "on_primary_container": "colOnPrimaryContainer",
            "secondary": "colSecondary",
            "secondary_container": "colSecondaryContainer",
            "on_secondary_container": "colOnSecondaryContainer",
            "tertiary": "colTertiary",
            "tertiary_container": "colTertiaryContainer",
            "on_tertiary_container": "colOnTertiaryContainer",
            "error": "colError",
            "shadow": "colShadow",
            "outline": "colOutline",
            "outline_variant": "colOutlineVariant"
        }
        for (var key in map) {
            if (json[key]) {
                try { root[map[key]] = json[key] } catch(e) {}
            }
        }
        // Derived colors
        if (json["surface"]) root.colLayer0 = json["surface"]
        if (json["surface_container_low"]) root.colLayer1 = json["surface_container_low"]
        if (json["on_surface_variant"]) root.colOnLayer1 = json["on_surface_variant"]
        if (json["outline"]) root.colSubtext = json["outline"]
    }

    function parseColorsIni(text) {
        var lines = text.split("\n")
        var inColors = false
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line === "[Colors]") { inColors = true; continue }
            if (line.startsWith("[")) { inColors = false; continue }
            if (inColors && line.indexOf("=") !== -1 && !line.startsWith("#")) {
                var eqIdx = line.indexOf("=")
                var key = line.substring(0, eqIdx).trim()
                var value = line.substring(eqIdx + 1).trim()
                applyColorIni(key, value)
            }
        }
    }

    function applyColorIni(key, value) {
        var map = {
            "background": "colBackground",
            "onBackground": "colOnBackground",
            "surfaceContainer": "colSurfaceContainer",
            "surfaceContainerHigh": "colSurfaceContainerHigh",
            "onSurface": "colOnSurface",
            "onSurfaceVariant": "colOnSurfaceVariant",
            "primary": "colPrimary",
            "onPrimary": "colOnPrimary",
            "primaryContainer": "colPrimaryContainer",
            "onPrimaryContainer": "colOnPrimaryContainer",
            "secondary": "colSecondary",
            "secondaryContainer": "colSecondaryContainer",
            "onSecondaryContainer": "colOnSecondaryContainer",
            "tertiary": "colTertiary",
            "tertiaryContainer": "colTertiaryContainer",
            "onTertiaryContainer": "colOnTertiaryContainer",
            "error": "colError",
            "shadow": "colShadow",
            "outline": "colOutline",
            "outlineVariant": "colOutlineVariant",
            "layer0": "colLayer0",
            "layer1": "colLayer1",
            "onLayer1": "colOnLayer1",
            "subtext": "colSubtext"
        }
        if (map[key]) root[map[key]] = value
    }

    // ---- Helper: read Name= from a .desktop file ----
    function readDesktopName(filePath) {
        var text = readFileContent(filePath)
        if (text === "") return ""
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.indexOf("Name=") === 0) {
                return line.substring(5).trim()
            }
        }
        return ""
    }

    // ---- Helper: get session name from model ----
    function getSessionName(idx) {
        if (idx < 0 || idx >= sessionModel.count) return Tr.tr("session")
        var modelIdx = sessionModel.index(idx, 0)
        // Try multiple roles to find the best human-readable name
        // SDDM SessionModel roles vary by version:
        //   Qt.DisplayRole, UserRole+1 (file), UserRole+2 (name), UserRole+3 (comment)
        var roles = [Qt.UserRole + 2, Qt.DisplayRole, Qt.UserRole + 1]
        var name = ""
        var filePath = ""
        for (var i = 0; i < roles.length; i++) {
            var val = sessionModel.data(modelIdx, roles[i])
            if (val && String(val) !== "") {
                var s = String(val)
                // Remember file path for .desktop fallback
                if (s.indexOf("/") !== -1 || s.indexOf(".desktop") !== -1)
                    filePath = s
                // Skip generic type names like "wayland-session", "x11-session"
                if (s.indexOf("-session") === -1) {
                    name = s
                    break
                }
                if (name === "") name = s
            }
        }
        // Fallback: read Name= from the .desktop file
        if ((!name || name.indexOf("-session") !== -1) && filePath !== "") {
            var desktopPath = filePath
            if (!desktopPath.startsWith("/")) {
                // Try standard session directories
                var dirs = ["/usr/share/wayland-sessions/", "/usr/share/xsessions/"]
                for (var d = 0; d < dirs.length; d++) {
                    var dn = readDesktopName(dirs[d] + desktopPath)
                    if (dn !== "") { name = dn; break }
                }
            } else {
                var dn = readDesktopName(desktopPath)
                if (dn !== "") name = dn
            }
        }
        if (!name || name === "") return Tr.tr("session")
        // If still looks like a path, extract a clean name
        if (name.indexOf("/") !== -1) {
            var parts = name.split("/").filter(function(p) { return p.length > 0 })
            name = parts[parts.length - 1] || Tr.tr("session")
            name = name.replace(/\.[^.]+$/, "")
        }
        return name
    }

    // ---- Helper: get user name from model ----
    function getUserName(idx) {
        if (idx < 0 || idx >= userModel.count) return Tr.tr("user")
        // Try RealName first (UserRole+2), then Name (UserRole+1), then DisplayRole
        var name = userModel.data(userModel.index(idx, 0), Qt.UserRole + 2)
        if (!name || name === "")
            name = userModel.data(userModel.index(idx, 0), Qt.UserRole + 1)
        if (!name || name === "")
            name = userModel.data(userModel.index(idx, 0), Qt.DisplayRole)
        return name || Tr.tr("user")
    }

    // ---- Helper: detect physical keyboard ----
    function detectPhysicalKeyboard() {
        var content = readFileContent("/proc/bus/input/devices")
        if (content === "") return true // assume present if can't read
        // Split into device blocks and look for a real keyboard:
        // Real keyboards have EV=120013 and a "leds" handler (Caps Lock/Num Lock LEDs)
        var blocks = content.split("\n\n")
        for (var i = 0; i < blocks.length; i++) {
            var block = blocks[i]
            if (/EV=120013/i.test(block) && /Handlers=.*\bleds\b/.test(block)) {
                return true
            }
        }
        return false
    }

    // ---- Helper: get keyboard layout short name ----
    function getKeyboardLayout() {
        try {
            var idx = keyboard.currentLayout
            if (keyboard.layouts && keyboard.layouts[idx])
                return keyboard.layouts[idx].shortName.toUpperCase()
        } catch(e) {}
        return ""
    }

    // ========== BACKGROUND ==========
    Rectangle {
        anchors.fill: parent
        color: root.colBackground
    }

    Item {
        anchors.fill: parent
        clip: true

        Image {
            id: wallpaper
            anchors.centerIn: parent
            width: parent.width * (root.blurEnabled ? root.blurExtraZoom : 1.0)
            height: parent.height * (root.blurEnabled ? root.blurExtraZoom : 1.0)
            source: root.wallpaperPath.startsWith("/") ? "file://" + root.wallpaperPath : Qt.resolvedUrl(root.wallpaperPath)
            fillMode: Image.PreserveAspectCrop
        }

        GaussianBlur {
            visible: root.blurEnabled
            anchors.fill: wallpaper
            source: wallpaper
            radius: root.blurRadius
            samples: Math.min(root.blurRadius * 2 + 1, 201)
        }

        // Dark overlay on blurred wallpaper
        Rectangle {
            anchors.fill: parent
            color: root.colLayer0
            opacity: root.blurOverlayOpacity
            visible: root.blurEnabled
        }
    }

    // ========== CLICK TO FOCUS ==========
    MouseArea {
        anchors.fill: parent
        onClicked: passwordField.forceActiveFocus()
    }

    // ========== CLOCK ==========
    Clock {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -60
        colFace: root.colPrimaryContainer
        colOnFace: root.colOnPrimaryContainer
        colHourHand: root.colPrimary
        colMinuteHand: root.colTertiary
        colShadow: root.colShadow
        colSecondaryContainer: root.colSecondaryContainer
        colOnSecondaryContainer: root.colOnSecondaryContainer
        colTertiaryContainer: root.colTertiaryContainer
        colOnTertiaryContainer: root.colOnTertiaryContainer
        fontFamily: root.clockFontFamily
        timeFontWeight: root.clockFontWeight
        clockSize: 230
    }

    // ========== MAIN TOOLBAR (center: password + confirm) ==========
    Toolbar {
        id: mainIsland
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 20
        }
        colBackground: root.colSurfaceContainer
        colShadow: root.colShadow
        scale: root.toolbarScale
        opacity: root.toolbarOpacity

        PasswordField {
            id: passwordField
            Layout.fillHeight: true
            colBackground: root.colLayer1
            colText: root.colOnLayer1
            colPlaceholder: root.colSubtext
            colAccent: root.colPrimary
            fontFamily: root.fontFamily
            fontSize: root.fontSize
            onAccepted: {
                sddm.login(root.currentUserName, passwordField.text, root.currentSessionIndex)
            }
        }

        ToolbarButton {
            id: confirmButton
            implicitWidth: height
            toggled: true
            colBackgroundToggled: root.colPrimary
            colBackgroundToggledHover: Qt.lighter(root.colPrimary, 1.1)
            iconText: "arrow_right_alt"
            iconColor: root.colOnPrimary
            iconSize: 24
            colShadow: root.colShadow
            onClicked: {
                sddm.login(root.currentUserName, passwordField.text, root.currentSessionIndex)
            }
        }
    }

    // ========== LEFT TOOLBAR (user + keyboard layout) ==========
    Toolbar {
        id: leftIsland
        anchors {
            right: mainIsland.left
            top: mainIsland.top
            bottom: mainIsland.bottom
            rightMargin: 10
        }
        colBackground: root.colSurfaceContainer
        colShadow: root.colShadow
        scale: root.toolbarScale
        opacity: root.toolbarOpacity

        UserSelector {
            Layout.fillHeight: true
            Layout.leftMargin: 2
            Layout.rightMargin: 4
            currentIndex: root.currentUserIndex
            userCount: userModel.count
            userName: root.currentUserName
            colText: root.colOnSurfaceVariant
            fontFamily: root.fontFamily
            fontSize: root.fontSize
            onUserChanged: function(idx) {
                root.currentUserIndex = idx
                root.currentUserName = root.getUserName(idx)
            }
        }

        SessionSelector {
            Layout.fillHeight: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            currentIndex: root.currentSessionIndex
            sessionCount: sessionModel.count
            sessionName: root.getSessionName(root.currentSessionIndex)
            colText: root.colOnSurfaceVariant
            fontFamily: root.fontFamily
            fontSize: root.fontSize
            onSessionChanged: function(idx) {
                root.currentSessionIndex = idx
            }
        }

    }

    // ========== RIGHT TOOLBAR (session + power buttons) ==========
    Toolbar {
        id: rightIsland
        anchors {
            left: mainIsland.right
            top: mainIsland.top
            bottom: mainIsland.bottom
            leftMargin: 10
        }
        colBackground: root.colSurfaceContainer
        colShadow: root.colShadow
        scale: root.toolbarScale
        opacity: root.toolbarOpacity

        // Keyboard: click toggles virtual keyboard, scroll cycles layout
        Item {
            Layout.fillHeight: true
            implicitWidth: kbRow.implicitWidth + 16
            clip: false

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: root.virtualKeyboardVisible
                    ? (kbMouse.containsMouse ? Qt.lighter(root.colPrimaryContainer, 1.1) : root.colPrimaryContainer)
                    : (kbMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                Behavior on color { ColorAnimation { duration: 80 } }
            }

            Item {
                id: kbRow
                anchors.centerIn: parent
                implicitWidth: 22
                implicitHeight: 22
                clip: false

                Text {
                    anchors.centerIn: parent
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 22
                    text: "keyboard"
                    color: root.colOnSurfaceVariant
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    id: kbBadge
                    property string lang: root.getKeyboardLayout()
                    visible: true
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -10
                    anchors.topMargin: -8
                    width: Math.max(kbBadgeText.implicitWidth + 6, height)
                    height: 15
                    radius: 7
                    color: root.colPrimary
                    z: 10

                    Text {
                        id: kbBadgeText
                        anchors.centerIn: parent
                        text: kbBadge.lang !== "" ? kbBadge.lang : Tr.tr("kb")
                        color: root.colOnPrimary
                        font.family: root.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        renderType: Text.NativeRendering
                    }
                }
            }

            MouseArea {
                id: kbMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton) {
                        keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
                    } else {
                        root.virtualKeyboardVisible = !root.virtualKeyboardVisible
                        passwordField.forceActiveFocus()
                    }
                }
                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
                    } else if (wheel.angleDelta.y < 0) {
                        keyboard.currentLayout = (keyboard.currentLayout - 1 + keyboard.layouts.length) % keyboard.layouts.length
                    }
                }
            }

            scale: kbMouse.pressed ? 0.92 : 1.0
            Behavior on scale { NumberAnimation { duration: 80 } }
        }

        // Battery indicator (reads from sysfs)
        Item {
            Layout.fillHeight: true
            implicitWidth: batteryIconItem.implicitWidth + 16
            clip: false

            Item {
                id: batteryIconItem
                anchors.centerIn: parent
                implicitWidth: 22
                implicitHeight: 22
                clip: false

                Text {
                    anchors.centerIn: parent
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 22
                    text: batteryTimer.icon
                    color: root.colOnSurfaceVariant
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    id: batteryBadge
                    visible: batteryTimer.level >= 0
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -10
                    anchors.topMargin: -8
                    width: Math.max(batteryBadgeText.implicitWidth + 6, height)
                    height: 15
                    radius: 7
                    color: root.colPrimary
                    z: 10

                    Text {
                        id: batteryBadgeText
                        anchors.centerIn: parent
                        text: batteryTimer.level + "%"
                        color: root.colOnPrimary
                        font.family: root.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        renderType: Text.NativeRendering
                    }
                }
            }
        }

        ToolbarButton {
            iconText: "dark_mode"
            iconColor: root.colOnSurfaceVariant
            colShadow: root.colShadow
            onClicked: sddm.suspend()
        }

        ToolbarButton {
            iconText: "power_settings_new"
            iconColor: root.colOnSurfaceVariant
            colShadow: root.colShadow
            onClicked: sddm.powerOff()
        }

        ToolbarButton {
            iconText: "restart_alt"
            iconColor: root.colOnSurfaceVariant
            colShadow: root.colShadow
            onClicked: sddm.reboot()
        }
    }

    // ========== BATTERY READER ==========
    Timer {
        id: batteryTimer
        property int level: -1
        property bool charging: false
        property string icon: "battery_android_full"
        property var batPaths: ["BAT0", "BAT1", "BAT2", "BATT", "battery"]
        property string foundBat: ""

        function readFile(path) {
            try {
                var xhr = new XMLHttpRequest()
                xhr.open("GET", "file://" + path, false)
                xhr.send()
                if ((xhr.status === 200 || xhr.status === 0) && xhr.responseText.trim() !== "")
                    return xhr.responseText.trim()
            } catch(e) {}
            return ""
        }

        function readBattery() {
            var paths = ["/sys/class/power_supply/BAT0", "/sys/class/power_supply/BAT1", "/sys/class/power_supply/BAT2"]
            if (foundBat === "") {
                for (var i = 0; i < paths.length; i++) {
                    var cap = readFile(paths[i] + "/capacity")
                    if (cap !== "") { foundBat = paths[i]; break }
                }
            }
            if (foundBat === "") { level = -1; return }

            var cap = readFile(foundBat + "/capacity")
            if (cap !== "") level = parseInt(cap)
            else level = -1

            var status = readFile(foundBat + "/status")
            charging = (status === "Charging")

            icon = charging ? "bolt" : "battery_android_full"
        }

        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: readBattery()
    }

    // ========== SDDM CONNECTIONS ==========
    Connections {
        target: sddm
        function onLoginFailed() {
            passwordField.loginFailed()
        }
        function onLoginSucceeded() {}
    }

    // ========== KEYBOARD SHORTCUTS ==========
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            passwordField.text = ""
        }
        passwordField.forceActiveFocus()
    }

    // ========== VIRTUAL KEYBOARD ==========
    Loader {
        id: virtualKeyboardLoader
        source: "Components/VirtualKeyboard.qml"
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.5
        y: parent.height

        onItemChanged: {
            if (item) {
                item.activated = Qt.binding(function() { return root.virtualKeyboardVisible })
                // Sync back: if user closes via Qt's built-in hide button
                item.activeChanged.connect(function() {
                    if (!item.active && root.virtualKeyboardVisible) {
                        root.virtualKeyboardVisible = false
                    }
                })
            }
        }

        state: root.virtualKeyboardVisible ? "visible" : "hidden"
        states: [
            State {
                name: "hidden"
                PropertyChanges { target: virtualKeyboardLoader; y: root.height }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: virtualKeyboardLoader
                    y: root.height - virtualKeyboardLoader.height
                }
            }
        ]
        transitions: Transition {
            NumberAnimation {
                property: "y"
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }
}
