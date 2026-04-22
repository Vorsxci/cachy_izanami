// =============================================================
// DotBorder.qml — Top/bottom dotted border strip
// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    id: root
    height: 16
    property bool flipped: false

    Row {
        anchors.centerIn: parent
        spacing: 6
        Repeater {
            model: 160
            Rectangle {
                width: 4; height: 4; radius: 2
                color: P.textDim
                opacity: 0.35
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
