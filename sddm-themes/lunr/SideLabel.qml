// =============================================================
// SideLabel.qml — Vertical "SYSTEM ACCESS" text, far-left edge
// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    width: 24
    height: 200

    Text {
        anchors.centerIn: parent
        text: "SYSTEM ACCESS"
        color: P.textDim
        font.family: P.fontFamily
        font.pixelSize: 10
        font.letterSpacing: 3
        opacity: 0.5

        transform: Rotation {
            origin.x: 0
            origin.y: 0
            angle: -90
        }
        x: 16
        y: 160
    }
}
