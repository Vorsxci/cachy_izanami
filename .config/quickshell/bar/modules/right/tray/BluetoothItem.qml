import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../../theme"

// BluetoothItem.qml — lives in bar/modules/right/tray/
RowLayout {
    spacing: 8

    property bool   btEnabled:   false
    property bool   btConnected: false
    property string btDevice:    ""

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
                const parts  = text.trim().split("|")
                btEnabled    = (parts[0] === "yes")
                btDevice     = parts[1]?.trim() ?? ""
                btConnected  = btDevice.length > 0
            }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: btProc.running = true
    }

    // Icon
    Text {
        text:  "\uf294"   // bluetooth glyph
        color: btEnabled ? Theme.mutedblue : Theme.textDim
        font { family: Theme.fontFamily; pixelSize: 13 }
        Layout.alignment: Qt.AlignVCenter
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    // Label — device name or status
    Text {
        text:  btConnected ? btDevice
             : btEnabled   ? "Bluetooth on"
             :               "Bluetooth off"
        color: Theme.foreground
        font { family: Theme.fontFamily; pixelSize: 12 }
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        elide: Text.ElideRight
    }

    // Toggle
    Rectangle {
        width: 36; height: 18
        radius: 9
        color:  btEnabled ? Theme.glassViolet : Theme.violet
        border.color: btEnabled ? Theme.violetBright : Theme.borderIdle
        border.width: 1
        Layout.alignment: Qt.AlignVCenter

        Text {
            anchors.centerIn: parent
            text:  btEnabled ? "On" : "Off"
            color: btEnabled ? Theme.accent : Theme.textDim
            font { family: Theme.fontFamily; pixelSize: 10 }
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
