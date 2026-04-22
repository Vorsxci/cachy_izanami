// =============================================================
// CornerSun.qml — Animated corner sun reticle
// Fixed at 420x420 — edit SIZE to scale everything uniformly

// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    id: root

    readonly property real size: 420

    width:  size
    height: size

    property real ring1Angle: 0
    property real ring2Angle: 0
    property real ring3Angle: 0
    property real ring4Angle: 0
    property real glowPulse:  0
    property real spikeRotate: 0

    NumberAnimation on ring1Angle  { from: 0;   to: 360; duration: 28000; loops: Animation.Infinite; running: true }
    NumberAnimation on ring2Angle  { from: 0;   to: 360; duration: 16000; loops: Animation.Infinite; running: true }
    NumberAnimation on ring3Angle  { from: 360; to: 0;   duration: 11000; loops: Animation.Infinite; running: true }
    NumberAnimation on ring4Angle  { from: 360; to: 0;   duration: 44000; loops: Animation.Infinite; running: true }
    NumberAnimation on glowPulse   { from: 0; to: Math.PI * 2; duration: 4000; loops: Animation.Infinite; running: true }
    NumberAnimation on spikeRotate { from: 0; to: Math.PI * 2; duration: 80000; loops: Animation.Infinite; running: true }

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
            var u   = root.size / 420

            var glow = 0.5 + 0.5 * Math.sin(root.glowPulse)

            // ── Breathing corona glow ─────────────────────────
            var glowR = (170 + glow * 24) * u
            var glowGrad = ctx.createRadialGradient(cx, cy, 0, cx, cy, glowR)
            glowGrad.addColorStop(0.0, "rgba(244, 163, 64, "  + (0.16 + glow * 0.10) + ")")
            glowGrad.addColorStop(0.5, "rgba(255, 101, 87, "  + (0.06 + glow * 0.05) + ")")
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

            // ── Four rings — warm solar colors
            drawRing(188, root.ring4Angle, "#ffca98", 0.80, 1.2, 4,  6)
            drawRing(150, root.ring1Angle, "#F4A340", 0.85, 1.5, 8,  7)
            drawRing(115, root.ring2Angle, "#FF9898", 0.82, 1.3, 12, 5)
            drawRing( 80, root.ring3Angle, "#FF6557", 0.85, 1.2, 6,  4)

            // ── Crosshairs ────────────────────────────────────
            var ca = 0.80 + glow * 0.10
            ctx.strokeStyle = "#FFDCA0"
            ctx.globalAlpha = ca
            ctx.lineWidth   = 1.4 * u
            ctx.lineCap     = "square"

            var gap = 42 * u
            var ext = 200 * u

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
            ctx.fillStyle = "#FFDCA0"
            ctx.globalAlpha = 0.65 + glow * 0.30
            ctx.fill()
            ctx.globalAlpha = 1.0

            // ── Solar spike rays (slowly rotating) ────────────
            ctx.save()
            ctx.translate(cx, cy)
            ctx.rotate(root.spikeRotate)

            var mr = 36 * u
            var numSpk = 8

            for (var sp = 0; sp < numSpk * 2; sp++) {
                var spAngle = (sp / (numSpk * 2)) * Math.PI * 2
                var isPrimary = (sp % 2 === 0)
                var spLen = isPrimary ? mr * 1.1 : mr * 0.65
                var tipX = Math.cos(spAngle) * (mr + spLen)
                var tipY = Math.sin(spAngle) * (mr + spLen)
                var baseW = isPrimary ? 3.5 * u : 2.0 * u
                var perpX = -Math.sin(spAngle) * baseW
                var perpY =  Math.cos(spAngle) * baseW
                var baseX = Math.cos(spAngle) * (mr * 0.65)
                var baseY = Math.sin(spAngle) * (mr * 0.65)

                var spGrad = ctx.createLinearGradient(baseX, baseY, tipX, tipY)
                spGrad.addColorStop(0.0, isPrimary ? "rgba(255,220,160,0.75)" : "rgba(244,163,64,0.55)")
                spGrad.addColorStop(0.6, isPrimary ? "rgba(255,101, 87,0.30)" : "rgba(255,152,152,0.20)")
                spGrad.addColorStop(1.0, "rgba(255,101,87,0.00)")

                ctx.beginPath()
                ctx.moveTo(baseX + perpX, baseY + perpY)
                ctx.lineTo(tipX, tipY)
                ctx.lineTo(baseX - perpX, baseY - perpY)
                ctx.closePath()
                ctx.fillStyle = spGrad
                ctx.fill()
            }

            // ── Sun disc ──────────────────────────────────────
            var sunGrad = ctx.createLinearGradient(-mr, -mr, mr, mr)
            sunGrad.addColorStop(0.0, "#FFDCA0")
            sunGrad.addColorStop(0.5, "#F4A340")
            sunGrad.addColorStop(1.0, "#FF6557")

            ctx.beginPath()
            ctx.arc(0, 0, mr, 0, Math.PI * 2)
            ctx.fillStyle = sunGrad
            ctx.globalAlpha = 0.92
            ctx.fill()

            // No crescent cutout — full disc
            ctx.beginPath()
            ctx.arc(0, 0, mr, 0, Math.PI * 2)
            ctx.strokeStyle = "#FFDCA0"
            ctx.globalAlpha = 0.80 + glow * 0.12
            ctx.lineWidth   = 1.2 * u
            ctx.stroke()

            ctx.globalAlpha = 1.0
            ctx.restore()

            // ── Corner brackets ───────────────────────────────
            ctx.strokeStyle = "#FFDCA0"
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
            ctx.fillStyle = "#FF9898"
            ctx.globalAlpha = 0.40
            ctx.fillText("SLR-01", cx - 18 * u, height - 8 * u)
            ctx.globalAlpha = 1.0
        }
    }
}
