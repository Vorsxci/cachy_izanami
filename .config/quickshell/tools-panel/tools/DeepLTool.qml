import QtQuick
import Quickshell.Io
import "../../theme"

// DeepLTool.qml
// EN <-> JA translator using the DeepL Free API.
// Paste your API key into the apiKey property below.

Item {
    id: tool

    readonly property string toolLabel:   "\u21c4"
    readonly property color  toolColor:   Theme.mutedblue
    readonly property string toolTooltip: "Translate"

    property bool toolActive: false
    property int  toolIndex:  -1

    // --- Config --------------------------------------------------------------
    // Your DeepL API key. Free tier keys end in ":fx"
    readonly property string apiKey: "f22f0963-9598-4ffe-b763-ec6708f51366:fx"

    // Language pairs available in the picker
    readonly property var langPairs: [
        { from: "EN", to: "JA", label: "EN \u2192 JA" },
        { from: "JA", to: "EN", label: "JA \u2192 EN" }
    ]

    // --- State ---------------------------------------------------------------
    property int    pairIndex:   0
    property string inputText:   ""
    property string outputText:  ""
    property bool   loading:     false
    property string errorMsg:    ""

    onToolActiveChanged: {
        if (toolActive) {
            focusTimer.restart()
        } else {
            sourceInput.text = ""
            inputText        = ""
            outputText       = ""
            errorMsg         = ""
            loading          = false
        }
    }

    Timer { id: focusTimer; interval: 80; onTriggered: sourceInput.forceActiveFocus() }

    Timer {
        id: debounce
        interval: 600
        onTriggered: {
            var t = tool.inputText.trim()
            if (t.length === 0) { tool.outputText = ""; tool.errorMsg = ""; return }
            tool.translate(t)
        }
    }

    Process {
        id: translateProc
        running: false
        command: []
        onRunningChanged: {
            if (!running) { tool.loading = false; resultFile.reload() }
        }
    }

    FileView {
        id: resultFile
        path: "/tmp/deepl_result.json"
        onTextChanged: {
            var raw = resultFile.text()
            if (raw && raw.length > 0) tool.parseResult(raw)
        }
    }

    function translate(text) {
        tool.loading    = true
        tool.outputText = ""
        tool.errorMsg   = ""

        var pair     = tool.langPairs[tool.pairIndex]
        var fromLang = pair.from
        var toLang   = pair.to

        // DeepL free API endpoint
        var endpoint = "https://api-free.deepl.com/v2/translate"

        translateProc.command = [
            "bash", "-c",
            "curl -s --max-time 10 " +
            "-X POST '" + endpoint + "' " +
            "-H 'Authorization: DeepL-Auth-Key " + tool.apiKey + "' " +
            "-H 'Content-Type: application/json' " +
            "-d '{\"text\":[\"" + text.replace(/\\/g, "\\\\").replace(/"/g, "\\\"").replace(/\n/g, "\\n") + "\"]," +
                 "\"source_lang\":\"" + fromLang + "\"," +
                 "\"target_lang\":\"" + toLang + "\"}' " +
            "> /tmp/deepl_result.json"
        ]
        translateProc.running = true
    }

    function parseResult(raw) {
        try {
            var obj = JSON.parse(raw)
            if (obj.translations && obj.translations.length > 0) {
                tool.outputText = obj.translations[0].text
            } else if (obj.message) {
                tool.errorMsg = obj.message
            } else {
                tool.errorMsg = "Unexpected response"
            }
        } catch (e) {
            tool.errorMsg = "Parse error: " + e.message
        }
    }

    // --- UI ------------------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color:        Theme.glassDeep
        radius:       8
        border.color: Theme.borderIdle
        border.width: 1

        // Accent stripe
        Rectangle {
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
            width: 2; radius: 8
            color: Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g, Theme.mutedblue.b, 0.6)
        }

        Item {
            anchors {
                left:   parent.left;   leftMargin:   14
                right:  parent.right;  rightMargin:  12
                top:    parent.top;    topMargin:    10
                bottom: parent.bottom; bottomMargin: 10
            }

            // Header row
            Row {
                id: header
                anchors { left: parent.left; right: parent.right; top: parent.top }
                spacing: 0

                // Title
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:  "DeepL"
                    color: Theme.mutedblue
                    font { family: Theme.fontFamily; pixelSize: 15; weight: Font.Medium }
                }

                Item { width: 10; height: 1 }

                // Language pair picker  click to cycle
                Repeater {
                    model: tool.langPairs
                    delegate: Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width:  pairRect.width
                        height: 22

                        Rectangle {
                            id: pairRect
                            anchors.verticalCenter: parent.verticalCenter
                            height: 20
                            width:  pairLabel.implicitWidth + 14
                            radius: 4
                            color: tool.pairIndex === index
                                ? Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g, Theme.mutedblue.b, 0.25)
                                : Qt.rgba(1, 1, 1, 0.05)
                            border.color: tool.pairIndex === index
                                ? Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g, Theme.mutedblue.b, 0.55)
                                : Theme.borderIdle
                            border.width: 1
                            Behavior on color        { ColorAnimation { duration: 100 } }
                            Behavior on border.color { ColorAnimation { duration: 100 } }

                            Text {
                                id: pairLabel
                                anchors.centerIn: parent
                                text:  modelData.label
                                color: tool.pairIndex === index ? Theme.mutedblue : Theme.textDim
                                font { family: Theme.fontFamily; pixelSize: 10 }
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    tool.pairIndex  = index
                                    tool.outputText = ""
                                    tool.errorMsg   = ""
                                    var t = tool.inputText.trim()
                                    if (t.length > 0) tool.translate(t)
                                }
                            }
                        }

                        // Small gap between pills
                        Item { width: 4; height: 1; anchors.left: pairRect.right }
                    }
                }

                // Loading indicator
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: tool.loading
                    text:    "..."
                    color:   Theme.textDim
                    font { family: Theme.fontFamily; pixelSize: 13 }
                }
            }

            // Source input box
            Rectangle {
                id: sourceBox
                anchors { left: parent.left; right: parent.right; top: header.bottom; topMargin: 8 }
                height: 90
                radius: 5
                color:  Qt.rgba(1, 1, 1, 0.05)
                border.color: sourceInput.activeFocus
                    ? Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g, Theme.mutedblue.b, 0.70)
                    : Theme.borderIdle
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: 120 } }

                TextEdit {
                    id: sourceInput
                    anchors {
                        fill: parent
                        margins: 8
                    }
                    color:          Theme.textPrimary
                    selectionColor: Theme.mutedblue
                    font { family: Theme.fontFamily; pixelSize: 13 }
                    wrapMode: TextEdit.Wrap
                    clip: true

                    Text {
                        visible: sourceInput.text.length === 0 && !sourceInput.activeFocus
                        anchors.fill: parent
                        text:  "type or paste text to translate..."
                        color: Theme.textDim
                        font:  sourceInput.font
                        wrapMode: Text.Wrap
                    }

                    onTextChanged: {
                        tool.inputText = text
                        debounce.restart()
                    }
                    Keys.onEscapePressed: tool.toolActive = false
                }
            }

            // Arrow divider
            Text {
                id: arrow
                anchors { horizontalCenter: parent.horizontalCenter; top: sourceBox.bottom; topMargin: 4 }
                text:  "\u2193"
                color: tool.loading
                    ? Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g, Theme.mutedblue.b, 0.8)
                    : Theme.textDim
                font { family: Theme.fontFamily; pixelSize: 14 }
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            // Output box
            Rectangle {
                anchors { left: parent.left; right: parent.right; top: arrow.bottom; topMargin: 4; bottom: parent.bottom }
                radius: 5
                color:  Qt.rgba(1, 1, 1, 0.03)
                border.color: Theme.borderIdle
                border.width: 1

                // Error
                Text {
                    anchors { fill: parent; margins: 8 }
                    visible: tool.errorMsg.length > 0
                    text:    tool.errorMsg
                    color:   "#e06c75"
                    font { family: Theme.fontFamily; pixelSize: 12 }
                    wrapMode: Text.Wrap
                }

                // Idle hint
                Text {
                    anchors.centerIn: parent
                    visible: tool.outputText.length === 0 && tool.errorMsg.length === 0 && !tool.loading
                    text:    "translation appears here"
                    color:   Theme.textDim
                    font { family: Theme.fontFamily; pixelSize: 11 }
                }

                // Result text + copy button
                Item {
                    anchors { fill: parent; margins: 8 }
                    visible: tool.outputText.length > 0

                    Text {
                        id: outputText
                        anchors { left: parent.left; right: copyBtn.left; rightMargin: 6; top: parent.top }
                        text:     tool.outputText
                        color:    Theme.textPrimary
                        font { family: Theme.fontFamily; pixelSize: 13 }
                        wrapMode: Text.Wrap
                    }

                    // Copy button
                    Rectangle {
                        id: copyBtn
                        anchors { right: parent.right; top: parent.top }
                        width: 28; height: 22; radius: 4
                        color: copyHover.hovered
                            ? Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g, Theme.mutedblue.b, 0.25)
                            : Qt.rgba(1, 1, 1, 0.05)
                        border.color: Theme.borderIdle
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }

                        HoverHandler { id: copyHover }

                        Text {
                            anchors.centerIn: parent
                            text:  copied ? "\u2713" : "\u29C9"   // checkmark or copy icon
                            color: copied ? "#6ecf9e" : Theme.textDim
                            font { family: Theme.fontFamily; pixelSize: 11 }
                            property bool copied: false
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                Clipboard.setText(tool.outputText)
                                var t = parent.children[0]   // the Text
                                t.copied = true
                                copyResetTimer.restart()
                            }
                        }

                        Timer {
                            id: copyResetTimer
                            interval: 1500
                            onTriggered: copyBtn.children[0].copied = false
                        }
                    }
                }
            }
        }
    }
}
