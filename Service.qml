pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons

Item {
    id: root
    property var shell: null
    property var manifest: null
    readonly property string moduleName: "palccod.bloub-avatar"
    readonly property string home: Quickshell.env("HOME")
    
    // Settings
    property bool avatarActive: true
    property bool positionLocked: true
    property int positionX: -1
    property int positionY: -1
    readonly property int minimumAvatarWidth: 60
    readonly property int maximumAvatarWidth: 640
    property int avatarWidth: 200
    readonly property int avatarHeight: 200  // Square avatar
    
    property string shape: "nuage"
    property string colorMode: "theme"
    property string customColor: "#3b93f0"
    property string expression: "idle"
    property real animationSpeed: 1.0
    property int workspaceId: 0
    
    readonly property bool avatarColorized: colorMode !== "default"
    readonly property color avatarTint: colorMode === "theme" ? Color.accent : customColor
    
    readonly property var idleService: shell && typeof shell.serviceFor === "function" ? shell.serviceFor("omarchy.idle") : null
    readonly property var lockService: shell && typeof shell.serviceFor === "function" ? shell.serviceFor("omarchy.lock") : null
    readonly property bool presentationSuppressed: (idleService && idleService.screensaverWindowCount > 0) || (lockService && lockService.locked)
    readonly property bool avatarVisible: avatarActive && !presentationSuppressed
    
    visible: false
    width: 0
    height: 0
    
    function localPath(relativePath) {
        return Qt.resolvedUrl(relativePath).toString().replace(/^file:\/\//, "")
    }
    
    function defaults() {
        return {
            active: true,
            positionLocked: true,
            positionX: -1,
            positionY: -1,
            avatarWidth: 200,
            shape: "nuage",
            colorMode: "theme",
            customColor: "#3b93f0",
            expression: "idle",
            animationSpeed: 1.0,
            workspaceId: 0
        }
    }
    
    function boolValue(value, fallback) {
        if (value === true || value === false) return value
        if (value === undefined || value === null) return fallback
        var text = String(value).toLowerCase()
        return text === "true" || text === "1" || text === "yes" || text === "on"
    }
    
    function intValue(value, fallback, minimum, maximum) {
        var parsed = parseInt(String(value), 10)
        if (!isFinite(parsed)) parsed = fallback
        return Math.max(minimum, Math.min(maximum, parsed))
    }
    
    function realValue(value, fallback, minimum, maximum) {
        var parsed = parseFloat(String(value))
        if (!isFinite(parsed)) parsed = fallback
        return Math.max(minimum, Math.min(maximum, parsed))
    }
    
    function mergedSettings(settings) {
        var merged = defaults()
        if (settings) {
            for (var key in settings) {
                if (key === "active") merged.active = boolValue(settings[key], merged.active)
                else if (key === "positionLocked") merged.positionLocked = boolValue(settings[key], merged.positionLocked)
                else if (key === "positionX") merged.positionX = intValue(settings[key], merged.positionX, -1, 16000)
                else if (key === "positionY") merged.positionY = intValue(settings[key], merged.positionY, -1, 16000)
                else if (key === "avatarWidth") merged.avatarWidth = intValue(settings[key], merged.avatarWidth, minimumAvatarWidth, maximumAvatarWidth)
                else if (key === "shape") merged.shape = String(settings[key] || merged.shape)
                else if (key === "colorMode") merged.colorMode = String(settings[key] || merged.colorMode)
                else if (key === "customColor") merged.customColor = String(settings[key] || merged.customColor)
                else if (key === "expression") merged.expression = String(settings[key] || merged.expression)
                else if (key === "animationSpeed") merged.animationSpeed = realValue(settings[key], merged.animationSpeed, 0.25, 3.0)
                else if (key === "workspaceId") merged.workspaceId = intValue(settings[key], merged.workspaceId, 0, 10)
            }
        }
        return merged
    }
    
    function applySettings(settings) {
        var m = mergedSettings(settings)
        avatarActive = m.active
        positionLocked = m.positionLocked
        positionX = m.positionX
        positionY = m.positionY
        avatarWidth = m.avatarWidth
        shape = m.shape
        colorMode = m.colorMode
        customColor = m.customColor
        expression = m.expression
        animationSpeed = m.animationSpeed
        workspaceId = m.workspaceId
    }
    
    function resolvedX(screen) {
        var maxX = Math.max(0, screen.width - avatarWidth)
        if (positionX < 0) return Math.round((screen.width - avatarWidth) / 2)
        return Math.min(positionX, maxX)
    }
    
    function resolvedY(screen) {
        var maxY = Math.max(0, screen.height - avatarHeight)
        if (positionY < 0) return Math.round((screen.height - avatarHeight) / 2)
        return Math.min(positionY, maxY)
    }
    
    function resolvedWindowY(screen) {
        var maxY = Math.max(0, screen.height - avatarHeight)
        if (positionY < 0) return Math.round((screen.height - avatarHeight) / 2) + 27  // Account for bar
        return Math.min(positionY, maxY)
    }
    
    function screenEnabled(screen) {
        if (!monitorName || monitorName === "") return true
        return screen.name === monitorName
    }
    
    function workspaceEnabled(screen) {
        if (workspaceId === 0) return true
        var ws = shell && shell.workspaces ? shell.workspaces(screen) : null
        if (!ws) return true
        return ws.indexOf(workspaceId) >= 0
    }
    
    function previewPosition(x, y, screen) {
        positionX = x
        positionY = y - frameTopInset
    }
    
    function commitPosition() {
        // Position is already set in previewPosition
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { positionX: positionX, positionY: positionY })
        }
    }
    
    function setPositionLocked(locked) {
        positionLocked = locked
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { positionLocked: positionLocked })
        }
    }
    
    function resizeCat(delta) {
        var newWidth = Math.max(minimumAvatarWidth, Math.min(maximumAvatarWidth, avatarWidth + delta))
        avatarWidth = newWidth
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { avatarWidth: avatarWidth })
        }
    }
    
    function setCatActive(active) {
        avatarActive = active
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { active: avatarActive })
        }
    }
    
    function setPosition(x, y) {
        positionX = x
        positionY = y
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { positionX: positionX, positionY: positionY })
        }
    }
    
    function setShape(newShape) {
        shape = newShape
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { shape: shape })
        }
    }
    
    function setColorMode(mode) {
        colorMode = mode
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { colorMode: colorMode })
        }
    }
    
    function setCustomColor(color) {
        customColor = color
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { customColor: customColor })
        }
    }
    
    function setExpression(expr) {
        expression = expr
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { expression: expression })
        }
    }
    
    function setAnimationSpeed(speed) {
        animationSpeed = speed
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { animationSpeed: animationSpeed })
        }
    }
    
    function setWorkspaceId(wsId) {
        workspaceId = wsId
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { workspaceId: workspaceId })
        }
    }
    
    function setMonitorName(name) {
        monitorName = name
        if (root.bar) {
            root.bar.shell.updateEntryInline(moduleName, { monitorName: monitorName })
        }
    }
    
    // Exported functions for bar widget
    function rescan(): void { }
    function status(): string {
        return JSON.stringify({
            active: root.avatarActive,
            locked: root.positionLocked,
            x: root.positionX,
            y: root.positionY,
            width: root.avatarWidth,
            shape: root.shape,
            colorMode: root.colorMode,
            expression: root.expression,
            animationSpeed: root.animationSpeed,
            workspace: root.workspaceId
        })
    }
    
    Component.onCompleted: {
        applySettings(pluginSettings)
    }
    
    onPluginSettingsChanged: applySettings(pluginSettings)
    
    readonly property int frameTopInset: 0
    property string monitorName: ""
    
    Variants {
        model: Quickshell.screens
        Scope {
            id: screenScope
            required property var modelData
            
            PanelWindow {
                id: displayWindow
                screen: screenScope.modelData
                visible: root.avatarVisible && root.positionLocked && root.screenEnabled(screenScope.modelData) && root.workspaceEnabled(screenScope.modelData)
                color: "transparent"
                implicitWidth: root.avatarWidth
                implicitHeight: root.avatarHeight
                exclusionMode: ExclusionMode.Ignore
                anchors {
                    top: root.positionY >= 0
                    bottom: root.positionY < 0
                    left: root.positionX >= 0
                    right: root.positionX < 0
                }
                margins {
                    left: root.positionX >= 0 ? root.resolvedX(screenScope.modelData) : 0
                    right: root.positionX < 0 ? 36 : 0
                    top: root.positionY >= 0 ? root.resolvedWindowY(screenScope.modelData) : 0
                    bottom: root.positionY < 0 ? 54 : 0
                }
                mask: Region {}
                WlrLayershell.namespace: "palccod-bloub-avatar"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                
                BloubAvatar {
                    anchors.fill: parent
                    source: Qt.resolvedUrl("assets/bloub-avatar.svg")
                    colorized: root.avatarColorized
                    tint: root.avatarTint
                    avatarWidth: root.avatarWidth
                    animationSpeed: root.animationSpeed
                }
            }
            
            PanelWindow {
                id: editWindow
                screen: screenScope.modelData
                visible: root.avatarVisible && !root.positionLocked && root.screenEnabled(screenScope.modelData) && root.workspaceEnabled(screenScope.modelData)
                color: "transparent"
                exclusionMode: ExclusionMode.Ignore
                anchors { top: true; bottom: true; left: true; right: true }
                mask: Region { item: editorAvatar }
                WlrLayershell.namespace: "palccod-bloub-avatar-position"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                
                Item {
                    id: editorAvatar
                    x: root.resolvedX(screenScope.modelData)
                    y: root.resolvedWindowY(screenScope.modelData)
                    width: root.avatarWidth
                    height: root.avatarHeight
                    
                    BloubAvatar {
                        anchors.fill: parent
                        source: Qt.resolvedUrl("assets/bloub-avatar.svg")
                        colorized: root.avatarColorized
                        tint: root.avatarTint
                        avatarWidth: root.avatarWidth
                        animationSpeed: root.animationSpeed
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: 2
                        border.color: root.avatarTint
                        radius: 8
                    }
                    
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 8
                        width: dragLabel.implicitWidth + 16
                        height: dragLabel.implicitHeight + 8
                        radius: 4
                        color: "#cc111111"
                        Text {
                            id: dragLabel
                            anchors.centerIn: parent
                            text: "Drag · Scroll to resize · Right-click to lock"
                            color: "white"
                            font.pixelSize: 11
                        }
                    }
                    
                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        hoverEnabled: true
                        cursorShape: pressedButtons & Qt.LeftButton ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        property real pressOffsetX: 0
                        property real pressOffsetY: 0
                        
                        onPressed: function(mouse) {
                            if (mouse.button !== Qt.LeftButton) return
                            pressOffsetX = mouse.x
                            pressOffsetY = mouse.y
                        }
                        
                        onPositionChanged: function(mouse) {
                            if (!(pressedButtons & Qt.LeftButton)) return
                            var point = editorAvatar.mapToItem(editWindow.contentItem, mouse.x, mouse.y)
                            root.previewPosition(point.x - pressOffsetX, point.y - pressOffsetY + root.frameTopInset, screenScope.modelData)
                        }
                        
                        onReleased: function(mouse) {
                            if (mouse.button === Qt.LeftButton) root.commitPosition()
                        }
                        
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton) root.setPositionLocked(true)
                        }
                        
                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y === 0) return
                            root.resizeCat(wheel.angleDelta.y > 0 ? 20 : -20)
                            wheel.accepted = true
                        }
                    }
                }
            }
        }
    }
}