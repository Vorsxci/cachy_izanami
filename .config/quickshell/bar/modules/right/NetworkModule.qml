import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../theme"

// NetworkModule — lives in bar/modules/right/
Item {
    id: root
    implicitHeight: Theme.barHeight
    implicitWidth:  row.implicitWidth

    property var  service: null
    property bool hovered: false

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
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Text {
            text:  wifiIcon
            color: (service?.connected ?? false) ? Theme.mutedblue : Theme.lilac
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        Text {
            visible: (service?.connected ?? false) && !(service?.ethernet ?? false)
                     && (service?.downSpeed ?? "") !== ""
            text:    "⇣" + (service?.downSpeed ?? "")
            color:   Theme.mutedblue
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["launch-wifi"])
    }

    HoverHandler { onHoveredChanged: root.hovered = hovered }

    Rectangle {
        visible:      root.hovered
        anchors.top:  parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color:        Theme.glassDeep
        border.color: Theme.borderIdle
        border.width: 1
        radius:       6
        implicitWidth:  tipText.implicitWidth  + 24
        implicitHeight: tipText.implicitHeight + 16

        Text {
            id: tipText
            anchors.centerIn: parent
            text: (service?.connected ?? false)
                ? ((service?.ethernet ?? false)
                    ? "Ethernet\n⇣" + (service?.downSpeed ?? "") + "  ⇡" + (service?.upSpeed ?? "")
                    : (service?.ssid ?? "") + " (" + (service?.signal ?? 0) + "%)\n⇣"
                      + (service?.downSpeed ?? "") + "  ⇡" + (service?.upSpeed ?? ""))
                : "Disconnected"
            color: Theme.foreground
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
        }
    }
}
