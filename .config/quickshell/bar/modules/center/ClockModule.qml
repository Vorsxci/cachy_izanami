import QtQuick
import Quickshell
import "../../../theme"

// ClockModule.qml — lives in bar/modules/center/
// Matches clock-toggle.sh behavior:
//   Default (JP): 2026年03月24日 | 火曜日 | 15:54
//   Toggled (EN): 03/24/2026 | Tuesday | 15:54
// Click to toggle, right-click for tz-select.
Item {
    implicitWidth:  clockText.contentWidth + 16
    implicitHeight: Theme.barHeight

    property bool showEnglish: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // Japanese weekday lookup matching clock-toggle.sh
    readonly property var jpWeekdays: [
        "日曜日",  // 0 Sunday
        "月曜日",  // 1 Monday
        "火曜日",  // 2 Tuesday
        "水曜日",  // 3 Wednesday
        "木曜日",  // 4 Thursday
        "金曜日",  // 5 Friday
        "土曜日",  // 6 Saturday
    ]

    Text {
        id: clockText
        anchors.centerIn: parent

        text: {
            const now     = clock.date
            const time    = Qt.formatTime(now, "HH:mm")
            const year    = now.getFullYear()
            const month   = String(now.getMonth() + 1).padStart(2, "0")
            const day     = String(now.getDate()).padStart(2, "0")
            const weekday = now.getDay()

            if (parent.showEnglish) {
                // EN: 03/24/2026 | Tuesday | 15:54
                return `${month}/${day}/${year} | ${Qt.formatDate(now, "dddd")} | ${time}`
            } else {
                // JP: 2026年03月24日 | 火曜日 | 15:54
                return `${year}年${month}月${day}日 | ${jpWeekdays[weekday]} | ${time}`
            }
        }

        color: Theme.textPrimary
        font {
            family:        Theme.fontFamily
            pixelSize:     Theme.fontSize
            weight:        Font.Medium
            letterSpacing: 0.5
        }

        Behavior on color { ColorAnimation { duration: 160 } }
    }

    MouseArea {
        anchors.fill:    parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                Quickshell.execDetached([
                    "launch-floating-terminal-with-presentation", "tz-select"
                ])
            else
                parent.showEnglish = !parent.showEnglish
        }
    }

    HoverHandler {
        onHoveredChanged: clockText.color = hovered ? Theme.accent : Theme.textPrimary
    }

    Behavior on implicitWidth {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }
}
