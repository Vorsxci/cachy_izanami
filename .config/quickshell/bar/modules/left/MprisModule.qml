import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../../theme"
import "../../../media-panel"

// MprisModule — lives in bar/modules/left/
// Always visible: shows a music note icon when nothing is playing,
// or track info when a player is active. Click opens/closes MediaPanel.
RowLayout {
    spacing: 4

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
    property bool hasPlayer: player !== null

    // Always visible — never hidden
    visible: true

    // ── Player / idle icon ────────────────────────────────────
    Text {
        text: {
            if (!hasPlayer) return "\uf001"   // nf-fa-music — idle state
            const name = (player.identity ?? "").toLowerCase()
            if (name.includes("spotify"))                             return "\uf1bc"
            if (name.includes("chromium") || name.includes("chrome")) return "\uf268"
            if (name.includes("mpv"))                                 return "🎵"
            return isPlaying ? "▶" : "⏸"
        }
        color:   hasPlayer ? (isPlaying ? Theme.mutedblue : Theme.lilac) : Theme.violetMid
        font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
        opacity: isPaused ? 0.7 : (hasPlayer ? 1.0 : 0.55)

        Behavior on color   { ColorAnimation { duration: 200 } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // ── Track info (hidden when idle) ─────────────────────────
    Text {
        visible: hasPlayer

        property string artist: player?.trackArtists?.join(", ") ?? ""
        property string title:  player?.trackTitle ?? ""

        text: {
            const a = artist.length > 15 ? artist.substring(0, 15) + "…" : artist
            const t = title.length  > 7 ? title.substring(0, 7)  + "…" : title
            if (a && t) return a + " – " + t
            return t || a || ""
        }

        color: isPaused ? Theme.lilac : Theme.mutedblue
        font {
            family:    Theme.fontFamily
            pixelSize: Theme.fontSize
            italic:    isPaused
        }

        width:            160
        elide:            Text.ElideRight
        maximumLineCount: 1

        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // ── Click opens / closes MediaPanel ──────────────────────
    MouseArea {
        anchors.fill:    parent
        anchors.margins: -4
        cursorShape:     Qt.PointingHandCursor
        onClicked:       MediaPanelState.toggle()
    }
}
