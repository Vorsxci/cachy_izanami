// =============================================================
// StatusPanel.qml — Top-right info widgets
// Battery bar, now-playing, weather — all via shell scripts
// =============================================================

import QtQuick 2.15
import QtQuick.Layouts 1.15
import "palette.js" as P

Item {
    id: root
    height: col.implicitHeight

    property string weatherText:    "· · ·"
    property string nowPlayingText: "· · ·"
    property string batteryText:    "· · ·"
    property real   batteryLevel:   1.0

    Timer {
        interval: 300000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: weatherProc.run()
    }
    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: nowPlayingProc.run()
    }
    Timer {
        interval: 30000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: batteryProc.run()
    }

    ScriptProcess {
        id: weatherProc
        script: P.scriptWeather
        onResult: (output) => root.weatherText = output.trim()
    }
    ScriptProcess {
        id: nowPlayingProc
        script: P.scriptNowPlaying
        onResult: (output) => root.nowPlayingText = output.trim()
    }
    ScriptProcess {
        id: batteryProc
        script: P.scriptBattery
        onResult: (output) => {
            var raw = output.trim().replace("%", "")
            var val = parseFloat(raw)
            if (!isNaN(val)) {
                root.batteryLevel = Math.max(0, Math.min(val / 100.0, 1.0))
                root.batteryText  = Math.round(val) + "%"
            } else {
                root.batteryText = output.trim()
            }
        }
    }

    Column {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 24

        // ── Now playing ───────────────────────────────────────
        WidgetCard {
            width: parent.width
            labelText: "NOW PLAYING"
            content: Row {
                spacing: 18
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    text: "♪"
                    color: P.accent
                    font.pixelSize: 32
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    width: parent.width - 50
                    text: root.nowPlayingText !== "" ? root.nowPlayingText : "Nothing playing"
                    color: root.nowPlayingText !== "" ? P.textPrimary : P.textDim
                    font.family: P.fontFamily
                    font.pixelSize: 26
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ── Weather ───────────────────────────────────────────
        WidgetCard {
            width: parent.width
            labelText: "WEATHER"
            content: Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: root.weatherText !== "" ? root.weatherText : "Fetching…"
                color: P.textPrimary
                font.family: P.fontFamily
                font.pixelSize: 26
                wrapMode: Text.WordWrap
            }
        }

        // ── Battery ───────────────────────────────────────────
        WidgetCard {
            width: parent.width
            labelText: "POWER"
            content: Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 14

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Text {
                        text: "⚡"
                        color: root.batteryLevel > 0.2 ? P.accent : P.errorColor
                        font.pixelSize: 28
                    }
                    Text {
                        anchors.right: parent.right
                        text: root.batteryText
                        color: P.textPrimary
                        font.family: P.fontFamily
                        font.pixelSize: 26
                    }
                }

                // Battery bar track
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 14
                    radius: 7
                    color: P.fieldBg

                    Rectangle {
                        width: parent.width * root.batteryLevel
                        height: parent.height
                        radius: 7
                        color: root.batteryLevel > 0.2 ? P.barFill : P.errorColor
                        Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                }
            }
        }
    }
}
