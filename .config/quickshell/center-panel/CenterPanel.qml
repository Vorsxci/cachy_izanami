import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./sections"
import "../theme"

PanelWindow {
    id: panel

    anchors.top: true
    exclusiveZone: 0

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    visible:        CenterPanelState.open
    implicitWidth:  600
    implicitHeight: flickable.contentHeight + 28

    WlrLayershell.margins {
        left:  Math.max(0, ((screen ? screen.width : 1920) - implicitWidth) / 2)
        right: Math.max(0, ((screen ? screen.width : 1920) - implicitWidth) / 2)
    }

    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onClicked: CenterPanelState.open = false
        z: -1
    }

    Rectangle {
        anchors.fill: parent
        color:        "#2E3440"
        border.color: Theme.borderIdle
        border.width: 1
        radius:       8

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 2
            color:  Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.40)
            radius: 8
        }

        Canvas {
            width: 20; height: 10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: -1
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.beginPath()
                ctx.moveTo(width / 2, 0)
                ctx.lineTo(width, height)
                ctx.lineTo(0, height)
                ctx.closePath()
                ctx.fillStyle = "#2E3440"
                ctx.fill()
                ctx.beginPath()
                ctx.moveTo(0, height)
                ctx.lineTo(width / 2, 0)
                ctx.lineTo(width, height)
                ctx.strokeStyle = Qt.rgba(Theme.borderIdle.r, Theme.borderIdle.g,
                                          Theme.borderIdle.b, Theme.borderIdle.a)
                ctx.lineWidth = 1
                ctx.stroke()
            }
        }
    }

    component Pill: Rectangle {
        default property alias content: pillInner.children
        Layout.fillWidth: true
        implicitHeight:   pillInner.childrenRect.height + 32
        color:            Theme.glassDeep
        radius:           8
        border.color:     Theme.borderIdle
        border.width:     1

        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width: 2
            color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                           Theme.violetBright.b, 0.45)
            radius: 2
        }

        Item {
            id: pillInner
            anchors { fill: parent; margins: 16; leftMargin: 20; bottomMargin: 16 }
        }
    }

    // ── Single EventsSection — the ONLY instance. Parses the ICS and holds the data.
    EventsSection {
        id: eventsData
        visible: false
    }

    Flickable {
        id: flickable
        anchors { fill: parent; topMargin: 14; leftMargin: 16; rightMargin: 16; bottomMargin: 8 }
        contentWidth:  width
        contentHeight: contentCol.implicitHeight
        clip: true

        ColumnLayout {
            id: contentCol
            width: parent.width
            spacing: 10

            Pill { UserSection {} }
            Pill { WeatherSection {} }

            Pill {
                implicitHeight: calendarRow.implicitHeight + 32

                RowLayout {
                    id: calendarRow
                    anchors { fill: parent; margins: 16; leftMargin: 20; bottomMargin: 16 }
                    spacing: 16

                    CalendarSection {
                        id: calSec
                        Layout.fillWidth: true
                        eventDates:   eventsData.eventDates
                        eventObjects: eventsData.events
                    }

                    Rectangle {
                        visible:           !calSec.weekView
                        width:             1
                        Layout.fillHeight: true
                        color:             Theme.borderIdle
                        opacity:           0.5
                    }

                    // ── Upcoming events list — reads directly from eventsData ──
                    // No second EventsSection instance. Render the list inline here
                    // so there is zero ambiguity about where the data comes from.
                    ColumnLayout {
                        visible:               !calSec.weekView
                        Layout.preferredWidth: 180
                        spacing: 6

                        Text {
                            text:  "Upcoming"
                            color: Theme.textDim
                            font { family: Theme.fontFamily; pixelSize: 11 }
                        }

                        Text {
                            visible: eventsData.events.length === 0
                            text:    "No upcoming events"
                            color:   Theme.textDim
                            font { family: Theme.fontFamily; pixelSize: 12; italic: true }
                        }

                        Repeater {
                            model: eventsData.events.slice(0, 5)

                            delegate: RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                function calColor(cal) {
                                    if (cal === "canvasCal")   return "#4C98D1"   // canvas blue
                                    if (cal === "eventsCal")   return "#9B94C4"   // violet
                                    if (cal === "meetingsCal") return "#D95337"   // meetings orange
                                    return "#9B94C4"
                                }

                                Rectangle {
                                    width:  3
                                    height: evtTitle.implicitHeight + 4
                                    radius: 2
                                    color:  parent.calColor(modelData.cal)
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        id: evtTitle
                                        text:  modelData.title
                                        color: Theme.foreground
                                        font { family: Theme.fontFamily; pixelSize: 13 }
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text:  eventsData.friendlyDate(modelData)
                                        color: Theme.accent
                                        font { family: Theme.fontFamily; pixelSize: 11 }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item { implicitHeight: 4 }
        }
    }
}
