import QtQuick
import "../theme"

// ToolBubble.qml - one icon button in the ToolsPanel bar

Item {
    id: bubble

    property string label:       ""
    property color  accentColor: Theme.violetBright
    property int    size:        32
    property bool   active:      false

    signal clicked()

    width:  size
    height: size

    HoverHandler { id: hov }

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: bubble.active
            ? Qt.rgba(bubble.accentColor.r, bubble.accentColor.g, bubble.accentColor.b, 0.35)
            : hov.hovered
                ? Qt.rgba(bubble.accentColor.r, bubble.accentColor.g, bubble.accentColor.b, 0.25)
                : Qt.rgba(bubble.accentColor.r, bubble.accentColor.g, bubble.accentColor.b, 0.12)
        border.color: bubble.active
            ? Qt.rgba(bubble.accentColor.r, bubble.accentColor.g, bubble.accentColor.b, 0.75)
            : Qt.rgba(bubble.accentColor.r, bubble.accentColor.g, bubble.accentColor.b, 0.40)
        border.width: 1
        Behavior on color        { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text:  bubble.label
            color: bubble.active
                ? Qt.rgba(bubble.accentColor.r, bubble.accentColor.g, bubble.accentColor.b, 1.0)
                : hov.hovered ? Theme.textPrimary : Theme.textDim
            font { family: Theme.fontFamily; pixelSize: 14; weight: Font.Medium }
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    bubble.clicked()
        }
    }
}
