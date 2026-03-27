import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: root

    anchors.left: true
    anchors.top:  true
    exclusiveZone: 0

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    
    WlrLayershell.margins {
        top: 300
    }

    readonly property int tabW:   10
    readonly property int tabH:   100
    readonly property int panelW: 350
    readonly property int panelH: 44

    implicitWidth:  tabW + panelW
    implicitHeight: panelH

    color: "transparent"

    property bool   panelOpen:  false
    property var    commands:   []
    property string suggestion: ""

    // ── Load completions from .dat file ──────────────────────────────────────
    // Format: one command per line, plain text
    FileView {
        id: commandsFile
        path: Qt.resolvedUrl("./commands.dat").toString().replace("file://", "")
        watchChanges: true
        onTextChanged: {
            var lines = commandsFile.text().split("\n")
            var cmds = []
            for (var i = 0; i < lines.length; i++) {
                var l = lines[i].trim()
                if (l.length > 0) cmds.push(l)
            }
            root.commands = cmds
        }
        onFileChanged: commandsFile.reload()
    }

    Component.onCompleted: {
        var t = commandsFile.text()
        if (t && t.length > 0) {
            var lines = t.split("\n")
            var cmds = []
            for (var i = 0; i < lines.length; i++) {
                var l = lines[i].trim()
                if (l.length > 0) cmds.push(l)
            }
            root.commands = cmds
        }
    }

    // Find first command that starts with current input
    function findSuggestion(text) {
        if (text.length === 0) return ""
        for (var i = 0; i < commands.length; i++) {
            if (commands[i].indexOf(text) === 0 && commands[i] !== text)
                return commands[i].substring(text.length)
        }
        return ""
    }

    // ── Open / close ─────────────────────────────────────────────────────────
    Timer {
        id: closeTimer
        interval: 400
        onTriggered: if (!cmdInput.activeFocus) root.panelOpen = false
    }

    onPanelOpenChanged: {
        if (panelOpen) {
            focusTimer.restart()
        } else {
            cmdInput.text = ""
            root.suggestion = ""
            cmdInput.focus = false
        }
    }

    Timer {
        id: focusTimer
        interval: 80
        onTriggered: cmdInput.forceActiveFocus()
    }

    // ── Launch ───────────────────────────────────────────────────────────────
    Process {
        id: launchProc
        property string cmd: ""
        command: ["bash", "-c", "quickshell-run " + launchProc.cmd]
        running: false
    }

    function submit() {
        var text = cmdInput.text.trim()
        if (text.length === 0) return
        launchProc.cmd = text
        launchProc.running = true
        cmdInput.text = ""
        root.suggestion = ""
        root.panelOpen = false
    }

    function acceptSuggestion() {
        if (root.suggestion.length === 0) return
        cmdInput.text = cmdInput.text + root.suggestion
        cmdInput.cursorPosition = cmdInput.text.length
        root.suggestion = ""
    }

    mask: Region { item: clipper }

    // ── Visual ───────────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent

        // ── Tab pill ─────────────────────────────────────────────────────────
        Item {
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            width:  root.tabW
            height: root.tabH
            z: 2

            HoverHandler {
                id: tabHover
                onHoveredChanged: {
                    if (hovered) { closeTimer.stop(); root.panelOpen = true }
                    else closeTimer.restart()
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(
                    Theme.violetBright.r,
                    Theme.violetBright.g,
                    Theme.violetBright.b,
                    tabHover.hovered || root.panelOpen ? 0.6 : 0.35
                )
                border.color: Theme.borderIdle
                border.width: 1

                Behavior on color { ColorAnimation { duration: 160 } }

                Text {
                    anchors.centerIn: parent
                    text:    "›"
                    color:   Theme.textPrimary
                    opacity: root.panelOpen ? 0.0 : 0.8
                    font { family: Theme.fontFamily; pixelSize: 10; weight: Font.Medium }
                    Behavior on opacity { NumberAnimation { duration: 160 } }
                }
            }
        }

        // ── Clip wrapper ──────────────────────────────────────────────────────
        Item {
            id: clipper
            anchors.left:   parent.left
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width: root.panelOpen ? root.tabW + root.panelW : root.tabW
            clip:  true

            Behavior on width {
                NumberAnimation { duration: 260; easing.type: Easing.InOutCubic }
            }

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) { closeTimer.stop(); root.panelOpen = true }
                    else closeTimer.restart()
                }
            }

            Rectangle {
                anchors.left:   parent.left
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                width: root.tabW + root.panelW
                color:        "#2E3440"
                radius:       8
                border.color: Theme.borderIdle
                border.width: 1

                // Left accent stripe
                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                    width: 2; radius: 8
                    color: Qt.rgba(
                        Theme.violetBright.r,
                        Theme.violetBright.g,
                        Theme.violetBright.b,
                        0.55
                    )
                }

                // ── Input row ─────────────────────────────────────────────────
                Row {
                    anchors {
                        left: parent.left; leftMargin: root.tabW + 10
                        right: parent.right; rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 8

                    opacity: root.panelOpen ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 160 } }

                    // Prompt symbol
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text:  "›"
                        color: Theme.violetBright
                        font { family: Theme.fontFamily; pixelSize: 16; weight: Font.Medium }
                    }

                    // Input + ghost text container
                    Item {
                        width: root.panelW - root.tabW - 52
                        height: cmdInput.height
                        anchors.verticalCenter: parent.verticalCenter

                        TextInput {
                            id: cmdInput
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                            color:          Theme.textPrimary
                            selectionColor: Theme.violetBright
                            font { family: Theme.fontFamily; pixelSize: 13 }
                            clip: true

                            // Placeholder
                            Text {
                                visible:      cmdInput.text.length === 0 && !cmdInput.activeFocus
                                anchors.fill: parent
                                text:         "run command..."
                                color:        Theme.textDim
                                font:         cmdInput.font
                                verticalAlignment: Text.AlignVCenter
                            }

                            // Ghost text — sits right after the typed text
                            Text {
                                id: ghostText
                                visible: root.suggestion.length > 0 && cmdInput.activeFocus
                                x: cmdInput.contentWidth
                                anchors.verticalCenter: parent.verticalCenter
                                text:  root.suggestion
                                color: Theme.textPrimary
                                opacity: 0.3
                                font:  cmdInput.font
                            }

                            onTextChanged: {
                                root.suggestion = root.findSuggestion(text)
                            }

                            Keys.onReturnPressed:  root.submit()
                            Keys.onEscapePressed:  root.panelOpen = false
                            Keys.onTabPressed:     { root.acceptSuggestion(); event.accepted = true }
                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Right && cursorPosition === text.length) {
                                    root.acceptSuggestion()
                                    event.accepted = true
                                }
                            }
                        }
                    }

                    // Run button
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24; height: 24; radius: 4
                        color: cmdInput.text.length > 0
                            ? Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.25)
                            : Qt.rgba(1, 1, 1, 0.05)

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text:  "↵"
                            color: cmdInput.text.length > 0 ? Theme.violetBright : Theme.textDim
                            font { family: Theme.fontFamily; pixelSize: 13 }
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    root.submit()
                        }
                    }
                }
            }
        }
    }
}
