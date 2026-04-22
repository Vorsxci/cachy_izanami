// =============================================================
// CornerMoon.qml — Animated corner moon reticle
// Fixed at 420x420 — edit SIZE to scale everything uniformly
// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    id: root

    // ── Single scale knob — change this to resize everything ──
    readonly property real size: 420

    width:  size
    height: size

    property real ring1Angle: 0
    property real ring2Angle: 0
    property real ring3Angle: 0
    property real ring4Angle: 0
    property real glowPulse:  0

    NumberAnimation on ring1Angle { from: 0;   to: 360; duration: 32000; loops: Animation.Infinite; running: true }
    NumberAnimation on ring2Angle { from: 0;   to: 360; duration: 18000; loops: Animation.Infinite; running: true }
    NumberAnimation on ring3Angle { from: 360; to: 0;   duration: 12000; loops: Animation.Infinite; running: true }
    NumberAnimation on ring4Angle { from: 360; to: 0;   duration: 48000; loops: Animation.Infinite; running: true }
    NumberAnimation on glowPulse  { from: 0; to: Math.PI * 2; duration: 5000; loops: Animation.Infinite; running: true }

    Timer {
        interval: 32
        repeat: true
        running: true
        onTriggered: canvas.requestPaint()
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cx  = width  / 2
            var cy  = height / 2
            var u   = root.size / 420   // unit scale — all values authored at SIZE=420

            var glow = 0.5 + 0.5 * Math.sin(root.glowPulse)

            // ── Breathing glow ────────────────────────────────
            var glowR = (160 + glow * 20) * u
            var glowGrad = ctx.createRadialGradient(cx, cy, 0, cx, cy, glowR)
            glowGrad.addColorStop(0.0, "rgba(180, 142, 173, " + (0.12 + glow * 0.08) + ")")
            glowGrad.addColorStop(0.6, "rgba(175, 197, 218, " + (0.05 + glow * 0.04) + ")")
            glowGrad.addColorStop(1.0, "rgba(0,0,0,0)")
            ctx.beginPath()
            ctx.arc(cx, cy, glowR, 0, Math.PI * 2)
            ctx.fillStyle = glowGrad
            ctx.fill()

            // ── Ring helper ───────────────────────────────────
            function drawRing(r, angle, color, alpha, lw, ticks, tl) {
                ctx.save()
                ctx.translate(cx, cy)
                ctx.rotate(angle * Math.PI / 180)
                ctx.beginPath()
                ctx.arc(0, 0, r * u, 0, Math.PI * 2)
                ctx.strokeStyle = color
                ctx.globalAlpha = alpha
                ctx.lineWidth   = lw * u
                ctx.stroke()
                for (var i = 0; i < ticks; i++) {
                    var a  = (i / ticks) * Math.PI * 2
                    var ix = Math.cos(a)
                    var iy = Math.sin(a)
                    ctx.beginPath()
                    ctx.moveTo(ix * (r - tl) * u, iy * (r - tl) * u)
                    ctx.lineTo(ix * (r + tl) * u, iy * (r + tl) * u)
                    ctx.lineWidth = lw * 0.7 * u
                    ctx.stroke()
                }
                ctx.globalAlpha = 1.0
                ctx.restore()
            }

            // ── Four rings (radius, angle, color, alpha, lw, ticks, tickLen)
            drawRing(188, root.ring4Angle, "#AFC5DA", 0.82, 1.2, 4,  6)
            drawRing(150, root.ring1Angle, "#D8DEE9", 0.87, 1.5, 8,  7)
            drawRing(115, root.ring2Angle, "#B48EAD", 0.84, 1.3, 12, 5)
            drawRing( 80, root.ring3Angle, "#AFC5DA", 0.87, 1.2, 6,  4)

            // ── Crosshairs ────────────────────────────────────
            var ca = 0.82 + glow * 0.08
            ctx.strokeStyle = "#FEFBD0"
            ctx.globalAlpha = ca
            ctx.lineWidth   = 1.4 * u
            ctx.lineCap     = "square"

            var gap = 42 * u   // gap around center moon
            var ext = 200 * u  // how far lines extend

            ctx.beginPath()
            ctx.moveTo(cx - ext, cy); ctx.lineTo(cx - gap, cy)
            ctx.moveTo(cx + gap, cy); ctx.lineTo(cx + ext, cy)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(cx, cy - ext); ctx.lineTo(cx, cy - gap)
            ctx.moveTo(cx, cy + gap); ctx.lineTo(cx, cy + ext)
            ctx.stroke()

            // Diagonal hints
            ctx.globalAlpha = ca * 0.4
            ctx.lineWidth   = 0.8 * u
            var dg = 30 * u
            var de = 145 * u
            ctx.beginPath()
            ctx.moveTo(cx - de, cy - de); ctx.lineTo(cx - dg, cy - dg)
            ctx.moveTo(cx + dg, cy + dg); ctx.lineTo(cx + de, cy + de)
            ctx.moveTo(cx + de, cy - de); ctx.lineTo(cx + dg, cy - dg)
            ctx.moveTo(cx - dg, cy + dg); ctx.lineTo(cx - de, cy + de)
            ctx.stroke()

            ctx.globalAlpha = 1.0
            ctx.lineCap = "butt"

            // ── Center dot ────────────────────────────────────
            ctx.beginPath()
            ctx.arc(cx, cy, 3.5 * u, 0, Math.PI * 2)
            ctx.fillStyle = "#FEFBD0"
            ctx.globalAlpha = 0.6 + glow * 0.3
            ctx.fill()
            ctx.globalAlpha = 1.0

            // ── Crescent moon ─────────────────────────────────
            var mr = 36 * u   // moon radius

            var moonGrad = ctx.createLinearGradient(cx - mr, cy - mr, cx + mr, cy + mr)
            moonGrad.addColorStop(0.0, "#FEFBD0")
            moonGrad.addColorStop(0.6, "#D8DEE9")
            moonGrad.addColorStop(1.0, "#AFC5DA")

            ctx.save()
            ctx.translate(cx, cy)

            ctx.beginPath()
            ctx.arc(0, 0, mr, 0, Math.PI * 2)
            ctx.fillStyle = moonGrad
            ctx.globalAlpha = 0.92
            ctx.fill()

            ctx.globalCompositeOperation = "destination-out"
            ctx.beginPath()
            ctx.arc(18 * u, -11 * u, mr - 5 * u, 0, Math.PI * 2)
            ctx.fillStyle = "rgba(0,0,0,1)"
            ctx.fill()
            ctx.globalCompositeOperation = "source-over"

            ctx.beginPath()
            ctx.arc(0, 0, mr, 0, Math.PI * 2)
            ctx.strokeStyle = "#FEFBD0"
            ctx.globalAlpha = 0.82 + glow * 0.10
            ctx.lineWidth   = 1.2 * u
            ctx.stroke()

            ctx.globalAlpha = 1.0
            ctx.restore()

            // ── Corner brackets ───────────────────────────────
            ctx.strokeStyle = "#FEFBD0"
            ctx.globalAlpha = 0.72
            ctx.lineWidth   = 1.5 * u
            var bl = 18 * u
            var bo = 4  * u

            ctx.beginPath(); ctx.moveTo(bo, bo + bl); ctx.lineTo(bo, bo); ctx.lineTo(bo + bl, bo); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(width - bo - bl, bo); ctx.lineTo(width - bo, bo); ctx.lineTo(width - bo, bo + bl); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(bo, height - bo - bl); ctx.lineTo(bo, height - bo); ctx.lineTo(bo + bl, height - bo); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(width - bo - bl, height - bo); ctx.lineTo(width - bo, height - bo); ctx.lineTo(width - bo, height - bo - bl); ctx.stroke()

            ctx.globalAlpha = 1.0

            // ── Data label ────────────────────────────────────
            ctx.font = (9 * u) + "px 'JetBrains Mono', monospace"
            ctx.fillStyle = "#AFC5DA"
            ctx.globalAlpha = 0.40
            ctx.fillText("LNR-01", cx - 18 * u, height - 8 * u)
            ctx.globalAlpha = 1.0
        }
    }
}
