import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "./tray"
import "../../../theme"

// TrayModule — lives in bar/modules/right/
Item {
    id: root
    implicitHeight: Theme.barHeight
    implicitWidth:  row.implicitWidth

    // Shared open state — both chip and popup read/write this
    property bool trayOpen:        false
    property bool chipHovered:     false
    property bool popupHovered:    false

    // Only close when BOTH chip and popup are not hovered
    function maybeClose() {
        if (!chipHovered && !popupHovered)
            trayOpen = false
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Text {
            text:  "\uf0d7"
            color: root.trayOpen ? Theme.violetBright : Theme.violetMid
            font { family: Theme.fontFamily; pixelSize: 10 }
            Layout.alignment: Qt.AlignVCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        // System tray icons
        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property SystemTrayItem modelData
                visible:          !modelData.id.toLowerCase().includes("fcitx")
                implicitWidth:    visible ? 16 : 0
                implicitHeight:   16
                Layout.alignment: Qt.AlignVCenter

                Image {
                    id: iconImg
                    anchors.fill: parent
                    source:       Quickshell.iconPath(modelData.icon, "")
                    fillMode:     Image.PreserveAspectFit
                    smooth:       true
                    visible:      status === Image.Ready
                    opacity:      modelData.status === SystemTrayItem.NeedsAttention ? 1.0 : 0.80
                }

                Image {
                    anchors.fill: parent
                    source:       iconImg.status !== Image.Ready
                                  ? "image://icon/" + modelData.icon : ""
                    fillMode:     Image.PreserveAspectFit
                    smooth:       true
                    visible:      iconImg.status !== Image.Ready && status === Image.Ready
                    opacity:      modelData.status === SystemTrayItem.NeedsAttention ? 1.0 : 0.80
                }

                MouseArea {
                    anchors.fill:    parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton && modelData.hasMenu)
                            modelData.display()
                        else
                            modelData.activate()
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            root.chipHovered = hovered
            if (hovered) {
                collapseTimer.stop()
                root.trayOpen = true
            } else {
                collapseTimer.restart()
            }
        }
    }

    Timer {
        id: collapseTimer
        interval: 350
        onTriggered: root.maybeClose()
    }

    TrayPopup {
        id: trayPopup
        chipItem:      root
        trayOpen:      root.trayOpen
        onPopupHoveredChanged: {
            root.popupHovered = popupHovered
            if (!popupHovered)
                collapseTimer.restart()
            else
                collapseTimer.stop()
        }
    }
}
