import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./sections"
import "../theme"

// UtilsPanel.qml — lives in utils-panel/
PanelWindow {
    id: panel

    property var networkService: null

    anchors.top:   true
    anchors.right: true
    exclusiveZone: 0

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    visible:        PanelState.open
    implicitWidth:  320
    implicitHeight: contentCol.implicitHeight + 28

    color: "transparent"

    HoverHandler {
        onHoveredChanged: {
            PanelState.panelHovered = hovered
            if (!hovered)
                panelCollapseTimer.restart()
            else
                panelCollapseTimer.stop()
        }
    }

    Timer {
        id: panelCollapseTimer
        interval: 300
        onTriggered: PanelState.open = false
    }

    // Background — same approach as TrayPopup, no canvas needed
    Rectangle {
        anchors.fill: parent
        color:        "#2E3440"
        border.color: Theme.borderIdle
        border.width: 1
        radius:       8

        // Violet top accent
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 2
            color:  Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                           Theme.violetBright.b, 0.60)
            radius: 8
        }

        // Notch triangle pointing up toward gear
        Canvas {
            id: notch
            width:  20
            height: 10
            anchors.right:  parent.right
            anchors.rightMargin: 18
            anchors.bottom: parent.top
            anchors.bottomMargin: -1

            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.beginPath()
                ctx.moveTo(width / 2, 0)
                ctx.lineTo(width, height)
                ctx.lineTo(0, height)
                ctx.closePath()
                ctx.fillStyle = "#2E3440"
                ctx.fill()
                ctx.strokeStyle = Qt.rgba(
                    Theme.borderIdle.r, Theme.borderIdle.g,
                    Theme.borderIdle.b, Theme.borderIdle.a)
                ctx.lineWidth = 1
                // Only stroke top two edges of triangle (not the bottom)
                ctx.beginPath()
                ctx.moveTo(0, height)
                ctx.lineTo(width / 2, 0)
                ctx.lineTo(width, height)
                ctx.stroke()
            }
        }
    }

    ColumnLayout {
        id: contentCol
        anchors {
            top:         parent.top
            left:        parent.left
            right:       parent.right
            topMargin:   14
            leftMargin:  16
            rightMargin: 16
        }
        spacing: 16

        component Divider: Rectangle {
            Layout.fillWidth: true
            height:  1
            color:   Theme.borderIdle
            opacity: 0.5
        }

        VolumeSection     {}
        Divider           {}
        BrightnessSection {}
        Divider           {}
        NetworkSection    { service: panel.networkService }
        Divider           {}
        BluetoothSection  {}

        Item { implicitHeight: 4 }
    }
}
