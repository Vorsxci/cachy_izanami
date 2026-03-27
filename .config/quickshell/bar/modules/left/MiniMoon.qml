import QtQuick
import "../../../theme"

// MiniMoon.qml — lives in bar/modules/left/
// Miniaturized CornerMoon: 4 rotating rings + crescent + glow + center dot
// Stripped of crosshairs, corner brackets, and data label for bar use.
Item {
    id: root

    readonly property real size: 32
    width:  size
    height: size

    // ── Rotation state ────────────────────────────────────────
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
        interval: 32; repeat: true; running: true
        onTriggered: canvas.requestPaint()
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            const cx  = width  / 2
            const cy  = height / 2
            // Scale factor: authored at 420px, rendering at 20px
            const u   = root.size / 420

            const glow = 0.5 + 0.5 * Math.sin(root.glowPulse)

            // ── Breathing glow ────────────────────────────────
            const glowR    = (160 + glow * 20) * u
            const glowGrad = ctx.createRadialGradient(cx, cy, 0, cx, cy, glowR)
            glowGrad.addColorStop(0.0, "rgba(180, 142, 173, " + (0.18 + glow * 0.10) + ")")
            glowGrad.addColorStop(0.6, "rgba(175, 197, 218, " + (0.08 + glow * 0.05) + ")")
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
                for (let i = 0; i < ticks; i++) {
                    const a  = (i / ticks) * Math.PI * 2
                    const ix = Math.cos(a)
                    const iy = Math.sin(a)
                    ctx.beginPath()
                    ctx.moveTo(ix * (r - tl) * u, iy * (r - tl) * u)
                    ctx.lineTo(ix * (r + tl) * u, iy * (r + tl) * u)
                    ctx.lineWidth = lw * 0.7 * u
                    ctx.stroke()
                }
                ctx.globalAlpha = 1.0
                ctx.restore()
            }

            // ── Four rings ────────────────────────────────────
            drawRing(188, root.ring4Angle, "#AFC5DA", 0.82, 1.2, 4,  6)
            drawRing(150, root.ring1Angle, "#D8DEE9", 0.87, 1.5, 8,  7)
            drawRing(115, root.ring2Angle, "#B48EAD", 0.84, 1.3, 12, 5)
            drawRing( 80, root.ring3Angle, "#AFC5DA", 0.87, 1.2, 6,  4)

            // ── Center dot ────────────────────────────────────
            ctx.beginPath()
            ctx.arc(cx, cy, 3.5 * u, 0, Math.PI * 2)
            ctx.fillStyle  = "#FEFBD0"
            ctx.globalAlpha = 0.6 + glow * 0.3
            ctx.fill()
            ctx.globalAlpha = 1.0

            // ── Crescent moon ─────────────────────────────────
            const mr = 36 * u

            const moonGrad = ctx.createLinearGradient(cx - mr, cy - mr, cx + mr, cy + mr)
            moonGrad.addColorStop(0.0, "#FEFBD0")
            moonGrad.addColorStop(0.6, "#D8DEE9")
            moonGrad.addColorStop(1.0, "#AFC5DA")

            ctx.save()
            ctx.translate(cx, cy)

            ctx.beginPath()
            ctx.arc(0, 0, mr, 0, Math.PI * 2)
            ctx.fillStyle  = moonGrad
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
        }
    }
}
