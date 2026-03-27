import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import "."
import "../theme"

// MediaPanel.qml — lives in media-panel/
PanelWindow {
    id: panel

    anchors.top:  true
    anchors.left: true

    exclusiveZone: 0
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    visible:        MediaPanelState.open
    implicitWidth:  480
    implicitHeight: content.implicitHeight + 28

    color: "transparent"

    // ── Hover / auto-close ────────────────────────────────────
    HoverHandler {
        onHoveredChanged: {
            MediaPanelState.panelHovered = hovered
            if (!hovered) collapseTimer.restart()
            else          collapseTimer.stop()
        }
    }
    Timer {
        id: collapseTimer
        interval: 600
        onTriggered: if (!MediaPanelState.panelHovered) MediaPanelState.open = false
    }

    // ── Active MPRIS player ───────────────────────────────────
    property var player: {
        const players = Mpris.players.values
        if (!players || players.length === 0) return null
        return players.find(p => p.playbackState === MprisPlaybackState.Playing)
            ?? players.find(p => p.playbackState === MprisPlaybackState.Paused)
            ?? players[0]
            ?? null
    }

    property bool isPlaying: player?.playbackState === MprisPlaybackState.Playing
    property bool isPaused:  player?.playbackState === MprisPlaybackState.Paused

    // ── Pipewire output sinks ─────────────────────────────────
    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    property var audioSink:     Pipewire.defaultAudioSink
    property bool sinkDropOpen: false

    property var sinkList: {
        return Pipewire.nodes.values.filter(n =>
            n.audio !== null && n.isSink === true
        )
    }

    // ── Seek / duration ───────────────────────────────────────
    property real positionSec: 0
    property real durationSec: {
        const l = panel.player?.length ?? 0
        return l > 0 ? (l / 1000000.0) : 0
    }

    onPlayerChanged: {
        positionSec = player ? (player.position / 1000000.0) : 0
    }

    Connections {
        target: panel.player
        function onTrackTitleChanged() {
            panel.positionSec = 0
        }
        function onPositionChanged() {
            panel.positionSec = panel.player.position / 1000000.0
        }
    }

    Timer {
        interval: 1000
        running:  panel.visible && panel.isPlaying
        repeat:   true
        onTriggered: {
            if (panel.player)
                panel.positionSec = panel.player.position / 1000000.0
        }
    }

    // ── Cava bars ─────────────────────────────────────────────
    property var  cavaBars:      Array(32).fill(0.1)
    property bool cavaAvailable: false
    property real _simPhase:     0

    Timer {
        id: simTimer
        interval: 60
        running:  panel.visible && (!panel.cavaAvailable || !panel.isPlaying)
        repeat:   true
        onTriggered: {
            panel._simPhase += 0.15
            const bars = []
            for (let i = 0; i < 32; i++) {
                const t = panel._simPhase + i * 0.40
                const v = Math.sin(t) * 0.32 + Math.sin(t * 1.8 + 1.1) * 0.22 + 0.46
                bars.push(Math.max(0.05, Math.min(1.0, v)))
            }
            panel.cavaBars = bars
        }
    }

    Process {
        id: cavaProc
        command: ["bash", "-c",
            "FIFO=/tmp/cava-qs.fifo; " +
            "[ -p \"$FIFO\" ] || { echo NOCAVA; exit 0; }; " +
            "cat \"$FIFO\""
        ]
        running: panel.visible
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                const t = line.trim()
                if (t === "NOCAVA") { panel.cavaAvailable = false; return }
                const parts = t.split(";").map(v => parseFloat(v))
                if (parts.length >= 4 && parts.every(v => !isNaN(v))) {
                    panel.cavaAvailable = true
                    panel.cavaBars = parts
                }
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────
    function fmtTime(sec) {
        const s = Math.max(0, Math.floor(sec))
        return Math.floor(s / 60) + ":" + ("0" + (s % 60)).slice(-2)
    }

    // ── Panel shell ───────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        Theme.glassDeep
        border.color: Theme.borderIdle
        border.width: 1
        radius:       10

        Rectangle {
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            width:  2
            color:  Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                            Theme.violetBright.b, 0.70)
            radius: 2
        }
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 2
            color:  Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.28)
            radius: 10
        }

        ColumnLayout {
            id: content
            anchors { fill: parent; margins: 18 }
            spacing: 14

            // ── No-player placeholder ─────────────────────────
            Item {
                visible:          !panel.player
                Layout.fillWidth: true
                implicitHeight:   80
                Text {
                    anchors.centerIn: parent
                    text:  "\uf001  No media playing"
                    color: Theme.textDim
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 2 }
                }
            }

            // ── Art + info row ────────────────────────────────
            RowLayout {
                visible:          !!panel.player
                Layout.fillWidth: true
                spacing:          20

                // Album art + cava ring
                Item {
                    implicitWidth:  164
                    implicitHeight: 164

                    Canvas {
                        id:           vizCanvas
                        anchors.fill: parent
                        property var bars: panel.cavaBars
                        onBarsChanged: requestPaint()

                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            const cx    = width  / 2
                            const cy    = height / 2
                            const n     = bars.length
                            const baseR = Math.min(cx, cy) - 26
                            const maxL  = 24

                            // Lilac (#9B94C4) → yellow (#FEFBD0)
                            const lr = 0.608, lg = 0.580, lb = 0.769
                            const hr = 0.996, hg = 0.984, hb = 0.816

                            for (let i = 0; i < n; i++) {
                                const angle = (i / n) * 2 * Math.PI - Math.PI / 2
                                const val   = Math.max(0.05, bars[i] || 0.05)
                                const sLen  = 5 + val * maxL

                                const x1 = cx + Math.cos(angle) * baseR
                                const y1 = cy + Math.sin(angle) * baseR
                                const x2 = cx + Math.cos(angle) * (baseR + sLen)
                                const y2 = cy + Math.sin(angle) * (baseR + sLen)

                                const r = lr + (hr - lr) * val
                                const g = lg + (hg - lg) * val
                                const b = lb + (hb - lb) * val
                                const a = 0.30 + val * 0.70

                                ctx.beginPath()
                                ctx.moveTo(x1, y1)
                                ctx.lineTo(x2, y2)
                                ctx.strokeStyle = Qt.rgba(r, g, b, a).toString()
                                ctx.lineWidth   = 2.5
                                ctx.lineCap     = "round"
                                ctx.stroke()
                            }
                        }
                    }

                    Rectangle {
                        width:  116; height: 116
                        anchors.centerIn: parent
                        radius:       10
                        color:        Theme.glassViolet
                        border.color: Theme.borderIdle
                        border.width: 1
                        clip:         true

                        Text {
                            anchors.centerIn: parent
                            visible: artImg.status !== Image.Ready
                            text:    "\uf001"
                            color:   Theme.violetMid
                            font { family: Theme.fontFamily; pixelSize: 38 }
                        }

                        Image {
                            id:           artImg
                            anchors.fill: parent
                            source:       panel.player?.trackArtUrl ?? ""
                            fillMode:     Image.PreserveAspectCrop
                            smooth:       true
                        }
                    }
                }

                // Track metadata + controls
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing:          3

                    // Title
                    Text {
                        Layout.fillWidth: true
                        text:  panel.player?.trackTitle ?? "Unknown"
                        color: Theme.textPrimary
                        font { family: Theme.fontFamily; pixelSize: 15; bold: true }
                        elide: Text.ElideRight
                    }

                    // Artist — trackArtists is a QStringList; cast via "" + x to get
                    // a comma-joined string that Qt auto-converts from the list
                    Text {
                        Layout.fillWidth: true
                        text: {
                            const raw = panel.player?.trackArtists
                            if (!raw) return "Unknown Artist"
                            // Qt auto-joins QStringList to "a, b, c" when coerced to string
                            const s = "" + raw
                            return s.length > 0 ? s : "Unknown Artist"
                        }
                        color: Theme.mutedblue
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
                        elide: Text.ElideRight
                    }

                    // Album
                    Text {
                        Layout.fillWidth: true
                        text:  panel.player?.trackAlbum ?? ""
                        color: Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 1 }
                        elide: Text.ElideRight
                    }

                    Item { implicitHeight: 6 }

                    // Playback controls
                    RowLayout {
                        spacing:          18
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            text:  "\uf049"
                            color: prevHov.hovered ? Theme.accent : Theme.mutedblue
                            font { family: Theme.fontFamily; pixelSize: 20 }
                            Behavior on color { ColorAnimation { duration: 100 } }
                            HoverHandler { id: prevHov }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: panel.player?.previous()
                            }
                        }

                        Rectangle {
                            width: 40; height: 40; radius: 20
                            color: playHov.hovered
                                   ? Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g,
                                             Theme.mutedblue.b, 0.28)
                                   : Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g,
                                             Theme.mutedblue.b, 0.13)
                            border.color: Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g,
                                                  Theme.mutedblue.b, 0.38)
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 100 } }
                            Text {
                                anchors.centerIn: parent
                                text:  panel.isPlaying ? "\uf04c" : "\uf04b"
                                color: Theme.accent
                                font { family: Theme.fontFamily; pixelSize: 18 }
                            }
                            HoverHandler { id: playHov }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: panel.player?.togglePlaying()
                            }
                        }

                        Text {
                            text:  "\uf050"
                            color: nextHov.hovered ? Theme.accent : Theme.mutedblue
                            font { family: Theme.fontFamily; pixelSize: 20 }
                            Behavior on color { ColorAnimation { duration: 100 } }
                            HoverHandler { id: nextHov }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: panel.player?.next()
                            }
                        }
                    }
                }
            }

            // ── Seek bar ──────────────────────────────────────
            ColumnLayout {
                visible:          !!panel.player
                Layout.fillWidth: true
                spacing:          5

                Item {
                    Layout.fillWidth: true
                    implicitHeight:   5

                    Rectangle {
                        anchors.fill: parent
                        color:  Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g,
                                        Theme.mutedblue.b, 0.16)
                        radius: 3
                    }
                    Rectangle {
                        width: panel.durationSec > 0
                               ? Math.min(parent.width,
                                   parent.width * (panel.positionSec / panel.durationSec))
                               : 0
                        height: parent.height
                        color:  Theme.mutedblue
                        radius: 3
                        Behavior on width {
                            NumberAnimation { duration: 950; easing.type: Easing.Linear }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            if (panel.player && panel.durationSec > 0) {
                                const frac        = Math.max(0, Math.min(1, mouse.x / width))
                                panel.player.position = Math.round(frac * panel.player.length)
                                panel.positionSec     = frac * panel.durationSec
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text:  panel.fmtTime(panel.positionSec)
                        color: Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 2 }
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text:  panel.fmtTime(panel.durationSec)
                        color: Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 2 }
                    }
                }
            }

            // ── Audio output device selector ──────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing:          5

                // Header / toggle row
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text:  "\uf028  Output"
                        color: Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 1 }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: {
                            const d = panel.audioSink?.description
                                      ?? panel.audioSink?.name ?? "—"
                            return d.length > 24 ? d.substring(0, 24) + "…" : d
                        }
                        color: Theme.mutedblue
                        font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 1 }
                    }

                    Text {
                        text:        panel.sinkDropOpen ? "\uf077" : "\uf078"
                        color:       Theme.violetMid
                        leftPadding: 6
                        font { family: Theme.fontFamily; pixelSize: 10 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    panel.sinkDropOpen = !panel.sinkDropOpen
                    }
                }

                // Sink list
                ColumnLayout {
                    visible:          panel.sinkDropOpen
                    Layout.fillWidth: true
                    spacing:          2

                    Repeater {
                        model: panel.sinkList

                        delegate: Rectangle {
                            property var  s:   modelData
                            property bool cur: s === panel.audioSink

                            Layout.fillWidth: true
                            implicitHeight:   30
                            radius:           5
                            color: cur
                                   ? Qt.rgba(Theme.violetBright.r, Theme.violetBright.g,
                                             Theme.violetBright.b, 0.18)
                                   : (sinkHov.hovered
                                      ? Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g,
                                                Theme.mutedblue.b, 0.10)
                                      : "transparent")
                            border.color: cur ? Theme.borderActive : "transparent"
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin:  10; rightMargin: 10
                                }
                                spacing: 8

                                Rectangle {
                                    width: 6; height: 6; radius: 3
                                    color:        cur ? Theme.accent : "transparent"
                                    border.color: cur ? Theme.accent : Theme.borderIdle
                                    border.width: 1
                                    Layout.alignment: Qt.AlignVCenter
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: {
                                        const d = s.description ?? s.name ?? "Unknown"
                                        return d.length > 38 ? d.substring(0, 38) + "…" : d
                                    }
                                    color: cur ? Theme.textPrimary : Theme.textDim
                                    font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 1 }
                                    elide: Text.ElideRight
                                }
                            }

                            HoverHandler { id: sinkHov }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: {
                                    Pipewire.defaultAudioSink = s
                                    panel.sinkDropOpen = false
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight:   1
                    color:            Theme.borderIdle
                    opacity:          0.4
                }
            }

            // ── Player source buttons (only with multiple players) ─
            RowLayout {
                visible:          Mpris.players.values.length > 1
                Layout.fillWidth: true
                spacing:          6

                Repeater {
                    model: Mpris.players.values
                    delegate: Rectangle {
                        property var  p:   modelData
                        property bool sel: panel.player === p

                        implicitHeight: 26
                        implicitWidth:  pLbl.contentWidth + 18
                        radius:         5
                        color: sel
                               ? Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g,
                                         Theme.mutedblue.b, 0.22)
                               : Qt.rgba(Theme.mutedblue.r, Theme.mutedblue.g,
                                         Theme.mutedblue.b, 0.07)
                        border.color: sel ? Theme.mutedblue : Theme.borderIdle
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            id:               pLbl
                            anchors.centerIn: parent
                            text:  p.identity ?? "Player"
                            color: sel ? Theme.textPrimary : Theme.textDim
                            font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 1 }
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: p.raise()
                        }
                    }
                }
            }
        }
    }
}
