import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../../theme"

// WorkspacesModule — lives in bar/modules/left/
RowLayout {
    spacing: 0

    readonly property var wsLabels: ["一","二","三","四","五","六","七","八","九","十"]

    // ── OS icon ──────────────────────────────────────────────
    Text {
        id: osBtn
        text:  "󰣇"
        color: Theme.lilac
        font { family: Theme.fontFamily; pixelSize: 17 }
        leftPadding:  4
        rightPadding: 4

        HoverHandler { onHoveredChanged: osBtn.color = hovered ? Theme.accent : Theme.lilac }

        MouseArea {
            anchors.fill:    parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton)
                    Quickshell.execDetached(["xdg-terminal-exec"])
                else
                    Quickshell.execDetached(["menu"])
            }
        }

        Behavior on color { ColorAnimation { duration: 160 } }
    }

    // Divider
    Rectangle {
        width:  1
        height: parent.height * 0.6
        color:  Theme.borderIdle
        anchors.verticalCenter: parent.verticalCenter
    }

    // ── Workspace buttons — compact width ─────────────────────
    Repeater {
        model: 5

        delegate: Item {
            id: wsBtn
            property int  wsId:   index + 1
            property bool active: Hyprland.focusedWorkspace?.id === wsId
            property bool exists: Hyprland.workspaces.values.some(w => w.id === wsId)

            implicitWidth:  22
            implicitHeight: Theme.barHeight

            Text {
                anchors.centerIn: parent
                text: wsBtn.active ? "󱓻" : wsLabels[index]
                color: {
                    if (wsBtn.active) return Theme.violetBright
                    if (wsBtn.exists) return Qt.rgba(0.85, 0.82, 0.95, 1.0)
                    return Qt.rgba(Theme.violetMid.r, Theme.violetMid.g,
                                   Theme.violetMid.b, 0.50)
                }
                font { family: Theme.fontMono; pixelSize: 13 }
                Behavior on color { ColorAnimation { duration: 160 } }
            }

            // Underline — yellow, positioned inside the pill near the bottom
            Rectangle {
                anchors.bottom:           parent.bottom
                anchors.bottomMargin:     2
                anchors.horizontalCenter: parent.horizontalCenter
                width:  wsBtn.active ? 10 : 0
                height: 2
                color:  Theme.accent
                radius: 1
                Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + wsBtn.wsId)
            }
        }
    }
}
