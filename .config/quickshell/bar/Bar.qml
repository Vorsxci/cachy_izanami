import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../utils-panel"
import "../center-panel"
import "modules/left/"
import "modules/center/"
import "modules/right/"

// Bar.qml — lives in bar/
Scope {
    id: barRoot

    readonly property alias networkSvc: networkSvc

    // ── CPU + Memory service ──────────────────────────────────
    QtObject {
        id: cpuMemSvc

        property int    cpuPct:   0
        property int    memPct:   0
        property string memUsed:  ""
        property string memTotal: ""

        readonly property bool cpuWarning:  cpuPct >= 50
        readonly property bool cpuCritical: cpuPct >= 80
        readonly property bool memWarning:  memPct >= 30
        readonly property bool memCritical: memPct >= 75

        property var _prev: null

        property var _cpuProc: Process {
            command: ["bash", "-c",
                "awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    const parts = text.trim().split(" ").map(Number)
                    const idle  = parts[3] + parts[4]
                    const total = parts.reduce((a, b) => a + b, 0)
                    const prev  = cpuMemSvc._prev
                    if (prev) {
                        const dTotal  = total - prev.total
                        const dIdle   = idle  - prev.idle
                        cpuMemSvc.cpuPct = dTotal > 0
                            ? Math.round((1 - dIdle / dTotal) * 100) : 0
                    }
                    cpuMemSvc._prev = { total, idle }
                }
            }
        }

        property var _memProc: Process {
            command: ["bash", "-c",
                "awk '/MemTotal|MemAvailable/{print $2}' /proc/meminfo | paste - -"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    const parts = text.trim().split(/\s+/).map(Number)
                    const total = parts[0]
                    const avail = parts[1]
                    const used  = total - avail
                    cpuMemSvc.memPct = Math.round(used / total * 100)
                    function fmt(kb) {
                        const gib = kb / 1_048_576
                        return gib >= 1 ? gib.toFixed(1) + "GiB"
                                        : (kb / 1024).toFixed(0) + "MiB"
                    }
                    cpuMemSvc.memUsed  = fmt(used)
                    cpuMemSvc.memTotal = fmt(total)
                }
            }
        }

        property var _timer: Timer {
            interval: 5000; running: true; repeat: true
            onTriggered: {
                cpuMemSvc._cpuProc.running = true
                cpuMemSvc._memProc.running = true
            }
        }
    }

    // ── Battery service ───────────────────────────────────────
    QtObject {
        id: batterySvc

        property int  capacity: 100
        property bool charging: false
        property bool plugged:  false
        property real power:    0.0

        readonly property bool warning:  !charging && capacity <= 35
        readonly property bool critical: !charging && capacity <= 10

        property var _proc: Process {
            command: ["bash", "-c", `
                BAT=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^BAT' | head -1)
                [ -z "$BAT" ] && echo "100 Unknown 0" && exit
                BAT=/sys/class/power_supply/$BAT
                cap=$(cat $BAT/capacity 2>/dev/null || echo 100)
                status=$(cat $BAT/status 2>/dev/null || echo Unknown)
                pow=$(cat $BAT/power_now 2>/dev/null || cat $BAT/current_now 2>/dev/null || echo 0)
                echo "$cap $status $pow"
            `]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    const parts         = text.trim().split(" ")
                    batterySvc.capacity = parseInt(parts[0]) || 100
                    const status        = parts[1] || "Unknown"
                    batterySvc.charging = (status === "Charging")
                    batterySvc.plugged  = (status === "Full" || status === "Not charging")
                    batterySvc.power    = (parseInt(parts[2]) || 0) / 1_000_000.0
                }
            }
        }

        property var _timer: Timer {
            interval: 5000; running: true; repeat: true
            onTriggered: batterySvc._proc.running = true
        }
    }

    // ── Network service ───────────────────────────────────────
    QtObject {
        id: networkSvc

        property bool   connected: false
        property bool   ethernet:  false
        property string ssid:      ""
        property int    signal:    0
        property string downSpeed: ""
        property string upSpeed:   ""

        property var _nmcli: Process {
            command: ["bash", "-c",
                "nmcli -t -f TYPE,STATE,CONNECTION dev status 2>/dev/null"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    const lines = text.trim().split("\n")
                    let found = false
                    for (const line of lines) {
                        const first  = line.indexOf(":")
                        const second = line.indexOf(":", first + 1)
                        if (first < 0 || second < 0) continue
                        const type  = line.substring(0, first)
                        const state = line.substring(first + 1, second)
                        const conn  = line.substring(second + 1)
                        if (state.startsWith("connected") && type !== "loopback"
                                && type !== "tun" && type !== "wifi-p2p") {
                            found                = true
                            networkSvc.ethernet  = (type === "ethernet")
                            networkSvc.connected = true
                            networkSvc.ssid      = conn
                            break
                        }
                    }
                    if (!found) {
                        networkSvc.connected = false
                        networkSvc.ethernet  = false
                        networkSvc.ssid      = ""
                        networkSvc.signal    = 0
                    }
                }
            }
        }

        property var _speed: Process {
            command: ["bash", "-c", `
                iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')
                [ -z "$iface" ] && echo "0 0" && exit
                r1=$(awk -v i="$iface:" '$1==i{print $2}' /proc/net/dev)
                t1=$(awk -v i="$iface:" '$1==i{print $10}' /proc/net/dev)
                sleep 1
                r2=$(awk -v i="$iface:" '$1==i{print $2}' /proc/net/dev)
                t2=$(awk -v i="$iface:" '$1==i{print $10}' /proc/net/dev)
                echo "$((r2-r1)) $((t2-t1))"
            `]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    const parts = text.trim().split(" ").map(Number)
                    networkSvc.downSpeed = networkSvc.fmt(parts[0])
                    networkSvc.upSpeed   = networkSvc.fmt(parts[1])
                }
            }
        }

        function fmt(bps) {
            if (bps >= 1_048_576) return (bps / 1_048_576).toFixed(1) + "MB/s"
            if (bps >= 1_024)     return Math.round(bps / 1_024) + "KB/s"
            return bps + "B/s"
        }

        property var _timer: Timer {
            interval: 5000; running: true; repeat: true
            onTriggered: {
                networkSvc._nmcli.running = true
                networkSvc._speed.running = true
            }
        }
    }

    // ── Bar window per monitor ────────────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.barHeight
            color: "transparent"

            // Use Item + anchors instead of RowLayout so center pill is
            // always screen-centered regardless of left/right pill widths
            Item {
                anchors.fill: parent
                anchors.leftMargin:   Theme.pillMarginH
                anchors.rightMargin:  Theme.pillMarginH
                anchors.topMargin:    Theme.pillMarginV
                anchors.bottomMargin: Theme.pillMarginV

                // ══ LEFT PILL ═════════════════════════════════
                Rectangle {
                    id: leftPill
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    implicitWidth: leftRow.implicitWidth + Theme.pillPadding * 2
                    color:         Theme.glassDeep
                    radius:        6
                    border.color:  Theme.borderIdle
                    border.width:  1

                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: 2
                        color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                                       Theme.violetBright.b, 0.55)
                        radius: 2
                    }

                    RowLayout {
                        id: leftRow
                        anchors {
                            fill:        parent
                            leftMargin:  Theme.pillPadding
                            rightMargin: Theme.pillPadding
                        }
                        spacing: Theme.chipSpacing

                        BarChip {
                            Layout.fillHeight: true
                            WorkspacesModule { anchors.verticalCenter: parent.verticalCenter }
                            Rectangle {
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                width: 1; height: parent.height * 0.6
                                color: Theme.borderIdle
                            }
                        }

                        // Mpris chip — always visible; width animates as track info appears
                        Item {
                            Layout.fillHeight: true
                            implicitWidth:     mprisChip.implicitWidth

                            Behavior on implicitWidth {
                                NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
                            }

                            BarChip {
                                id: mprisChip
                                height:     parent.height
                                leftAccent: true
                                MprisModule { anchors.verticalCenter: parent.verticalCenter }
                            }
                        }

                        BarChip {
                            Layout.fillHeight: true
                            Rectangle {
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                width: 1; height: parent.height * 0.6
                                color: Theme.borderIdle
                            }
                            WindowTitleModule {
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // ══ CENTER PILL — truly centered on screen ════
                Rectangle {
                    id: centerPill
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top:    parent.top
                    anchors.bottom: parent.bottom
                    implicitWidth:  centerRow.implicitWidth + Theme.pillPadding * 2
                    color:          Theme.glassDeep
                    radius:         6
                    border.color:   Theme.borderIdle
                    border.width:   1

                    Rectangle {
                        anchors { top: parent.top; left: parent.left; right: parent.right }
                        height: 2
                        color:  Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.30)
                        radius: 6
                    }

                    RowLayout {
                        id: centerRow
                        anchors {
                            fill:        parent
                            leftMargin:  Theme.pillPadding
                            rightMargin: Theme.pillPadding
                        }
                        spacing: Theme.chipSpacing

                        Item {
                            implicitWidth:    50
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                anchors.centerIn: parent
                                source:   "file:///home/kazuki/.config/themes/lunr/LUNR_OS_Logo.png"
                                width:    44; height: 22
                                fillMode: Image.PreserveAspectFit
                                smooth:   true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["menu", "themes"])
                            }
                        }

                        ClockModule {
                            Layout.fillHeight: true
                            Layout.alignment:  Qt.AlignVCenter
                        }

                        // MiniMoon trigger — fixed size, never expands
                        Item {
                            Layout.fillHeight: true
                            Layout.alignment:  Qt.AlignVCenter
                            implicitWidth:     36

                            MiniMoon {
                                width:  32
                                height: 32
                                anchors.centerIn: parent
                                opacity: CenterPanelState.open ? 1.0 : 0.75
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: CenterPanelState.toggle()
                            }
                        }

                        UpdateModule {
                            Layout.fillHeight: true
                            Layout.alignment:  Qt.AlignVCenter
                        }
                    }
                }

                // ══ RIGHT PILL ════════════════════════════════
                Rectangle {
                    id: rightPill
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    implicitWidth: rightRow.implicitWidth + Theme.pillPadding * 2
                    color:         Theme.glassDeep
                    radius:        6
                    border.color:  Theme.borderIdle
                    border.width:  1

                    Rectangle {
                        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                        width: 2
                        color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                                       Theme.violetBright.b, 0.55)
                        radius: 2
                    }

                    RowLayout {
                        id: rightRow
                        anchors {
                            fill:        parent
                            leftMargin:  Theme.pillPadding
                            rightMargin: Theme.pillPadding
                        }
                        spacing: Theme.chipSpacing

                        BarChip {
                            Layout.fillHeight: true
                            TrayModule { anchors.verticalCenter: parent.verticalCenter }
                        }

                        // Divider between tray and network
                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: Theme.borderIdle
                            opacity: 0.6
                        }

                        BarChip {
                            Layout.fillHeight: true
                            leftAccent: true
                            NetworkModule {
                                anchors.verticalCenter: parent.verticalCenter
                                service: networkSvc
                            }
                        }

                        BarChip {
                            Layout.fillHeight: true
                            leftAccent: true
                            CpuMemModule {
                                anchors.verticalCenter: parent.verticalCenter
                                service: cpuMemSvc
                            }
                        }

                        // Battery + gear grouped with no gap between them
                        RowLayout {
                            spacing: 0
                            Layout.fillHeight: true

                            BarChip {
                                Layout.fillHeight: true
                                leftAccent: true
                                BatteryModule {
                                    anchors.verticalCenter: parent.verticalCenter
                                    service: batterySvc
                                }
                            }

                            Rectangle {
                                id: gearChip
                                Layout.fillHeight: true
                                implicitWidth:     gearIcon.contentWidth + 12
                                color:             gearHover.hovered ? Theme.glassViolet : "transparent"
                                radius:            5
                                border.color:      gearHover.hovered ? Theme.borderHover : "transparent"
                                border.width:      1

                                Behavior on color        { ColorAnimation { duration: 180 } }
                                Behavior on border.color { ColorAnimation { duration: 180 } }

                                Text {
                                    id: gearIcon
                                    anchors.centerIn: parent
                                    text:  "\uf013"
                                    color: PanelState.open
                                           ? Theme.accent
                                           : (gearHover.hovered ? Theme.accent : Theme.violetMid)
                                    font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                HoverHandler {
                                    id: gearHover
                                    onHoveredChanged: {
                                        if (hovered) {
                                            gearCollapseTimer.stop()
                                            PanelState.open = true
                                        } else {
                                            gearCollapseTimer.restart()
                                        }
                                    }
                                }

                                Timer {
                                    id: gearCollapseTimer
                                    interval: 300
                                    onTriggered: {
                                        if (!PanelState.panelHovered)
                                            PanelState.open = false
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
