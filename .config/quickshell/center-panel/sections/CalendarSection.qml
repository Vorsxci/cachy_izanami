import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"

// CalendarSection.qml
Item {
    id: root
    implicitWidth:  parent.width
    implicitHeight: calCol.implicitHeight

    property var  eventDates:   []
    property var  eventObjects: []   // [{ title, start, end, rawH, rawMin, allDay }]
    property int  displayYear:  today.getFullYear()
    property int  displayMonth: today.getMonth()
    property bool weekView:     false

    readonly property var today: new Date()

    // ── Navigation ────────────────────────────────────────────
    function prevPeriod() {
        if (weekView) {
            const ws = weekStart()
            ws.setDate(ws.getDate() - 7)
            weekAnchor = new Date(ws)
            displayYear  = ws.getFullYear()
            displayMonth = ws.getMonth()
        } else {
            if (displayMonth === 0) { displayMonth = 11; displayYear-- }
            else displayMonth--
        }
    }

    function nextPeriod() {
        if (weekView) {
            const ws = weekStart()
            ws.setDate(ws.getDate() + 7)
            weekAnchor = new Date(ws)
            displayYear  = ws.getFullYear()
            displayMonth = ws.getMonth()
        } else {
            if (displayMonth === 11) { displayMonth = 0; displayYear++ }
            else displayMonth++
        }
    }

    // weekAnchor = local midnight of the Sunday starting this week
    property var weekAnchor: {
        const d = new Date()
        d.setDate(d.getDate() - d.getDay())
        d.setHours(0, 0, 0, 0)
        return d
    }

    function weekStart() { return new Date(weekAnchor) }

    // ── Month grid data ───────────────────────────────────────
    property var gridDays: {
        const days = []
        const first = new Date(displayYear, displayMonth, 1)
        const startDow = first.getDay()
        const daysInMonth     = new Date(displayYear, displayMonth + 1, 0).getDate()
        const daysInPrevMonth = new Date(displayYear, displayMonth,     0).getDate()
        for (let i = 0; i < startDow; i++)
            days.push({ day: daysInPrevMonth - startDow + 1 + i, thisMonth: false, date: null })
        for (let i = 1; i <= daysInMonth; i++)
            days.push({ day: i, thisMonth: true, date: new Date(displayYear, displayMonth, i) })
        while (days.length < 42)
            days.push({ day: days.length - startDow - daysInMonth + 1, thisMonth: false, date: null })
        return days
    }

    // ── Week view columns ─────────────────────────────────────
    property var weekDays: {
        const days = []
        const ws   = weekStart()
        for (let i = 0; i < 7; i++) {
            const d = new Date(ws)
            d.setDate(ws.getDate() + i)
            days.push(d)
        }
        return days
    }

    // ── Helpers ───────────────────────────────────────────────
    function dateKey(d) {
        return d.getFullYear() + "-"
            + String(d.getMonth() + 1).padStart(2, "0") + "-"
            + String(d.getDate()).padStart(2, "0")
    }

    // dateKey using LOCAL date of a UTC-stored Date object
    // (events are stored as UTC; we need the local calendar day)
    function dateKeyLocal(d) {
        return d.getFullYear() + "-"
            + String(d.getMonth() + 1).padStart(2, "0") + "-"
            + String(d.getDate()).padStart(2, "0")
    }

    function hasEvent(d) {
        if (!d) return false
        return eventDates.indexOf(dateKey(d)) !== -1
    }

    function isToday(d) {
        if (!d) return false
        const t = today
        return d.getDate()     === t.getDate()
            && d.getMonth()    === t.getMonth()
            && d.getFullYear() === t.getFullYear()
    }

    function eventsOnDay(d) {
        if (!eventObjects || eventObjects.length === 0) return []
        const key = dateKey(d)   // d is a local-midnight Date, so dateKey is correct
        const out = []
        for (let i = 0; i < eventObjects.length; i++) {
            const ev = eventObjects[i]
            if (!ev.start) continue
            // ev.start is a UTC Date; compare its local date representation
            if (dateKeyLocal(ev.start) === key) out.push(ev)
        }
        return out
    }

    function fmtTime(h, m) {
        const ampm = h >= 12 ? "pm" : "am"
        const h12  = h % 12 === 0 ? 12 : h % 12
        return h12 + (m > 0 ? ":" + String(m).padStart(2, "0") : "") + ampm
    }

    // ── Layout ────────────────────────────────────────────────
    ColumnLayout {
        id: calCol
        anchors { left: parent.left; right: parent.right }
        spacing: 8

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text:  "\uf053"
                color: Theme.violetMid
                font { family: Theme.fontFamily; pixelSize: 11 }
                MouseArea { anchors.fill: parent; onClicked: prevPeriod() }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: weekView
                    ? Qt.formatDate(weekStart(), "MMM d") + " \u2013 "
                      + Qt.formatDate(new Date(weekStart().getTime() + 6 * 86400000), "MMM d, yyyy")
                    : Qt.formatDate(new Date(displayYear, displayMonth, 1), "MMMM yyyy")
                color: Theme.textPrimary
                font { family: Theme.fontFamily; pixelSize: 14; weight: Font.Medium }
            }

            Text {
                text:  "\uf054"
                color: Theme.violetMid
                font { family: Theme.fontFamily; pixelSize: 11 }
                MouseArea { anchors.fill: parent; onClicked: nextPeriod() }
            }

            // Toggle M ↔ W
            Item {
                implicitWidth: 52; implicitHeight: 22
                Rectangle {
                    anchors.fill: parent
                    radius: 11
                    color:  weekView ? Theme.violetBright : Theme.glassViolet
                    border.color: Theme.borderIdle; border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        x: weekView ? parent.width - width - 3 : 3
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16; height: 16; radius: 8
                        color: weekView ? Theme.background : Theme.violetMid
                        Behavior on x     { NumberAnimation { duration: 150; easing.type: Easing.InOutCubic } }
                        Behavior on color { ColorAnimation  { duration: 150 } }
                    }
                    Text {
                        anchors { left: parent.left; leftMargin: 5; verticalCenter: parent.verticalCenter }
                        text: "M"; font { family: Theme.fontFamily; pixelSize: 9; weight: Font.Medium }
                        color: weekView ? Qt.rgba(1,1,1,0.4) : Theme.textPrimary
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    Text {
                        anchors { right: parent.right; rightMargin: 5; verticalCenter: parent.verticalCenter }
                        text: "W"; font { family: Theme.fontFamily; pixelSize: 9; weight: Font.Medium }
                        color: weekView ? Theme.textPrimary : Qt.rgba(1,1,1,0.4)
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
                MouseArea { anchors.fill: parent; onClicked: weekView = !weekView }
            }
        }

        // DOW headers — always visible, shared by both views
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData; color: Theme.textDim
                    font { family: Theme.fontFamily; pixelSize: 11 }
                }
            }
        }

        // ── Month grid ────────────────────────────────────────
        Grid {
            visible: !weekView
            Layout.fillWidth: true
            columns: 7; spacing: 2

            Repeater {
                model: gridDays
                delegate: Item {
                    width: calCol.width / 7; height: 28

                    Rectangle {
                        anchors.centerIn: parent
                        width: 24; height: 24; radius: 12
                        color:   isToday(modelData.date) ? Theme.violetBright : "transparent"
                        visible: modelData.thisMonth
                    }
                    Text {
                        anchors.centerIn: parent
                        text: modelData.day
                        color: !modelData.thisMonth     ? "transparent"
                             : isToday(modelData.date)  ? Theme.background
                             : hasEvent(modelData.date) ? Theme.accent
                             : Theme.foreground
                        font { family: Theme.fontFamily; pixelSize: 12 }
                    }
                    Rectangle {
                        visible: hasEvent(modelData.date) && !isToday(modelData.date) && modelData.thisMonth
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 1
                        width: 4; height: 4; radius: 2; color: Theme.accent
                    }
                }
            }
        }

        // ── Week view ─────────────────────────────────────────
        // Fixed height matching the month grid (6 rows × 30px), so the panel doesn't resize
        Item {
            visible:          weekView
            Layout.fillWidth: true
            implicitHeight:   180   // ~same visual footprint as 6-row month grid

            Row {
                anchors.fill: parent
                spacing: 2

                Repeater {
                    model: weekDays
                    delegate: Item {
                        width:  (calCol.width - 12) / 7   // 12 = 2px gap × 6
                        height: parent.height

                        // Today highlight column background
                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color:  isToday(modelData)
                                    ? Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                                              Theme.violetBright.b, 0.08)
                                    : "transparent"
                        }

                        ColumnLayout {
                            anchors { left: parent.left; right: parent.right; top: parent.top }
                            anchors.margins: 2
                            spacing: 2

                            // Day number
                            Item {
                                Layout.fillWidth: true
                                implicitHeight:   26

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 22; height: 22; radius: 11
                                    color: isToday(modelData) ? Theme.violetBright : "transparent"
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text:  modelData.getDate()
                                    color: isToday(modelData)  ? Theme.background
                                         : hasEvent(modelData) ? Theme.accent
                                         : Theme.foreground
                                    font { family: Theme.fontFamily; pixelSize: 12 }
                                }
                            }

                            // Event pills — clipped to column height
                            Repeater {
                                model: eventsOnDay(modelData)
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    height: pillText.implicitHeight + 6
                                    radius: 3
                                    clip:   true
                                    color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                                                   Theme.violetBright.b, 0.22)
                                    border.color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                                                          Theme.violetBright.b, 0.5)
                                    border.width: 1

                                    // Left accent bar
                                    Rectangle {
                                        width: 2; height: parent.height
                                        color: Theme.violetBright; radius: 2
                                    }

                                    Text {
                                        id: pillText
                                        anchors {
                                            left: parent.left; right: parent.right
                                            top:  parent.top
                                            leftMargin: 5; rightMargin: 3; topMargin: 3
                                        }
                                        text:  modelData.allDay
                                               ? modelData.title
                                               : (fmtTime(modelData.rawH, modelData.rawMin)
                                                  + " " + modelData.title)
                                        color: Theme.foreground
                                        font { family: Theme.fontFamily; pixelSize: 8; weight: Font.Medium }
                                        wrapMode:    Text.WordWrap
                                        elide:       Text.ElideRight
                                        maximumLineCount: 2
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
