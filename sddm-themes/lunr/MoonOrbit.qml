// =============================================================
// MoonOrbit.qml — Digital crescent moon with stacked orbits
// Sharp geometric aesthetic — NieR / LuNR style
// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    id: root
    width: 660
    height: 660

    readonly property real s: 3.0   // scale factor

    property real ring1Angle: 0
    property real ring2Angle: 0
    property real ring3Angle: 0
    property real glowPulse:  0
    property real scanLine:   0

    // Ring 1 — slow
    NumberAnimation on ring1Angle {
        from: 0; to: 360
        duration: 18000
        loops: Animation.Infinite
        running: true
    }

    // Ring 2 — medium, opposite
    NumberAnimation on ring2Angle {
        from: 360; to: 0
        duration: 11000
        loops: Animation.Infinite
        running: true
    }

    // Ring 3 — fast
    NumberAnimation on ring3Angle {
        from: 0; to: 360
        duration: 7000
        loops: Animation.Infinite
        running: true
    }

    // Glow pulse
    NumberAnimation on glowPulse {
        from: 0; to: Math.PI * 2
        duration: 4000
        loops: Animation.Infinite
        running: true
    }

    // Scan line sweep
    NumberAnimation on scanLine {
        from: 0; to: 1
        duration: 3000
        loops: Animation.Infinite
        running: true
    }

    // ── Repaint timer ─────────────────────────────────────────
    Timer {
        interval: 16
        repeat: true
        running: true
        onTriggered: canvas.requestPaint()
    }

    // ── Main canvas ───────────────────────────────────────────
    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: false   // OFF — we want sharp digital edges

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cx = width  / 2
            var cy = height / 2
            var sc = root.s

            // All orbits share the same tilt — 45 deg, bottom-left to top-right
            var TILT = 45

            // ── Stacked orbit radii (same tilt, different sizes) ──
            // Each ring: [radiusX, radiusY, color, dashOn, dashOff]
            var rings = [
                { rx: 92, ry: 28, color: "#AFC5DA", dash: [4, 5],  alpha: 0.35 },
                { rx: 70, ry: 21, color: "#B48EAD", dash: [6, 4],  alpha: 0.30 },
                { rx: 50, ry: 15, color: "#FAFF99", dash: [3, 7],  alpha: 0.25 },
            ]

            // ── Draw orbit rings first (behind moon) ─────────────
            rings.forEach(function(r) {
                ctx.save()
                ctx.translate(cx, cy)
                ctx.rotate(TILT * Math.PI / 180)
                ctx.beginPath()
                ctx.ellipse(0, 0, r.rx * sc, r.ry * sc, 0, 0, Math.PI * 2)
                ctx.strokeStyle = r.color
                ctx.globalAlpha = r.alpha
                ctx.lineWidth = 1.2 * sc
                ctx.setLineDash(r.dash.map(function(v){ return v * sc }))
                ctx.stroke()
                ctx.setLineDash([])
                ctx.globalAlpha = 1.0
                ctx.restore()

                // Corner tick marks at 0/90/180/270 deg of each ring
                ;[0, 90, 180, 270].forEach(function(deg) {
                    var rad  = deg * Math.PI / 180
                    var tRad = TILT * Math.PI / 180
                    var ex = r.rx * sc * Math.cos(rad)
                    var ey = r.ry * sc * Math.sin(rad)
                    var rx2 = ex * Math.cos(tRad) - ey * Math.sin(tRad)
                    var ry2 = ex * Math.sin(tRad) + ey * Math.cos(tRad)
                    ctx.save()
                    ctx.translate(cx + rx2, cy + ry2)
                    ctx.rotate(TILT * Math.PI / 180)
                    ctx.strokeStyle = r.color
                    ctx.globalAlpha = r.alpha * 2
                    ctx.lineWidth = 1.0 * sc
                    var ts = 3 * sc
                    ctx.beginPath()
                    ctx.moveTo(-ts, 0); ctx.lineTo(ts, 0)
                    ctx.moveTo(0, -ts); ctx.lineTo(0, ts)
                    ctx.stroke()
                    ctx.globalAlpha = 1.0
                    ctx.restore()
                })
            })

            // ── Digital crescent moon ─────────────────────────────
            var moonR = 36 * sc

            // Pixelated glow — drawn as concentric squares, not circles
            var glowSize = (52 + Math.sin(root.glowPulse) * 4) * sc
            var pulseAlpha = 0.06 + Math.sin(root.glowPulse) * 0.02
            ;[1.0, 0.75, 0.5, 0.25].forEach(function(t) {
                var gs = glowSize * t
                ctx.save()
                ctx.globalAlpha = pulseAlpha * (1 - t + 0.2)
                ctx.fillStyle = "#605A80"
                // Diamond / rotated square glow
                ctx.beginPath()
                ctx.save()
                ctx.translate(cx, cy)
                ctx.rotate(Math.PI / 4)
                ctx.fillRect(-gs/2, -gs/2, gs, gs)
                ctx.restore()
                ctx.restore()
            })

            // Moon body — flat-faced hexagonal polygon for digital look
            ctx.save()
            ctx.translate(cx, cy)

            // Clip path: hexagon
            var hex = 6
            ctx.beginPath()
            for (var i = 0; i < hex; i++) {
                var hexAngle = (i / hex) * Math.PI * 2 - Math.PI / 6
                var hx = moonR * Math.cos(hexAngle)
                var hy = moonR * Math.sin(hexAngle)
                if (i === 0) ctx.moveTo(hx, hy)
                else ctx.lineTo(hx, hy)
            }
            ctx.closePath()
            ctx.save()
            ctx.clip()

            // Moon fill — flat gradient with hard stop
            var moonGrad = ctx.createLinearGradient(-moonR, -moonR, moonR, moonR)
            moonGrad.addColorStop(0.0,  "#FEFBD0")
            moonGrad.addColorStop(0.45, "#D8DEE9")
            moonGrad.addColorStop(0.55, "#AFC5DA")
            moonGrad.addColorStop(1.0,  "#605A80")
            ctx.fillStyle = moonGrad
            ctx.fillRect(-moonR, -moonR, moonR * 2, moonR * 2)

            // Scan line across moon surface
            var scanY = -moonR + root.scanLine * moonR * 2
            ctx.fillStyle = "rgba(254, 251, 208, 0.06)"
            ctx.fillRect(-moonR, scanY - 1.5 * sc, moonR * 2, 3 * sc)

            // Grid lines on moon surface
            ctx.strokeStyle = "rgba(175, 197, 218, 0.10)"
            ctx.lineWidth = 0.5 * sc
            for (var gx = -moonR; gx <= moonR; gx += 10 * sc) {
                ctx.beginPath()
                ctx.moveTo(gx, -moonR)
                ctx.lineTo(gx, moonR)
                ctx.stroke()
            }
            for (var gy = -moonR; gy <= moonR; gy += 10 * sc) {
                ctx.beginPath()
                ctx.moveTo(-moonR, gy)
                ctx.lineTo(moonR, gy)
                ctx.stroke()
            }

            ctx.restore() // clip

            // Crescent cutout — offset square/hex to upper right
            ctx.globalCompositeOperation = "destination-out"
            ctx.beginPath()
            var cutR = moonR - 3 * sc
            for (var j = 0; j < hex; j++) {
                var cutAngle = (j / hex) * Math.PI * 2 - Math.PI / 6
                var cutx = cutR * Math.cos(cutAngle) + 20 * sc
                var cuty = cutR * Math.sin(cutAngle) - 12 * sc
                if (j === 0) ctx.moveTo(cutx, cuty)
                else ctx.lineTo(cutx, cuty)
            }
            ctx.closePath()
            ctx.fillStyle = "rgba(0,0,0,1)"
            ctx.fill()
            ctx.globalCompositeOperation = "source-over"

            // Moon border — sharp geometric stroke
            ctx.beginPath()
            for (var k = 0; k < hex; k++) {
                var bAngle = (k / hex) * Math.PI * 2 - Math.PI / 6
                var bx = moonR * Math.cos(bAngle)
                var by = moonR * Math.sin(bAngle)
                if (k === 0) ctx.moveTo(bx, by)
                else ctx.lineTo(bx, by)
            }
            ctx.closePath()
            ctx.strokeStyle = "#FEFBD0"
            ctx.globalAlpha = 0.6
            ctx.lineWidth = 1.0 * sc
            ctx.stroke()
            ctx.globalAlpha = 1.0

            // Corner accent marks on moon
            ctx.strokeStyle = "#FAFF99"
            ctx.globalAlpha = 0.8
            ctx.lineWidth = 1.2 * sc
            var cm = moonR * 0.7
            var cl = 6 * sc
            // top-left corner
            ctx.beginPath(); ctx.moveTo(-cm, -cm + cl); ctx.lineTo(-cm, -cm); ctx.lineTo(-cm + cl, -cm); ctx.stroke()
            // top-right corner
            ctx.beginPath(); ctx.moveTo(cm - cl, -cm); ctx.lineTo(cm, -cm); ctx.lineTo(cm, -cm + cl); ctx.stroke()
            // bottom-left corner
            ctx.beginPath(); ctx.moveTo(-cm, cm - cl); ctx.lineTo(-cm, cm); ctx.lineTo(-cm + cl, cm); ctx.stroke()
            // bottom-right corner
            ctx.beginPath(); ctx.moveTo(cm - cl, cm); ctx.lineTo(cm, cm); ctx.lineTo(cm, cm - cl); ctx.stroke()
            ctx.globalAlpha = 1.0

            ctx.restore() // translate

            // ── Draw orbiting diamond stars (in front of moon) ────
            function drawDiamond(angle, ringRx, ringRy, size, color) {
                var rad  = angle * Math.PI / 180
                var tRad = TILT * Math.PI / 180

                var ex = ringRx * sc * Math.cos(rad)
                var ey = ringRy * sc * Math.sin(rad)

                var rx2 = ex * Math.cos(tRad) - ey * Math.sin(tRad)
                var ry2 = ex * Math.sin(tRad) + ey * Math.cos(tRad)

                var sx = cx + rx2
                var sy = cy + ry2

                // Only draw if in front (positive ry component)
                var depthAlpha = 0.35 + 0.65 * ((ry2 / (ringRy * sc) + 1) / 2)

                var ps = size * sc
                ctx.save()
                ctx.globalAlpha = depthAlpha
                ctx.translate(sx, sy)
                ctx.rotate(Math.PI / 4)  // rotate to diamond orientation

                // Sharp 4-point diamond
                ctx.beginPath()
                ctx.moveTo(0,   -ps)
                ctx.lineTo(ps,   0)
                ctx.lineTo(0,    ps)
                ctx.lineTo(-ps,  0)
                ctx.closePath()
                ctx.fillStyle = color
                ctx.fill()

                // Hard bright center dot
                ctx.beginPath()
                ctx.arc(0, 0, ps * 0.25, 0, Math.PI * 2)
                ctx.fillStyle = "#FFFFFF"
                ctx.globalAlpha = depthAlpha * 0.8
                ctx.fill()

                ctx.restore()
            }

            // Ring 1 stars
            drawDiamond(root.ring1Angle,       92, 28, 3.5, "#FEFBD0")
            drawDiamond(root.ring1Angle + 120, 92, 28, 2.5, "#D8DEE9")
            drawDiamond(root.ring1Angle + 240, 92, 28, 3.0, "#AFC5DA")

            // Ring 2 stars
            drawDiamond(root.ring2Angle,       70, 21, 3.0, "#B48EAD")
            drawDiamond(root.ring2Angle + 180, 70, 21, 2.5, "#FEFBD0")

            // Ring 3 stars
            drawDiamond(root.ring3Angle,       50, 15, 2.5, "#FAFF99")
            drawDiamond(root.ring3Angle + 180, 50, 15, 2.0, "#D8DEE9")

            // ── Static corner data readouts ───────────────────────
            ctx.font = (8 * sc) + "px 'JetBrains Mono', monospace"
            ctx.fillStyle = "#AFC5DA"
            ctx.globalAlpha = 0.4
            var labels = [
                { text: "SYS:OK",   x: cx - 90 * sc, y: cy - 80 * sc },
                { text: "SYNC:98%", x: cx + 52 * sc, y: cy - 80 * sc },
                { text: "AUTH:ON",  x: cx - 90 * sc, y: cy + 88 * sc },
                { text: "ORB:03",   x: cx + 52 * sc, y: cy + 88 * sc },
            ]
            labels.forEach(function(l) {
                ctx.fillText(l.text, l.x, l.y)
            })
            ctx.globalAlpha = 1.0
        }
    }
}
