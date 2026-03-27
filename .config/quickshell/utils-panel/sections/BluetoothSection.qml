import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

// BluetoothSection.qml — lives in utils-panel/sections/
// Polls bluetoothctl for state and connected device name.
Item {
    implicitWidth:  parent.width
    implicitHeight: row.implicitHeight

    property bool   btEnabled:  false
    property bool   btConnected: false
    property string btDevice:   ""

    Process {
        id: btProc
        command: ["bash", "-c", `
            power=$(bluetoothctl show | awk '/Powered:/{print $2}')
            device=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)
            echo "$power|$device"
        `]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                btEnabled   = (parts[0] === "yes")
                btDevice    = parts[1]?.trim() ?? ""
                btConnected = btDevice.length > 0
            }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: btProc.running = true
    }

    RowLayout {
        id: row
        anchors { left: parent.left; right: parent.right }
        spacing: 10

        Text {
            text:  btConnected ? "\uf294" : (btEnabled ? "\uf294" : "\uf294")
            color: btEnabled ? Theme.mutedblue : Theme.textDim
            font { family: Theme.fontFamily; pixelSize: 14 }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text:  btConnected ? btDevice
                       : (btEnabled ? "Bluetooth on" : "Bluetooth off")
                color: Theme.foreground
                font { family: Theme.fontFamily; pixelSize: 13 }
            }

            Text {
                visible: btConnected
                text:    "Connected"
                color:   Theme.textDim
                font { family: Theme.fontFamily; pixelSize: 11 }
            }
        }

        // Toggle
        Rectangle {
            width:  60; height: 22
            radius: 11
            color:  btEnabled ? Theme.glassViolet : Theme.violet
            border.color: btEnabled ? Theme.violetBright : Theme.borderIdle
            border.width: 1

            Text {
                anchors.centerIn: parent
                text:  btEnabled ? "On" : "Off"
                color: btEnabled ? Theme.accent : Theme.textDim
                font { family: Theme.fontFamily; pixelSize: 11 }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    const cmd = btEnabled ? "power off" : "power on"
                    Quickshell.execDetached(["bash", "-c",
                        "echo '" + cmd + "' | bluetoothctl"])
                    btEnabled = !btEnabled
                }
            }

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
}
