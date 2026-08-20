pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Panel {
    id: root
    moduleName: "palccod.bloub-avatar"
    ipcTarget: ""
    manageIpc: false
    
    readonly property var bloub: bar && bar.shell && typeof bar.shell.serviceFor === "function" ? bar.shell.serviceFor(moduleName) : null
    readonly property color foreground: bar ? bar.foreground : Color.foreground
    readonly property color background: bar ? bar.background : Color.background
    readonly property color accent: bar ? bar.urgent : Color.accent
    readonly property color dim: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.58)
    readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
    
    readonly property var activeScreen: bloub ? bloub.targetScreen() : null
    readonly property int positionXValue: bloub && activeScreen ? Math.round(bloub.resolvedX(activeScreen)) : 0
    readonly property int positionYValue: bloub && activeScreen ? Math.round(bloub.resolvedY(activeScreen)) : 0
    readonly property int positionXMaximum: bloub && activeScreen ? Math.max(0, activeScreen.width - bloub.avatarWidth) : 8000
    readonly property int positionYMaximum: bloub && activeScreen ? Math.max(0, activeScreen.height - bloub.avatarHeight) : 8000
    readonly property bool presentationSuppressed: bloub ? bloub.presentationSuppressed : false
    
    property var panelSessionService: null
    
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight
    
    onOpenedChanged: {
        if (opened) {
            beginPanelSession()
            if (bloub) {
                bloub.scanDevices && bloub.scanDevices()
            }
            Qt.callLater(function() { keyCatcher.forceActiveFocus() })
        } else {
            finishPanelSession()
        }
    }
    
    onBloubChanged: if (opened) beginPanelSession()
    onPresentationSuppressedChanged: if (presentationSuppressed) close()
    Component.onDestruction: abandonPanelSession()
    
    function beginPanelSession() {
        if (panelSessionService || !bloub || typeof bloub.beginPanelSession !== "function") return
        panelSessionService = bloub
        panelSessionService.beginPanelSession()
    }
    
    function finishPanelSession() {
        if (!panelSessionService) return
        var service = panelSessionService
        panelSessionService = null
        if (typeof service.endPanelSession === "function") service.endPanelSession()
    }
    
    function abandonPanelSession() {
        if (!panelSessionService) return
        var service = panelSessionService
        panelSessionService = null
        if (typeof service.abandonPanelSession === "function") service.abandonPanelSession()
    }
    
    function toggleActive() {
        if (bloub) bloub.setCatActive(!bloub.avatarActive)
    }
    
    function moveFromPanel(dx, dy) {
        if (!bloub) return
        bloub.setPosition(positionXValue + dx, positionYValue + dy)
    }
    
    // Bar button
    WidgetButton {
        id: button
        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                opened = !opened
            } else if (mouse.button === Qt.RightButton) {
                toggleActive()
            } else if (mouse.button === Qt.MiddleButton) {
                // Middle click to test animation
                if (bloub) bloub.setExpression("wink")
            }
        }
        onWheel: function(wheel) {
            if (!bloub) return
            if (wheel.modifiers & Qt.ControlModifier) {
                bloub.resizeCat(wheel.angleDelta.y > 0 ? 20 : -20)
            }
            wheel.accepted = true
        }
        tooltipText: "Bloub Avatar\nLeft-click: Open panel\nRight-click: Toggle active\nMiddle-click: Test animation\nCtrl+Wheel: Resize"
        
        OpticalGlyph {
            id: glyph
            anchors.centerIn: parent
            width: Math.max(Style.space(22), iconSize + Style.space(4))
            height: Math.max(Style.space(22), iconSize + Style.space(4))
            text: bloub && bloub.avatarActive ? "󰸭" : "󰸫"  // Sparkles / sparkles-off
            fontFamily: root.fontFamily
            fontSize: iconSize
            color: bloub && bloub.avatarActive ? root.accent : root.dim
        }
    }
    
    // Keyboard navigation
    Item {
        id: keyCatcher
        focus: true
        Keys.onPressed: function(event) {
            if (!bloub) return
            if (event.key === Qt.Key_Escape) {
                close()
                event.accepted = true
            } else if (event.key === Qt.Key_P) {
                bloub.setPositionLocked(!bloub.positionLocked)
                event.accepted = true
            } else if (event.key === Qt.Key_T) {
                bloub.setExpression("wink")
                event.accepted = true
            } else if (event.key === Qt.Key_R) {
                bloub.rescan && bloub.rescan()
                event.accepted = true
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                moveFromPanel(-10, 0)
                event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                moveFromPanel(10, 0)
                event.accepted = true
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                moveFromPanel(0, -10)
                event.accepted = true
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                moveFromPanel(0, 10)
                event.accepted = true
            }
        }
    }
    
    // Panel content
    Column {
        id: panelContent
        width: Style.space(320)
        spacing: Style.spacing.lg
        
        // Header
        Row {
            width: parent.width
            spacing: Style.spacing.md
            
            Text {
                text: "Bloub Avatar"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
                font.bold: true
            }
            
            Item { Layout.fillWidth: true }
            
            // Compact header buttons
            Row { spacing: Style.spacing.sm
                Button {
                    height: Style.spacing.controlHeight
                    text: bloub && bloub.avatarActive ? "Disable" : "Enable"
                    tooltipText: "Toggle avatar visibility"
                    bordered: true
                    focusable: true
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onClicked: toggleActive()
                }
                
                Button {
                    height: Style.spacing.controlHeight
                    text: bloub && !bloub.positionLocked ? "Lock" : "Unlock"
                    tooltipText: bloub && !bloub.positionLocked ? "Lock position" : "Unlock for dragging"
                    bordered: true
                    focusable: true
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onClicked: bloub.setPositionLocked(!bloub.positionLocked)
                    enabled: bloub && bloub.avatarActive
                }
                
                Button {
                    height: Style.spacing.controlHeight
                    text: "Test"
                    tooltipText: "Play test animation"
                    bordered: true
                    focusable: true
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onClicked: bloub.setExpression("wink")
                    enabled: bloub && bloub.avatarActive
                }
            }
        }
        
        // Active toggle
        Row {
            width: parent.width
            spacing: Style.spacing.md
            
            Text {
                text: "Active"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                verticalAlignment: Text.AlignVCenter
            }
            
            Item { Layout.fillWidth: true }
            
            Switch {
                checked: bloub ? bloub.avatarActive : false
                onCheckedChanged: toggleActive()
            }
        }
        
        // Position lock
        Row {
            width: parent.width
            spacing: Style.spacing.md
            visible: bloub && bloub.avatarActive
            
            Text {
                text: "Lock Position"
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                verticalAlignment: Text.AlignVCenter
            }
            
            Item { Layout.fillWidth: true }
            
            Switch {
                checked: bloub ? bloub.positionLocked : true
                onCheckedChanged: bloub.setPositionLocked(checked)
            }
        }
        
        // Shape selector
        Row {
            width: parent.width
            spacing: Style.spacing.md
            visible: bloub && bloub.avatarActive
            
            Column {
                width: parent.width
                spacing: Style.spacing.xs
                
                Text {
                    text: "Shape"
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                }
                
                Dropdown {
                    width: parent.width
                    label: ""
                    showLabel: false
                    value: bloub ? bloub.shape : "nuage"
                    options: [
                        { value: "nuage", label: "☁ Cloud (default)" },
                        { value: "cercle", label: "⭘ Circle" },
                        { value: "galet", label: "🪨 Pebble" },
                        { value: "squircle", label: "⬢ Squircle" },
                        { value: "capsule", label: "💊 Capsule" },
                        { value: "triangle", label: "🔺 Triangle" },
                        { value: "hexagone", label: "⬡ Hexagon" },
                        { value: "goutte", label: "💧 Droplet" }
                    ]
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onChanged: function(next) { if (bloub) bloub.setShape(next) }
                }
            }
        }
        
        // Color mode selector
        Row {
            width: parent.width
            spacing: Style.spacing.md
            visible: bloub && bloub.avatarActive
            
            Column {
                width: parent.width
                spacing: Style.spacing.xs
                
                Text {
                    text: "Color Mode"
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                }
                
                Dropdown {
                    width: parent.width
                    label: ""
                    showLabel: false
                    value: bloub ? bloub.colorMode : "theme"
                    options: [
                        { value: "default", label: "Default (Ink #0a0a0c)" },
                        { value: "theme", label: "Theme Accent (synced)" },
                        { value: "custom", label: "Custom Color" }
                    ]
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onChanged: function(next) { if (bloub) bloub.setColorMode(next) }
                }
            }
        }
        
        // Custom color picker (shown when colorMode is custom)
        Row {
            width: parent.width
            spacing: Style.spacing.md
            visible: bloub && bloub.avatarActive && bloub.colorMode === "custom"
            
            Column {
                width: parent.width
                spacing: Style.spacing.xs
                
                Text {
                    text: "Custom Color"
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                }
                
                Row {
                    spacing: Style.spacing.sm
                    
                    ColorButton {
                        id: customColorBtn
                        color: bloub ? bloub.customColor : "#3b93f0"
                        width: Style.space(80)
                        height: Style.spacing.controlHeight
                        onColorChanged: function(color) { if (bloub) bloub.setCustomColor(color) }
                    }
                    
                    TextField {
                        id: colorHexInput
                        text: bloub ? bloub.customColor : "#3b93f0"
                        placeholderText: "#RRGGBB"
                        width: parent.width - Style.space(80) - Style.spacing.sm
                        height: Style.spacing.controlHeight
                        foreground: root.foreground
                        accent: root.accent
                        fontFamily: root.fontFamily
                        onAccepted: {
                            if (bloub && text.length === 7 && text[0] === "#") {
                                bloub.setCustomColor(text)
                                customColorBtn.color = text
                            }
                        }
                    }
                }
            }
        }
        
        // Expression selector
        Row {
            width: parent.width
            spacing: Style.spacing.md
            visible: bloub && bloub.avatarActive
            
            Column {
                width: parent.width
                spacing: Style.spacing.xs
                
                Text {
                    text: "Rest Expression"
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                }
                
                Dropdown {
                    width: parent.width
                    label: ""
                    showLabel: false
                    value: bloub ? bloub.expression : "idle"
                    options: [
                        { value: "idle", label: "😐 Idle" },
                        { value: "thinking", label: "🤔 Thinking" },
                        { value: "sleep", label: "😴 Sleep" },
                        { value: "wink", label: "😉 Wink" },
                        { value: "wide", label: "😲 Wide Eyes" },
                        { value: "alert", label: "⚠ Alert" },
                        { value: "happy", label: "😊 Happy" }
                    ]
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onChanged: function(next) { if (bloub) bloub.setExpression(next) }
                }
            }
        }
        
        // Animation speed
        Row {
            width: parent.width
            spacing: Style.spacing.md
            visible: bloub && bloub.avatarActive
            
            Column {
                width: parent.width
                spacing: Style.spacing.xs
                
                Row {
                    Text {
                        text: "Animation Speed"
                        color: root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.body
                    }
                    Text {
                        text: (bloub ? bloub.animationSpeed : 1.0).toFixed(2) + "x"
                        color: root.dim
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.bodySmall
                    }
                }
                
                Slider {
                    width: parent.width
                    from: 0.25
                    to: 3.0
                    stepSize: 0.25
                    value: bloub ? bloub.animationSpeed : 1.0
                    onValueChanged: function(v) { if (bloub) bloub.setAnimationSpeed(v) }
                    foreground: root.accent
                    background: root.background
                }
            }
        }
        
        // Size slider
        Row {
            width: parent.width
            spacing: Style.spacing.md
            visible: bloub && bloub.avatarActive
            
            Column {
                width: parent.width
                spacing: Style.spacing.xs
                
                Row {
                    Text {
                        text: "Size"
                        color: root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.body
                    }
                    Text {
                        text: (bloub ? bloub.avatarWidth : 200) + " px"
                        color: root.dim
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.bodySmall
                    }
                }
                
                Slider {
                    width: parent.width
                    from: 60
                    to: 640
                    stepSize: 10
                    value: bloub ? bloub.avatarWidth : 200
                    onValueChanged: function(v) { if (bloub) bloub.resizeCat(v - (bloub.avatarWidth || 200)) }
                    foreground: root.accent
                    background: root.background
                }
            }
        }
        
        // Position controls (when unlocked)
        Column {
            visible: bloub && bloub.avatarActive && !bloub.positionLocked
            width: parent.width
            spacing: Style.spacing.md
            
            Text {
                text: "Position (unlocked — drag avatar or use arrows)"
                color: root.accent
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
                horizontalAlignment: Text.AlignHCenter
            }
            
            Row {
                width: parent.width
                spacing: Style.spacing.md
                
                Column {
                    width: parent.width / 2 - Style.spacing.md / 2
                    spacing: Style.spacing.xs
                    
                    Text { text: "X Position"; color: root.foreground; font.family: root.fontFamily; font.pixelSize: Style.font.bodySmall }
                    SpinBox {
                        width: parent.width
                        height: Style.spacing.controlHeight
                        from: -1
                        to: positionXMaximum
                        stepSize: 10
                        value: bloub ? bloub.positionX : -1
                        onValueChanged: function(v) { if (bloub) { bloub.setPosition(v, bloub.positionY) } }
                        foreground: root.foreground
                        accent: root.accent
                        fontFamily: root.fontFamily
                    }
                }
                
                Column {
                    width: parent.width / 2 - Style.spacing.md / 2
                    spacing: Style.spacing.xs
                    
                    Text { text: "Y Position"; color: root.foreground; font.family: root.fontFamily; font.pixelSize: Style.font.bodySmall }
                    SpinBox {
                        width: parent.width
                        height: Style.spacing.controlHeight
                        from: -1
                        to: positionYMaximum
                        stepSize: 10
                        value: bloub ? bloub.positionY : -1
                        onValueChanged: function(v) { if (bloub) { bloub.setPosition(bloub.positionX, v) } }
                        foreground: root.foreground
                        accent: root.accent
                        fontFamily: root.fontFamily
                    }
                }
            }
            
            Row {
                width: parent.width
                spacing: Style.spacing.sm
                
                Button {
                    text: "Center"
                    width: parent.width / 3 - Style.spacing.sm * 2 / 3
                    height: Style.spacing.controlHeight
                    bordered: true
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onClicked: {
                        if (bloub && activeScreen) {
                            bloub.setPosition(-1, -1)
                        }
                    }
                }
                
                Button {
                    text: "Reset"
                    width: parent.width / 3 - Style.spacing.sm * 2 / 3
                    height: Style.spacing.controlHeight
                    bordered: true
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onClicked: {
                        if (bloub) {
                            bloub.setPosition(-1, -1)
                            bloub.resizeCat(200 - (bloub.avatarWidth || 200))
                            bloub.setPositionLocked(true)
                        }
                    }
                }
                
                Button {
                    text: "Lock"
                    width: parent.width / 3 - Style.spacing.sm * 2 / 3
                    height: Style.spacing.controlHeight
                    bordered: true
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onClicked: bloub.setPositionLocked(true)
                }
            }
        }
        
        // Workspace selector
        Row {
            width: parent.width
            spacing: Style.spacing.md
            visible: bloub && bloub.avatarActive
            
            Column {
                width: parent.width
                spacing: Style.spacing.xs
                
                Text {
                    text: "Workspace Visibility"
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                }
                
                Dropdown {
                    width: parent.width
                    label: ""
                    showLabel: false
                    value: bloub ? bloub.workspaceId : 0
                    options: (function() {
                        var opts = [{ value: 0, label: "All Workspaces" }]
                        for (var i = 1; i <= 10; i++) opts.push({ value: i, label: "Workspace " + i })
                        return opts
                    })()
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    onChanged: function(next) { if (bloub) bloub.setWorkspaceId(next) }
                }
            }
        }
        
        // Status display
        Row {
            width: parent.width
            visible: bloub
            spacing: Style.spacing.md
            
            Text {
                text: "Status: " + (bloub.avatarActive ? "Active" : "Inactive")
                color: bloub.avatarActive ? root.accent : root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
            }
            
            Text {
                text: bloub.positionLocked ? "🔒 Locked" : "🔓 Unlocked"
                color: bloub.positionLocked ? root.dim : root.accent
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: "Pos: " + positionXValue + ", " + positionYValue
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
            }
            
            Text {
                text: "Size: " + (bloub.avatarWidth || 200) + "px"
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
            }
        }
        
        // Keyboard shortcuts hint
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: "Shortcuts: P=Lock/Unlock  T=Test  Arrows=Move  Esc=Close"
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            horizontalAlignment: Text.AlignHCenter
        }
    }
}