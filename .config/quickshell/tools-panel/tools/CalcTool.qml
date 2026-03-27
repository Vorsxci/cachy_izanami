import QtQuick
import Quickshell.Io
import "../../theme"

// CalcTool.qml
// Scientific calculator. Expressions are evaluated by passing them to
// `bc -l` (supports sin, cos, tan, log, sqrt, ^ etc.) via a Process.
// Results are shown in a scrollable history tape.

Item {
    id: tool

    readonly property string toolLabel:   "="
    readonly property color  toolColor:   Theme.accent
    readonly property string toolTooltip: "Calculator"

    property bool toolActive: false
    property int  toolIndex:  -1

    // --- State ---------------------------------------------------------------
    property string expression: ""
    property var    history:    []   // [{expr, result}]
    property string errorMsg:   ""

    onToolActiveChanged: {
        if (toolActive) focusTimer.restart()
    }

    Timer { id: focusTimer; interval: 80; onTriggered: exprInput.forceActiveFocus() }

    Process {
        id: calcProc
        running: false
        command: []
        property string pendingExpr: ""
        onRunningChanged: {
            if (!running) resultFile.reload()
        }
    }

    FileView {
        id: resultFile
        path: "/tmp/calc_result.txt"
        onTextChanged: {
            var raw = resultFile.text().trim()
            if (!raw || raw.length === 0) return
            tool.pushResult(calcProc.pendingExpr, raw)
        }
    }

    // Translate display expression to bc-compatible form
    function toBcExpr(expr) {
        return expr
            .replace(/\u00F7/g, "/")    // division sign
            .replace(/\u00D7/g, "*")    // multiplication sign
            .replace(/\u221A\(/g, "sqrt(")
            .replace(/\u03C0/g, "4*a(1)")           // pi = 4*atan(1) in bc
            .replace(/\be\b/g, "e(1)")              // e
            .replace(/sin\(/g, "s(")
            .replace(/cos\(/g, "c(")
            .replace(/tan\(/g, "s($1)/c(")          // tan via sin/cos
            .replace(/ln\(/g,  "l(")
            .replace(/log\(/g, "l(/l(10)*")         // log10 via ln
            .replace(/\^/g,    "^")
    }

    function evaluate(expr) {
        var e = expr.trim()
        if (e.length === 0) return
        tool.errorMsg = ""
        var bcExpr = tool.toBcExpr(e)
        calcProc.pendingExpr = e
        calcProc.command = [
            "bash", "-c",
            "echo 'scale=10; " + bcExpr.replace(/'/g, "'\\''") + "' | bc -l 2>&1 | head -1 > /tmp/calc_result.txt"
        ]
        calcProc.running = true
    }

    function pushResult(expr, raw) {
        if (raw.indexOf("error") !== -1 || raw.indexOf("(standard_in)") !== -1 || raw.indexOf("illegal") !== -1) {
            tool.errorMsg = "Error"
            return
        }
        // Trim trailing zeros after decimal
        var num = parseFloat(raw)
        var display = isNaN(num) ? raw : (Number.isInteger(num) ? num.toString() : parseFloat(num.toFixed(8)).toString())
        var updated = tool.history.slice()
        updated.push({ expr: expr, result: display })
        tool.history = updated
        // Put result back into input for chaining
        exprInput.text = display
    }

    function clear() {
        exprInput.text  = ""
        tool.expression = ""
        tool.errorMsg   = ""
    }

    function clearHistory() {
        tool.history  = []
        tool.errorMsg = ""
    }

    function appendToExpr(s) {
        exprInput.text = exprInput.text + s
        exprInput.cursorPosition = exprInput.text.length
    }

    // --- UI ------------------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color:        Theme.glassDeep
        radius:       8
        border.color: Theme.borderIdle
        border.width: 1

        Rectangle {
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
            width: 2; radius: 8
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.6)
        }

        Item {
            anchors {
                left:   parent.left;   leftMargin:   14
                right:  parent.right;  rightMargin:  12
                top:    parent.top;    topMargin:    10
                bottom: parent.bottom; bottomMargin: 10
            }

            // Header
            Row {
                id: header
                anchors { left: parent.left; right: parent.right; top: parent.top }
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:  "Calculator"
                    color: Theme.accent
                    font { family: Theme.fontFamily; pixelSize: 15; weight: Font.Medium }
                }

                // Clear history button
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text:  "clear"
                    color: clearHov.hovered ? Theme.textPrimary : Theme.textDim
                    font { family: Theme.fontFamily; pixelSize: 10 }
                    Behavior on color { ColorAnimation { duration: 100 } }
                    HoverHandler { id: clearHov }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    tool.clearHistory()
                    }
                }
            }

            // History tape
            ListView {
                id: historyList
                anchors { left: parent.left; right: parent.right; top: header.bottom; topMargin: 6; bottom: inputRow.top; bottomMargin: 6 }
                model:   tool.history
                spacing: 2
                clip:    true
                verticalLayoutDirection: ListView.BottomToTop

                delegate: Item {
                    width:  historyList.width
                    height: historyRow.implicitHeight + 4

                    Row {
                        id: historyRow
                        anchors { left: parent.left; right: parent.right }
                        spacing: 6

                        Text {
                            text:  modelData.expr
                            color: Theme.textDim
                            font { family: Theme.fontMono; pixelSize: 11 }
                            elide: Text.ElideLeft
                            width: parent.width * 0.55
                        }
                        Text {
                            text:  "="
                            color: Theme.textDim
                            font { family: Theme.fontMono; pixelSize: 11 }
                        }
                        Text {
                            text:  modelData.result
                            color: Theme.textPrimary
                            font { family: Theme.fontMono; pixelSize: 11; weight: Font.Medium }
                            // Tap to reuse result
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    exprInput.text = modelData.result
                                    exprInput.cursorPosition = exprInput.text.length
                                }
                            }
                        }
                    }
                }
            }

            // Error
            Text {
                anchors { horizontalCenter: parent.horizontalCenter; bottom: inputRow.top; bottomMargin: 2 }
                visible: tool.errorMsg.length > 0
                text:    tool.errorMsg
                color:   "#e06c75"
                font { family: Theme.fontFamily; pixelSize: 11 }
            }

            // Input row
            Item {
                id: inputRow
                anchors { left: parent.left; right: parent.right; bottom: sciRow.top; bottomMargin: 6 }
                height: 32

                Rectangle {
                    anchors.fill: parent
                    radius: 5
                    color:  Qt.rgba(1, 1, 1, 0.05)
                    border.color: exprInput.activeFocus
                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.70)
                        : Theme.borderIdle
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Row {
                        anchors {
                            left: parent.left; leftMargin: 8
                            right: parent.right; rightMargin: 4
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 4

                        TextInput {
                            id: exprInput
                            width: parent.width - eqBtn.width - 8
                            anchors.verticalCenter: parent.verticalCenter
                            color:          Theme.textPrimary
                            selectionColor: Theme.accent
                            font { family: Theme.fontMono; pixelSize: 14 }
                            clip: true

                            Text {
                                visible: exprInput.text.length === 0 && !exprInput.activeFocus
                                anchors.fill: parent
                                text:  "expression..."
                                color: Theme.textDim
                                font:  exprInput.font
                                verticalAlignment: Text.AlignVCenter
                            }

                            onTextChanged: tool.expression = text
                            Keys.onReturnPressed:  tool.evaluate(text)
                            Keys.onEscapePressed:  tool.clear()
                        }

                        // = button
                        Rectangle {
                            id: eqBtn
                            anchors.verticalCenter: parent.verticalCenter
                            width: 28; height: 24; radius: 4
                            color: eqHov.hovered
                                ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.30)
                                : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12)
                            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.40)
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 100 } }
                            HoverHandler { id: eqHov }
                            Text {
                                anchors.centerIn: parent
                                text:  "="
                                color: Theme.accent
                                font { family: Theme.fontFamily; pixelSize: 13; weight: Font.Medium }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    tool.evaluate(exprInput.text)
                            }
                        }
                    }
                }
            }

            // Scientific function buttons
            Column {
                id: sciRow
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                spacing: 4

                // Row 1: trig
                Row {
                    spacing: 4
                    Repeater {
                        model: ["sin(", "cos(", "tan(", "ln(", "log("]
                        delegate: CalcBtn {
                            label:  modelData
                            accent: Theme.accent
                            onTap:  tool.appendToExpr(modelData)
                        }
                    }
                }

                // Row 2: misc
                Row {
                    spacing: 4
                    Repeater {
                        model: ["\u221A(", "^", "(", ")", "\u03C0"]
                        delegate: CalcBtn {
                            label:  modelData
                            accent: Theme.accent
                            onTap:  tool.appendToExpr(modelData)
                        }
                    }
                }
            }
        }
    }

    // Inline sub-component for scientific buttons
    component CalcBtn: Rectangle {
        property string label:  ""
        property color  accent: Theme.accent
        signal tap()

        width:  (parent.width - 4 * 4) / 5
        height: 26
        radius: 4
        color: btnHov.hovered
            ? Qt.rgba(accent.r, accent.g, accent.b, 0.20)
            : Qt.rgba(1, 1, 1, 0.05)
        border.color: Qt.rgba(accent.r, accent.g, accent.b, 0.30)
        border.width: 1
        Behavior on color { ColorAnimation { duration: 100 } }

        HoverHandler { id: btnHov }

        Text {
            anchors.centerIn: parent
            text:  label
            color: btnHov.hovered ? Theme.textPrimary : Theme.textDim
            font { family: Theme.fontMono; pixelSize: 11 }
            Behavior on color { ColorAnimation { duration: 100 } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    tap()
        }
    }
}
