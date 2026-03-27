import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

// WeatherSection.qml — lives in center-panel/sections/
Item {
    implicitWidth:  parent.width
    implicitHeight: col.implicitHeight

    property string currentIcon:  ""
    property string currentTemp:  ""
    property string currentClass: ""
    property string location:     ""
    property var    forecast:     []
    property bool   refreshing:   false

    // Current conditions
    Process {
        id: currentProc
        command: ["bash", "-lc",
            "LOCK_WEATHER_PART=json /home/kazuki/.config/weather/weather-read.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j      = JSON.parse(text.trim())
                    const raw    = j.text ?? ""
                    const idx    = raw.indexOf(" ")
                    currentIcon  = idx >= 0 ? raw.substring(0, idx) : raw
                    currentTemp  = idx >= 0 ? raw.substring(idx + 1) : ""
                    currentClass = j.class   ?? ""
                    location     = j.tooltip ?? ""
                } catch(e) {}
                refreshing = false
            }
        }
    }

    // Manual update — runs weather-update.sh then re-reads
    Process {
        id: updateProc
        command: ["bash", "-lc", "/home/kazuki/.config/weather/weather-update.sh"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                currentProc.running  = true
                forecastProc.running = true
            }
        }
    }

    // 3-day forecast
    Process {
        id: forecastProc
        command: ["bash", "-c", `
            curl -sf "https://wttr.in/?format=j1" 2>/dev/null | \
            python3 -c "
import json,sys
d=json.load(sys.stdin)
days=d.get('weather',[])[:3]
icons={'113':'\uf185','116':'\uf0c2','119':'\uf0c2','122':'\uf0c2','176':'\uf043','179':'\uf2dc','200':'\uf0e7','227':'\uf2dc','230':'\uf2dc','248':'\uf0c2','260':'\uf0c2','263':'\uf043','266':'\uf043','281':'\uf043','284':'\uf043','293':'\uf043','296':'\uf043','299':'\uf043','302':'\uf043','305':'\uf043','308':'\uf043','320':'\uf2dc','323':'\uf2dc','326':'\uf2dc','356':'\uf043','359':'\uf043','362':'\uf043','365':'\uf043','386':'\uf0e7','389':'\uf0e7','392':'\uf0e7','395':'\uf2dc'}
for day in days:
    date=day.get('date','')
    code=str(day.get('hourly',[{}])[4].get('weatherCode','113'))
    hi=day.get('maxtempC','')
    lo=day.get('mintempC','')
    icon=icons.get(code,'\uf0c2')
    print(f'{date}|{icon}|{hi}|{lo}')
"
        `]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(l => l.length > 0)
                forecast = lines.map(l => {
                    const p = l.split("|")
                    return { date: p[0], icon: p[1], hi: p[2] + "°", lo: p[3] + "°" }
                })
            }
        }
    }

    Timer {
        interval: 1800000; running: true; repeat: true
        onTriggered: { currentProc.running = true; forecastProc.running = true }
    }

    property color iconColor: {
        switch (currentClass) {
            case "sunny":  return "#F0A500"
            case "rain":   return Theme.mutedblue
            case "snow":   return "#FFFFFF"
            case "cloudy": return Theme.textDim
            default:       return Theme.mutedblue
        }
    }

    ColumnLayout {
        id: col
        anchors { left: parent.left; right: parent.right }
        spacing: 12

        // ── Current conditions row ────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Big weather icon
            Text {
                text:  currentIcon
                color: iconColor
                font { family: Theme.fontFamily; pixelSize: 48 }
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: 300 } }
            }

            // Temp + location
            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                Text {
                    text:  currentTemp
                    color: Theme.textPrimary
                    font { family: Theme.fontFamily; pixelSize: 32; weight: Font.Medium }
                }

                Text {
                    text:  location
                    color: Theme.textDim
                    font { family: Theme.fontFamily; pixelSize: 12 }
                }
            }

            // ── Action buttons ────────────────────────────────
            ColumnLayout {
                spacing: 4
                Layout.alignment: Qt.AlignVCenter

                // Open weather config TUI
                Rectangle {
                    implicitWidth:  configBtn.contentWidth + 14
                    implicitHeight: 24
                    radius:         5
                    color:          configHov.hovered
                                    ? Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g,
                                              Theme.mutedblue.b, 0.18)
                                    : Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g,
                                              Theme.mutedblue.b, 0.08)
                    border.color:   configHov.hovered ? Theme.borderHover : Theme.borderIdle
                    border.width:   1
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        id:               configBtn
                        anchors.centerIn: parent
                        text:  "\uf013  Config"
                        color: configHov.hovered ? Theme.textPrimary : Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 2 }
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    HoverHandler { id: configHov }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached([
                            "xdg-terminal-exec", "--class=org.cachy.tui",
                            "-e", "/home/kazuki/.config/weather/weather-config-tui.sh"
                        ])
                    }
                }

                // Manual refresh button
                Rectangle {
                    implicitWidth:  refreshBtn.contentWidth + 14
                    implicitHeight: 24
                    radius:         5
                    color:          refreshHov.hovered
                                    ? Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                                              Theme.violetBright.b, 0.18)
                                    : Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                                              Theme.violetBright.b, 0.06)
                    border.color:   refreshHov.hovered ? Theme.borderActive : Theme.borderIdle
                    border.width:   1
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        id:               refreshBtn
                        anchors.centerIn: parent
                        text:  refreshing ? "\uf110  …" : "\uf021  Update"
                        color: refreshHov.hovered ? Theme.violetBright : Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 2 }
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    HoverHandler { id: refreshHov }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            if (!refreshing) {
                                refreshing = true
                                updateProc.running = true
                            }
                        }
                    }
                }
            }
        }

        // ── 3-day forecast strip ──────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            visible: forecast.length > 0

            Repeater {
                model: forecast

                delegate: Item {
                    Layout.fillWidth: true
                    implicitHeight:   forecastCol.implicitHeight

                    ColumnLayout {
                        id: forecastCol
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Text {
                            text: {
                                const d = new Date(modelData.date)
                                return Qt.formatDate(d, "ddd")
                            }
                            color: Theme.textDim
                            font { family: Theme.fontFamily; pixelSize: 11 }
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text:  modelData.icon
                            color: Theme.mutedblue
                            font { family: Theme.fontFamily; pixelSize: 20 }
                            Layout.alignment: Qt.AlignHCenter
                        }

                        RowLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignHCenter

                            Text {
                                text:  modelData.hi
                                color: Theme.textPrimary
                                font { family: Theme.fontFamily; pixelSize: 12 }
                            }
                            Text {
                                text:  modelData.lo
                                color: Theme.textDim
                                font { family: Theme.fontFamily; pixelSize: 12 }
                            }
                        }
                    }
                }
            }
        }
    }
}
