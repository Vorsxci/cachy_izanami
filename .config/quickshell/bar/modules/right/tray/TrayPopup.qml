import QtQuick
import QtQuick.Layouts
import Quickshell
import "./"
import "../../../theme"

// TrayPopup.qml — lives in bar/modules/right/tray/
PopupWindow {
    id: popup

    property Item chipItem:     null
    property bool trayOpen:     false
    property bool popupHovered: false

    anchor.item:    chipItem
    anchor.edges:   Edges.Bottom
    anchor.gravity: Edges.Bottom | Edges.Left

    visible: chipItem !== null && trayOpen

    color: "transparent"

    implicitWidth:  contentCol.implicitWidth  + 24
    implicitHeight: contentCol.implicitHeight + 20

    HoverHandler {
        onHoveredChanged: popup.popupHovered = hovered
    }

    // Nord #2E3440 background
    Rectangle {
        anchors.fill: parent
        color:        "#2E3440"
        border.color: Theme.borderIdle
        border.width: 1
        radius:       8

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 2
            color:  Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                           Theme.violetBright.b, 0.60)
            radius: 8
        }
    }

    ColumnLayout {
        id: contentCol
        anchors { fill: parent; margins: 12 }
        spacing: 10

        BluetoothItem {}

        Rectangle {
            Layout.fillWidth: true
            height:  1
            color:   Theme.borderIdle
            opacity: 0.5
        }

        InputMethodItem {}
    }
}
