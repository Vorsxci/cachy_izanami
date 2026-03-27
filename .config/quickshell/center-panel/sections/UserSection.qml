import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

// UserSection.qml — lives in center-panel/sections/
Item {
    implicitWidth:  parent.width
    implicitHeight: row.implicitHeight

    property string hostname: ""
    property string uptime:   ""
    property string distro:   "CachyOS"
    property string kernel:   ""

    Process {
        id: infoProc
        command: ["bash", "-c", `
            echo "hostname:$(hostname)"
            echo "uptime:$(uptime -p | sed 's/up //')"
            echo "kernel:$(uname -r)"
        `]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    const [k, ...rest] = line.split(":")
                    const v = rest.join(":")
                    if (k === "hostname") hostname = v
                    if (k === "uptime")   uptime   = v
                    if (k === "kernel")   kernel   = v
                }
            }
        }
    }

    // Refresh uptime every minute
    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: infoProc.running = true
    }

    RowLayout {
        id: row
        anchors { left: parent.left; right: parent.right }
        spacing: 16

        // Arch logo
        Text {
            text:  "󰣇"
            color: Theme.accent
            font { family: Theme.fontFamily; pixelSize: 36 }
            Layout.alignment: Qt.AlignVCenter
        }

        // Info column
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text:  hostname
                color: Theme.textPrimary
                font { family: Theme.fontFamily; pixelSize: 16; weight: Font.Medium }
            }

            RowLayout {
                spacing: 16
                Text {
                    text:  "󰣇 " + distro
                    color: Theme.foreground
                    font { family: Theme.fontFamily; pixelSize: 12 }
                }
                Text {
                    text:  " " + uptime
                    color: Theme.textDim
                    font { family: Theme.fontFamily; pixelSize: 12 }
                }
            }

            Text {
                text:  "󰌽 " + kernel
                color: Theme.textDim
                font { family: Theme.fontFamily; pixelSize: 11 }
            }
        }
    }
}
