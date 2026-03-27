import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../theme"

// WeatherModule — lives in bar/modules/left/
// weather-read.sh outputs e.g. "󰖐 13°C" — we split on the space
// so the icon can be sized independently from the temperature text.
Item {
    implicitHeight: Theme.barHeight
    implicitWidth:  row.implicitWidth + 8

    property string rawText:     ""
    property string tooltipText: ""
    property string weatherClass: ""  // sunny | cloudy | rain | snow
    property bool   isHovered:   false

    // Color based on weather condition
    property color iconColor: {
        switch (weatherClass) {
            case "sunny":  return "#F0A500"   // warm orange
            case "rain":   return "#AFC5DA"   // blue (mutedblue)
            case "snow":   return "#FFFFFF"   // white
            case "cloudy": return "#8A90A0"   // gray (textDim)
            default:       return Theme.mutedblue
        }
    }

    // Split "󰖐 13°C" into icon + temp
    // The icon is everything before the first space, temp is everything after
    property string weatherIcon: {
        const idx = rawText.indexOf(" ")
        return idx >= 0 ? rawText.substring(0, idx) : rawText
    }
    property string weatherTemp: {
        const idx = rawText.indexOf(" ")
        return idx >= 0 ? rawText.substring(idx + 1) : ""
    }

    Process {
        id: weatherProc
        command: ["bash", "-lc",
            "LOCK_WEATHER_PART=json /home/kazuki/.config/weather/weather-read.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j      = JSON.parse(text.trim())
                    rawText      = j.text    ?? text.trim()
                    tooltipText  = j.tooltip ?? ""
                    weatherClass = j.class   ?? ""
                } catch(e) {
                    rawText      = text.trim()
                    tooltipText  = ""
                    weatherClass = ""
                }
            }
        }
    }

    Timer {
        interval: 30000; running: true; repeat: true
        onTriggered: weatherProc.running = true
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // Weather icon — slightly larger, colored by condition
        Text {
            text:  weatherIcon
            color: iconColor
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 3 }
            Layout.alignment: Qt.AlignVCenter
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        // Temperature text
        Text {
            text:  weatherTemp
            color: Theme.mutedblue
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached([
            "xdg-terminal-exec", "--class=org.cachy.tui",
            "-e", "/home/kazuki/.config/weather/weather-config-tui.sh"
        ])
    }

    HoverHandler { onHoveredChanged: isHovered = hovered }

    Rectangle {
        visible:      isHovered && tooltipText !== ""
        anchors.top:  parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color:        Theme.glassDeep
        border.color: Theme.borderIdle
        border.width: 1
        radius:       6
        implicitWidth:  tipText.implicitWidth  + 24
        implicitHeight: tipText.implicitHeight + 16

        Text {
            id: tipText
            anchors.centerIn: parent
            text:  tooltipText
            color: Theme.foreground
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
        }
    }
}
