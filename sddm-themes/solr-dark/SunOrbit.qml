// =============================================================
// SunOrbit.qml — Digital sun with corona rings and solar flares
// Sharp geometric aesthetic — SOLR OS style

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
    property real flareRotate: 0

    // Ring 1 — slow
    NumberAnimation on ring1Angle {
        from: 0; to: 360
        duration: 20000
        loops: Animation.Infinite
        running: true
    }

    // Ring 2 — medium, opposite
    NumberAnimation on ring2Angle {
        from: 360; to: 0
        duration: 13000
        loops: Animation.Infinite
        running: true
    }

    // Ring 3 — fast
    NumberAnimation on ring3Angle {
        from: 0; to: 360
        duration: 8000
        loops: Animation.Infinite
        running: true
    }

    // Glow pulse
    NumberAnimation on glowPulse {
        from: 0; to: Math.PI * 2
        duration: 3500
        loops: Animation.Infinite
        running: true
    }

    // Scan line sweep
    NumberAnimation on scanLine {
        from: 0; to: 1
        duration: 2500
        loops: Animation.Infinite
        running: true
    }

    // Solar spike rotation — slow drift
    NumberAnimation on flareRotate {
        from: 0; to: Math.PI * 2
        duration: 60000
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
        antialiasing: false   // OFF — sharp digital edges

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cx = width  / 2
            var cy = height / 2
            var sc = root.s

            var TILT = 45

            // ── Orbit rings (tilted elliptical, warm colors) ──
            var rings = [
                { rx: 92, ry: 28, color: "#F4A340", dash: [4, 5],  alpha: 0.35 },
                { rx: 70, ry: 21, color: "#FF9898", dash: [6, 4],  alpha: 0.30 },
                { rx: 50, ry: 15, color: "#FF6557", dash: [3, 7],  alpha: 0.25 },
            ]

            // ── Draw orbit rings (behind sun) ─────────────────────
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

            // ── Digital sun body ─────────────────────────────────
            var sunR = 36 * sc

            // ── Outer corona glow — concentric diamond pulses ─────
            var glowSize = (64 + Math.sin(root.glowPulse) * 8) * sc
            var pulseAlpha = 0.08 + Math.sin(root.glowPulse) * 0.03
            ;[1.0, 0.72, 0.48, 0.26].forEach(function(t) {
                var gs = glowSize * t
                ctx.save()
                ctx.globalAlpha = pulseAlpha * (1 - t + 0.25)
                ctx.fillStyle = "#F4A340"
                ctx.beginPath()
                ctx.save()
                ctx.translate(cx, cy)
                ctx.rotate(Math.PI / 4)
                ctx.fillRect(-gs/2, -gs/2, gs, gs)
                ctx.restore()
                ctx.restore()
            })

            // ── Solar spike rays ──────────────────────────────────
            // 8 primary spikes + 8 secondary, slowly rotating
            ctx.save()
            ctx.translate(cx, cy)
            ctx.rotate(root.flareRotate)

            var numSpikes = 8
            var spikeLen  = sunR * 1.35
            var spikeLen2 = sunR * 0.85  // secondary shorter spikes

            for (var sp = 0; sp < numSpikes * 2; sp++) {
                var spikeAngle = (sp / (numSpikes * 2)) * Math.PI * 2
                var isPrimary  = (sp % 2 === 0)
                var len = isPrimary ? spikeLen : spikeLen2
                var tipX = Math.cos(spikeAngle) * (sunR + len)
                var tipY = Math.sin(spikeAngle) * (sunR + len)
                var baseW = isPrimary ? 4 * sc : 2.5 * sc

                var perpX = -Math.sin(spikeAngle) * baseW
                var perpY =  Math.cos(spikeAngle) * baseW
                var baseX = Math.cos(spikeAngle) * (sunR * 0.7)
                var baseY = Math.sin(spikeAngle) * (sunR * 0.7)

                // Spike gradient — hot tip fades out
                var spikeGrad = ctx.createLinearGradient(baseX, baseY, tipX, tipY)
                spikeGrad.addColorStop(0.0, isPrimary ? "rgba(255,220,160,0.70)" : "rgba(244,163,64,0.50)")
                spikeGrad.addColorStop(0.5, isPrimary ? "rgba(255,101, 87,0.35)" : "rgba(255,152,152,0.25)")
                spikeGrad.addColorStop(1.0, "rgba(255,101,87,0.00)")

                ctx.beginPath()
                ctx.moveTo(baseX + perpX, baseY + perpY)
                ctx.lineTo(tipX, tipY)
                ctx.lineTo(baseX - perpX, baseY - perpY)
                ctx.closePath()
                ctx.fillStyle = spikeGrad
                ctx.fill()
            }

            ctx.restore()

            // ── Sun body — hexagonal, like lunar counterpart ──────
            ctx.save()
            ctx.translate(cx, cy)

            var hex = 6
            ctx.beginPath()
            for (var i = 0; i < hex; i++) {
                var hexAngle = (i / hex) * Math.PI * 2 - Math.PI / 6
                var hx = sunR * Math.cos(hexAngle)
                var hy = sunR * Math.sin(hexAngle)
                if (i === 0) ctx.moveTo(hx, hy)
                else ctx.lineTo(hx, hy)
            }
            ctx.closePath()
            ctx.save()
            ctx.clip()

            // Sun fill — hot core gradient
            var sunGrad = ctx.createLinearGradient(-sunR, -sunR, sunR, sunR)
            sunGrad.addColorStop(0.0,  "#FFDCA0")   // peach — hot center
            sunGrad.addColorStop(0.30, "#ffca98")   // pale amber
            sunGrad.addColorStop(0.55, "#F4A340")   // orange
            sunGrad.addColorStop(0.80, "#FF6557")   // redorange
            sunGrad.addColorStop(1.0,  "#FF9898")   // pink edge
            ctx.fillStyle = sunGrad
            ctx.fillRect(-sunR, -sunR, sunR * 2, sunR * 2)

            // Scan line across sun surface
            var scanY = -sunR + root.scanLine * sunR * 2
            ctx.fillStyle = "rgba(255, 220, 160, 0.08)"
            ctx.fillRect(-sunR, scanY - 1.5 * sc, sunR * 2, 3 * sc)

            // Grid lines on sun surface — solar latitude/longitude
            ctx.strokeStyle = "rgba(255, 152, 152, 0.12)"
            ctx.lineWidth = 0.5 * sc
            for (var gx = -sunR; gx <= sunR; gx += 10 * sc) {
                ctx.beginPath()
                ctx.moveTo(gx, -sunR)
                ctx.lineTo(gx, sunR)
                ctx.stroke()
            }
            for (var gy = -sunR; gy <= sunR; gy += 10 * sc) {
                ctx.beginPath()
                ctx.moveTo(-sunR, gy)
                ctx.lineTo(sunR, gy)
                ctx.stroke()
            }

            ctx.restore() // clip

            // ── NO crescent cutout — sun is full ──────────────────
            // (this is the key difference from the moon)

            // Sun border — sharp geometric stroke
            ctx.beginPath()
            for (var k = 0; k < hex; k++) {
                var bAngle = (k / hex) * Math.PI * 2 - Math.PI / 6
                var bx = sunR * Math.cos(bAngle)
                var by = sunR * Math.sin(bAngle)
                if (k === 0) ctx.moveTo(bx, by)
                else ctx.lineTo(bx, by)
            }
            ctx.closePath()
            ctx.strokeStyle = "#FFDCA0"
            ctx.globalAlpha = 0.7
            ctx.lineWidth = 1.0 * sc
            ctx.stroke()
            ctx.globalAlpha = 1.0

            // Corner accent marks on sun body
            ctx.strokeStyle = "#FF6557"
            ctx.globalAlpha = 0.85
            ctx.lineWidth = 1.2 * sc
            var cm = sunR * 0.7
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

            // ── Draw orbiting diamond stars (in front) ────────────
            function drawDiamond(angle, ringRx, ringRy, size, color) {
                var rad  = angle * Math.PI / 180
                var tRad = TILT * Math.PI / 180

                var ex = ringRx * sc * Math.cos(rad)
                var ey = ringRy * sc * Math.sin(rad)

                var rx2 = ex * Math.cos(tRad) - ey * Math.sin(tRad)
                var ry2 = ex * Math.sin(tRad) + ey * Math.cos(tRad)

                var sx = cx + rx2
                var sy = cy + ry2

                var depthAlpha = 0.35 + 0.65 * ((ry2 / (ringRy * sc) + 1) / 2)

                var ps = size * sc
                ctx.save()
                ctx.globalAlpha = depthAlpha
                ctx.translate(sx, sy)
                ctx.rotate(Math.PI / 4)

                ctx.beginPath()
                ctx.moveTo(0,   -ps)
                ctx.lineTo(ps,   0)
                ctx.lineTo(0,    ps)
                ctx.lineTo(-ps,  0)
                ctx.closePath()
                ctx.fillStyle = color
                ctx.fill()

                ctx.beginPath()
                ctx.arc(0, 0, ps * 0.25, 0, Math.PI * 2)
                ctx.fillStyle = "#FFFFFF"
                ctx.globalAlpha = depthAlpha * 0.8
                ctx.fill()

                ctx.restore()
            }

            // Ring 1 stars — warm amber/orange
            drawDiamond(root.ring1Angle,       92, 28, 3.5, "#FFDCA0")
            drawDiamond(root.ring1Angle + 120, 92, 28, 2.5, "#ffca98")
            drawDiamond(root.ring1Angle + 240, 92, 28, 3.0, "#F4A340")

            // Ring 2 stars — orange/pink
            drawDiamond(root.ring2Angle,       70, 21, 3.0, "#FF9898")
            drawDiamond(root.ring2Angle + 180, 70, 21, 2.5, "#FFDCA0")

            // Ring 3 stars — solar flare red
            drawDiamond(root.ring3Angle,       50, 15, 2.5, "#FF6557")
            drawDiamond(root.ring3Angle + 180, 50, 15, 2.0, "#F4A340")

            // ── Static corner data readouts ───────────────────────
            ctx.font = (8 * sc) + "px 'JetBrains Mono', monospace"
            ctx.fillStyle = "#FF9898"
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
