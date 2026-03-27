import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

// BrightnessSection.qml — lives in utils-panel/sections/
Item {
    implicitWidth:  parent.width
    implicitHeight: col.implicitHeight

    property int current: 100
    property int maximum: 100
    property int pct:     maximum > 0 ? Math.round(current / maximum * 100) : 0

    // Read current brightness on load
    Process {
        id: readProc
        command: ["brightnessctl", "-m", "get"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: current = parseInt(text.trim()) || 100
        }
    }

    // Read max once
    Process {
        id: readMax
        command: ["brightnessctl", "-m", "max"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: maximum = parseInt(text.trim()) || 100
        }
    }

    // Debounce writes — only fire brightnessctl after user stops dragging
    Timer {
        id: writeTimer
        interval: 80
        onTriggered: {
            const val = Math.round(maximum * pct / 100)
            Quickshell.execDetached(["brightnessctl", "set", val + ""])
        }
    }

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right }
        spacing: 8

        // ── Header row ────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            Text {
                text:  pct >= 66 ? "\uf005" : (pct >= 33 ? "\uf123" : "\uf006")
                color: Theme.accent
                font { family: Theme.fontFamily; pixelSize: 14 }
            }

            Text {
                text:  "Brightness"
                color: Theme.foreground
                font { family: Theme.fontFamily; pixelSize: 13 }
                Layout.fillWidth: true
                leftPadding: 6
            }

            Text {
                text:  pct + "%"
                color: Theme.textDim
                font { family: Theme.fontFamily; pixelSize: 12 }
                Layout.minimumWidth: 36
                horizontalAlignment: Text.AlignRight
            }
        }

        // ── Slider ────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            implicitHeight: 20

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width:  parent.width
                height: 4
                radius: 2
                color:  Theme.glassViolet
                border.color: Theme.borderIdle
                border.width: 1

                Rectangle {
                    width:  Math.max(8, parent.width * (pct / 100))
                    height: parent.height
                    radius: 2
                    color:  Theme.accent
                    Behavior on width { NumberAnimation { duration: 80 } }
                }
            }

            Rectangle {
                x:      Math.max(0, Math.min(parent.width - width,
                        parent.width * (pct / 100) - width / 2))
                anchors.verticalCenter: parent.verticalCenter
                width:  14; height: 14
                radius: 7
                color:  Theme.glassDeep
                border.color: Theme.accent
                border.width: 2
                Behavior on x { NumberAnimation { duration: 80 } }
            }

            MouseArea {
                anchors.fill: parent
                onPressed:       mouse => updateBrightness(mouse.x)
                onMouseXChanged: mouse => { if (pressed) updateBrightness(mouse.x) }

                function updateBrightness(x) {
                    pct = Math.max(1, Math.min(100, Math.round(x / width * 100)))
                    current = Math.round(maximum * pct / 100)
                    writeTimer.restart()
                }
            }
        }
    }
}
