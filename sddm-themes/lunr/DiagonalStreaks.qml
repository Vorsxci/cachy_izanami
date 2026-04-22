// =============================================================
// DiagonalStreaks.qml — Slow parallel light rays at one angle
// Randomized timing so pulses feel organic and independent
// =============================================================

import QtQuick 2.15

Item {
    id: root
    anchors.fill: parent

    component Streak : Canvas {
        anchors.fill: parent
        antialiasing: true

        property real  startX:   0.0
        property real  startY:   0.0
        property real  endX:     1.0
        property real  endY:     1.0
        property color clr:      "#FEFBD0"
        property real  pw:       1.0
        property int   minDur:   14000   // min travel time ms
        property int   maxDur:   26000   // max travel time ms
        property int   dur:      18000   // current travel time (randomized each cycle)
        property int   minGap:   1000
        property int   maxGap:   7000
        property int   delay:    0

        // Pulse half-length — randomized each cycle (fraction of line)
        property real  halfLen:     0.08    // current half-length
        property real  minHalf:  0.04    // short sharp streak
        property real  maxHalf:  0.18    // long sweeping streak

        property real progress:   -0.1
        property real bloomPulse:  0.0

        SequentialAnimation on progress {
            id: pulseAnim
            loops: Animation.Infinite
            running: true

            PauseAnimation  { duration: delay }

            NumberAnimation {
                id: travelAnim
                from: -0.1; to: 1.1
                duration: dur
                easing.type: Easing.InOutQuad
            }

            ScriptAction {
                script: {
                    // Randomize gap, speed, and pulse length each cycle
                    gapPause.duration  = minGap + Math.floor(Math.random() * (maxGap - minGap))
                    dur  = minDur + Math.floor(Math.random() * (maxDur - minDur))
                    halfLen = minHalf + Math.random() * (maxHalf - minHalf)
                }
            }

            PauseAnimation { id: gapPause; duration: 4000 }
        }

        SequentialAnimation on bloomPulse {
            loops: Animation.Infinite
            running: true
            PauseAnimation  { duration: delay * 0.7 }
            NumberAnimation { from: 0.0; to: 1.0; duration: dur * 0.4; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1.0; to: 0.0; duration: dur * 0.6; easing.type: Easing.InOutSine }
            PauseAnimation  { duration: gapPause.duration * 0.8 }
        }

        onProgressChanged:   requestPaint()
        onBloomPulseChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var W  = width
            var H  = height
            var ax = startX * W
            var ay = startY * H
            var bx = endX   * W
            var by = endY   * H
            var dx = bx - ax
            var dy = by - ay

            var half = halfLen   // randomized each cycle
            var t0   = Math.max(0.0, progress - half)
            var t1   = Math.min(1.0, progress + half)
            if (t1 <= 0.0 || t0 >= 1.0) return

            var sx0 = ax + dx * t0;  var sy0 = ay + dy * t0
            var sx1 = ax + dx * t1;  var sy1 = ay + dy * t1

            // Layer 1 — wide diffuse bloom
            ctx.beginPath()
            ctx.moveTo(sx0, sy0)
            ctx.lineTo(sx1, sy1)
            ctx.strokeStyle = Qt.rgba(clr.r, clr.g, clr.b, 0.05 + bloomPulse * 0.04)
            ctx.lineWidth   = pw * 32
            ctx.lineCap     = "round"
            ctx.stroke()

            // Layer 2 — soft glow
            ctx.beginPath()
            ctx.moveTo(sx0, sy0)
            ctx.lineTo(sx1, sy1)
            ctx.strokeStyle = Qt.rgba(clr.r, clr.g, clr.b, 0.15)
            ctx.lineWidth   = pw * 12
            ctx.stroke()

            // Layer 3 — inner glow
            ctx.beginPath()
            ctx.moveTo(sx0, sy0)
            ctx.lineTo(sx1, sy1)
            ctx.strokeStyle = Qt.rgba(clr.r, clr.g, clr.b, 0.36)
            ctx.lineWidth   = pw * 4
            ctx.stroke()

            // Layer 4 — sharp core
            ctx.beginPath()
            ctx.moveTo(sx0, sy0)
            ctx.lineTo(sx1, sy1)
            ctx.strokeStyle = Qt.rgba(clr.r, clr.g, clr.b, 0.90)
            ctx.lineWidth   = pw
            ctx.stroke()

            // Leading spark
            var leadT = Math.min(progress + half * 0.7, 1.0)
            var lx    = ax + dx * leadT
            var ly    = ay + dy * leadT

            ctx.beginPath()
            ctx.arc(lx, ly, pw * 8, 0, Math.PI * 2)
            ctx.fillStyle = Qt.rgba(clr.r, clr.g, clr.b, 0.10)
            ctx.fill()

            ctx.beginPath()
            ctx.arc(lx, ly, pw * 3, 0, Math.PI * 2)
            ctx.fillStyle = Qt.rgba(clr.r, clr.g, clr.b, 0.45)
            ctx.fill()

            ctx.beginPath()
            ctx.arc(lx, ly, pw * 1.2, 0, Math.PI * 2)
            ctx.fillStyle = "rgba(255,255,255,0.95)"
            ctx.fill()

            // Trailing fade
            var trailT0 = Math.max(0.0, progress - half * 2.2)
            var trailT1 = Math.max(0.0, progress - half)
            if (trailT1 > trailT0) {
                var tx0 = ax + dx * trailT0; var ty0 = ay + dy * trailT0
                var tx1 = ax + dx * trailT1; var ty1 = ay + dy * trailT1
                ctx.beginPath()
                ctx.moveTo(tx0, ty0)
                ctx.lineTo(tx1, ty1)
                ctx.strokeStyle = Qt.rgba(clr.r, clr.g, clr.b, 0.07)
                ctx.lineWidth   = pw * 2
                ctx.lineCap     = "round"
                ctx.stroke()
            }
        }
    }

    // ── Streak instances ──────────────────────────────────────
    // speed: minDur/maxDur ms — higher = slower
    // length: minHalf/maxHalf — default range 0.04–0.18

    // Left-edge origins
    Streak { startX:-0.107; startY:-0.083; endX:0.870; endY:1.133; clr:"#FEFBD0"; pw:1.4; minDur:2000; maxDur:15000; minGap:1000; maxGap:6000;  delay:0     }
    Streak { startX:-0.107; startY: 0.067; endX:0.749; endY:1.133; clr:"#D8DEE9"; pw:0.7; minDur:2000; maxDur:15000; minGap:500;  maxGap:7000;  delay:2100  }
    Streak { startX:-0.107; startY: 0.247; endX:0.605; endY:1.133; clr:"#FEFBD0"; pw:1.8; minDur:2000; maxDur:15000; minGap:2000; maxGap:5000;  delay:4800  }
    Streak { startX:-0.107; startY: 0.417; endX:0.468; endY:1.133; clr:"#AFC5DA"; pw:0.6; minDur:2000; maxDur:15000; minGap:1000; maxGap:8000;  delay:1300  }
    Streak { startX:-0.107; startY: 0.587; endX:0.332; endY:1.133; clr:"#B48EAD"; pw:0.9; minDur:2000; maxDur:15000; minGap:1500; maxGap:6500;  delay:7200  }
    Streak { startX:-0.107; startY: 0.747; endX:0.203; endY:1.133; clr:"#D8DEE9"; pw:0.5; minDur:2000; maxDur:15000; minGap:800;  maxGap:5500;  delay:3600  }

    // Top-edge origins
    Streak { startX: 0.073; startY:-0.133; endX:1.090; endY:1.133; clr:"#FAFF99"; pw:0.8; minDur:2000; maxDur:15000; minGap:1200; maxGap:7000;  delay:900   }
    Streak { startX: 0.313; startY:-0.133; endX:1.107; endY:0.855; clr:"#FEFBD0"; pw:1.2; minDur:2000; maxDur:15000; minGap:600;  maxGap:6000;  delay:5500  }
    Streak { startX: 0.573; startY:-0.133; endX:1.107; endY:0.531; clr:"#D8DEE9"; pw:0.6; minDur:2000; maxDur:15000; minGap:1500; maxGap:5000;  delay:2900  }
}
