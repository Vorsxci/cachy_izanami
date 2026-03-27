import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../../theme"

// VolumeSection.qml — lives in utils-panel/sections/
Item {
    implicitWidth:  parent.width
    implicitHeight: col.implicitHeight

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property PwNode sink:   Pipewire.defaultAudioSink
    property bool   muted:  sink?.audio?.muted  ?? false
    property real   volume: sink?.audio?.volume ?? 0.0
    property int    volPct: Math.round(volume * 100)

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right }
        spacing: 8

        // ── Header row ────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            Text {
                text:  muted ? "\uf026" : (volPct >= 66 ? "\uf028" : (volPct >= 33 ? "\uf027" : "\uf026"))
                color: muted ? Theme.textDim : Theme.violetBright
                font { family: Theme.fontFamily; pixelSize: 14 }
            }

            Text {
                text:  "Volume"
                color: Theme.foreground
                font { family: Theme.fontFamily; pixelSize: 13 }
                Layout.fillWidth: true
                leftPadding: 6
            }

            // Mute toggle
            Rectangle {
                width:  46; height: 22
                radius: 11
                color:  muted ? Theme.violet : Theme.glassViolet
                border.color: muted ? Theme.violetBright : Theme.borderIdle
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text:  muted ? "Off" : "On"
                    color: muted ? Theme.textDim : Theme.accent
                    font { family: Theme.fontFamily; pixelSize: 11 }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: if (sink?.audio) sink.audio.muted = !sink.audio.muted
                }

                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                text:  volPct + "%"
                color: Theme.textDim
                font { family: Theme.fontFamily; pixelSize: 12 }
                leftPadding: 8
                Layout.minimumWidth: 36
                horizontalAlignment: Text.AlignRight
            }
        }

        // ── Slider ────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            implicitHeight: 20

            // Track background
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width:  parent.width
                height: 4
                radius: 2
                color:  Theme.glassViolet
                border.color: Theme.borderIdle
                border.width: 1

                // Fill
                Rectangle {
                    width:  Math.max(8, parent.width * (volPct / 100))
                    height: parent.height
                    radius: 2
                    color:  muted ? Theme.violetMid : Theme.violetBright
                    Behavior on width { NumberAnimation { duration: 80 } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            // Thumb
            Rectangle {
                x:      Math.max(0, Math.min(parent.width - width,
                        parent.width * (volPct / 100) - width / 2))
                anchors.verticalCenter: parent.verticalCenter
                width:  14; height: 14
                radius: 7
                color:  Theme.glassDeep
                border.color: muted ? Theme.violetMid : Theme.accent
                border.width: 2
                Behavior on x { NumberAnimation { duration: 80 } }
            }

            MouseArea {
                anchors.fill: parent
                onPressed:  mouse => updateVolume(mouse.x)
                onMouseXChanged: mouse => { if (pressed) updateVolume(mouse.x) }

                function updateVolume(x) {
                    if (!sink?.audio) return
                    const pct = Math.max(0, Math.min(1, x / width))
                    sink.audio.volume = pct
                    if (sink.audio.muted && pct > 0) sink.audio.muted = false
                }
            }
        }
    }
}
