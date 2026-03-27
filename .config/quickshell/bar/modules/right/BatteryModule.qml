import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../theme"

// BatteryModule — lives in bar/modules/right/
Item {
    id: root
    implicitHeight: Theme.barHeight
    implicitWidth:  row.implicitWidth + 8

    property var  service: null
    property bool hovered: false

    readonly property color batFilled: "#a0cfdc"
    readonly property color batEmpty:  "#3c3f4a"

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        // Icon
        Text {
            text: {
                if (service?.plugged) return "󰂅"
                if (service?.charging) {
                    const icons = ["󰢜","󰂆","󰂇","󰂈","󰢝","󰂉","󰢞","󰂊","󰂋","󰂅"]
                    return icons[Math.min(Math.floor((service?.capacity ?? 100) / 10), 9)]
                }
                const icons = ["󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"]
                return icons[Math.min(Math.floor((service?.capacity ?? 100) / 10), 9)]
            }
            color: {
                if (service?.charging)                    return Theme.accent
                if ((service?.capacity ?? 100) <= 10)     return Theme.lilac
                if ((service?.capacity ?? 100) <= 35)     return Theme.textPrimary
                return Theme.mutedblue
            }
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        // Bar
        Item {
            implicitWidth:  52
            implicitHeight: 12

            Rectangle {
                anchors.fill: parent
                color:        batEmpty
                radius:       3
            }

            Rectangle {
                width:  Math.max(4, parent.width * (service?.capacity ?? 100) / 100)
                height: parent.height
                color:  batFilled
                radius: 3

                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 2
                    color:  Qt.rgba(1, 1, 1, 0.18)
                    radius: 3
                }

                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }

            Rectangle {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                anchors.rightMargin: -3
                width: 3; height: 6
                color:  batFilled
                radius: 1
            }
        }

        // Percentage
        Text {
            text:  (service?.capacity ?? 0) + "%"
            color: {
                if (service?.charging)                    return Theme.accent
                if ((service?.capacity ?? 100) <= 10)     return Theme.lilac
                if ((service?.capacity ?? 100) <= 35)     return Theme.textPrimary
                return Theme.mutedblue
            }
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["menu", "power"])
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
            text: ((service?.charging ?? false)
                    ? (service?.power ?? 0).toFixed(0) + "W↑"
                    : (service?.power ?? 0).toFixed(0) + "W↓")
                  + "  " + (service?.capacity ?? 0) + "%"
            color: Theme.foreground
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
        }
    }
}
