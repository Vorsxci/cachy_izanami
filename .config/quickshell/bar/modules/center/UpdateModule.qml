import QtQuick
import Quickshell
import Quickshell.Io
import "../../../theme"

// UpdateModule — shows  when updates are available
// Lives in bar/modules/center/
Item {
    implicitWidth:  hasUpdates ? 24 : 0
    implicitHeight: Theme.barHeight
    visible:        hasUpdates

    property bool hasUpdates: false
    property bool hovered:    false

    Process {
        id: updateProc
        command: ["bash", "-lc", "update-available"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: hasUpdates = text.trim().length > 0
        }
    }

    Timer {
        interval: 3600000; running: true; repeat: true
        onTriggered: updateProc.running = true
    }

    Text {
        anchors.centerIn: parent
        text:  ""
        color: Theme.accent
        font { family: Theme.fontFamily; pixelSize: 10 }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached([
            "launch-floating-terminal-with-presentation", "update-pkgs"
        ])
    }

    HoverHandler { onHoveredChanged: hovered = hovered }

    Rectangle {
        visible:      hovered
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
            text:  "O"
            color: Theme.foreground
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
        }
    }

    Behavior on implicitWidth { NumberAnimation { duration: 200 } }
}
