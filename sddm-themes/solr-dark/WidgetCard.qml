// =============================================================
// WidgetCard.qml — Reusable status widget card
// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    id: root
    height: cardBody.implicitHeight + 2

    property string labelText: "WIDGET"
    property Item   content:   null

    onContentChanged: {
        if (content) {
            content.parent = contentSlot
            content.anchors.left  = contentSlot.left
            content.anchors.right = contentSlot.right
        }
    }

    Rectangle {
        id: cardBody
        anchors.fill: parent
        radius: 10
        color: P.glass
        border.color: P.border1
        border.width: 1
        implicitHeight: innerCol.implicitHeight + 40

        Column {
            id: innerCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 26
            spacing: 16

            // Widget label header
            Row {
                spacing: 10

                Rectangle {
                    width: 4; height: 22
                    radius: 2
                    color: P.accent
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: root.labelText
                    color: P.textDim
                    font.family: P.fontFamily
                    font.pixelSize: 20
                    font.letterSpacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Content slot
            Item {
                id: contentSlot
                anchors.left: parent.left
                anchors.right: parent.right
                height: childrenRect.height
            }
        }
    }
}
