import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"

// NetworkSection.qml — lives in utils-panel/sections/
// Receives network data via the 'service' property from UtilsPanel
Item {
    implicitWidth:  parent.width
    implicitHeight: row.implicitHeight

    property var service: null

    property string wifiIcon: {
        if (!service?.connected) return "󰤮"
        if (service?.ethernet)   return "󰀂"
        if (service?.signal >= 80) return "󰤨"
        if (service?.signal >= 60) return "󰤥"
        if (service?.signal >= 40) return "󰤢"
        if (service?.signal >= 20) return "󰤟"
        return "󰤯"
    }

    RowLayout {
        id: row
        anchors { left: parent.left; right: parent.right }
        spacing: 10

        Text {
            text:  wifiIcon
            color: (service?.connected ?? false) ? Theme.mutedblue : Theme.textDim
            font { family: Theme.fontFamily; pixelSize: 14 }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: (service?.connected ?? false)
                      ? ((service?.ethernet ?? false) ? "Ethernet" : (service?.ssid ?? ""))
                      : "Not connected"
                color: Theme.foreground
                font { family: Theme.fontFamily; pixelSize: 13 }
            }

            Text {
                visible: service?.connected ?? false
                text:    "⇣ " + (service?.downSpeed ?? "") + "  ⇡ " + (service?.upSpeed ?? "")
                color:   Theme.textDim
                font { family: Theme.fontFamily; pixelSize: 11 }
            }
        }

        Rectangle {
            width:  60; height: 22
            radius: 11
            color:  (service?.connected ?? false) ? Theme.glassViolet : Theme.violet
            border.color: (service?.connected ?? false) ? Theme.violetBright : Theme.borderIdle
            border.width: 1

            Text {
                anchors.centerIn: parent
                text:  (service?.connected ?? false) ? "On" : "Off"
                color: (service?.connected ?? false) ? Theme.accent : Theme.textDim
                font { family: Theme.fontFamily; pixelSize: 11 }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Quickshell.execDetached(["launch-wifi"])
            }

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
}
