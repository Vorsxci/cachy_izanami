// =============================================================
// ClockPanel.qml — Center: large clock, date, system name
// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    id: root
    width: 900
    height: col.implicitHeight

    property string timeStr: Qt.formatTime(new Date(), "hh:mm")
    property string dateStr: Qt.formatDate(new Date(), "yyyy.MM.dd")

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root.timeStr = Qt.formatTime(new Date(), "hh:mm")
            root.dateStr = Qt.formatDate(new Date(), "yyyy.MM.dd")
        }
    }

    Column {
        id: col
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8



        Item { height: 12; width: 1 }

        // Clock
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.timeStr
            color: P.textPrimary
            font.family: P.fontFamily
            font.pixelSize: 192
            font.weight: Font.Light
            font.letterSpacing: 16
        }

        // Date
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.dateStr
            color: P.textDim
            font.family: P.fontFamily
            font.pixelSize: 36
            font.letterSpacing: 12
        }

        Item { height: 28; width: 1 }

        // System name
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "[ Cachy-Os: 一輝 ]"
            color: P.textPrimary
            font.family: P.fontFamily
            font.pixelSize: 48
            font.letterSpacing: 16
        }

        // Subtitle
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "S O L R   O p e r a t i n g   S y s t e m"
            color: P.textDim
            font.family: P.fontFamily
            font.pixelSize: 26
            font.letterSpacing: 6
        }

        Item { height: 40; width: 1 }

        // Animated moon with orbiting star rings
        SunOrbit {
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
