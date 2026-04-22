// =============================================================
// ActionButton.qml — Reusable action button with hover glow
// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    id: root
    height: 80

    property string label: "Action"
    signal activated()

    // Outer glow
    Rectangle {
        anchors.fill: inner
        anchors.margins: -6
        radius: inner.radius + 6
        color: "transparent"
        border.color: hoverArea.containsMouse ? P.accentGlow : "transparent"
        border.width: 4
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    Rectangle {
        id: inner
        anchors.fill: parent
        radius: 8
        color: hoverArea.containsMouse
             ? (hoverArea.pressed ? P.selectedBg : P.hoverBg)
             : P.glass
        border.color: hoverArea.containsMouse ? P.hoverBorder : P.border1
        border.width: 1

        Behavior on color        { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        // ◆ diamond glyph
        Text {
            id: diamond
            anchors.left: parent.left
            anchors.leftMargin: 28
            anchors.verticalCenter: parent.verticalCenter
            text: "◆"
            color: hoverArea.containsMouse ? P.accent : P.textDim
            font.pixelSize: 20
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        // Label
        Text {
            anchors.left: diamond.right
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: hoverArea.containsMouse ? P.textPrimary : P.textDim
            font.family: P.fontFamily
            font.pixelSize: 26
            font.weight: hoverArea.containsMouse ? Font.Medium : Font.Normal
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        // Right-edge accent bar on hover
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: hoverArea.containsMouse ? 5 : 0
            radius: 3
            color: P.accent
            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.activated()
    }
}
