import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../theme"

// CpuMemModule — lives in bar/modules/right/
RowLayout {
    spacing: 8

    property var service: null

    Text {
        text:  "󰍛 " + (service?.cpuPct ?? 0) + "%"
        color: (service?.cpuCritical ?? false) ? Theme.lilac
             : (service?.cpuWarning  ?? false) ? Theme.textPrimary
             :                                   Theme.foreground
        font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
        Behavior on color { ColorAnimation { duration: 300 } }

        MouseArea {
            anchors.fill: parent
            onClicked: Quickshell.execDetached(["launch-or-focus-tui", "btop"])
        }
    }

    Text {
        text:  "\uefc5 " + (service?.memPct ?? 0) + "%"
        color: (service?.memCritical ?? false) ? Theme.lilac
             : (service?.memWarning  ?? false) ? Theme.textPrimary
             :                                   Theme.foreground
        font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
        Behavior on color { ColorAnimation { duration: 300 } }

        MouseArea {
            anchors.fill: parent
            onClicked: Quickshell.execDetached(["launch-or-focus-tui", "btop"])
        }
    }
}
