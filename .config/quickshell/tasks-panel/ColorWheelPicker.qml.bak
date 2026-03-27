import QtQuick
import "../theme"

// ColorWheelPicker.qml
// Emits: colorSelected(hexString)
// Usage:
//   ColorWheelPicker {
//       visible: showPicker
//       currentColor: "#4C98D1"
//       onColorPicked: { myColor = hex; showPicker = false }
//   }

Item {
    id: picker
    implicitWidth:  210
    implicitHeight: 215

    signal colorPicked(string hex)

    property string currentColor: "#9B94C4"

    // Internal HSV state
    property real  _hue:  0.6
    property real  _sat:  0.7
    property real  _val:  0.9

    // Derive from currentColor on first show
    Component.onCompleted: _fromHex(currentColor)
    onCurrentColorChanged: _fromHex(currentColor)

    // ── HSV ↔ RGB helpers ─────────────────────────────────────

    function _fromHex(hex) {
        if (!hex || hex.length < 7) return
        var r = parseInt(hex.substring(1,3),16) / 255
        var g = parseInt(hex.substring(3,5),16) / 255
        var b = parseInt(hex.substring(5,7),16) / 255
        var mx = Math.max(r,g,b), mn = Math.min(r,g,b), d = mx - mn
        var h = 0, s = mx === 0 ? 0 : d/mx, v = mx
        if (d > 0) {
            if      (mx === r) h = ((g - b) / d + (g < b ? 6 : 0)) / 6
            else if (mx === g) h = ((b - r) / d + 2) / 6
            else               h = ((r - g) / d + 4) / 6
        }
        _hue = h; _sat = s; _val = v
    }

    function _hsvToHex(h, s, v) {
        var r, g, b
        var i = Math.floor(h * 6)
        var f = h * 6 - i
        var p = v * (1 - s)
        var q = v * (1 - f * s)
        var t = v * (1 - (1 - f) * s)
        switch (i % 6) {
            case 0: r=v; g=t; b=p; break
            case 1: r=q; g=v; b=p; break
            case 2: r=p; g=v; b=t; break
            case 3: r=p; g=q; b=v; break
            case 4: r=t; g=p; b=v; break
            default:r=v; g=p; b=q; break
        }
        function h2(n) { var s = Math.round(n*255).toString(16); return s.length===1 ? "0"+s : s }
        return "#" + h2(r) + h2(g) + h2(b)
    }

    property string _previewHex: _hsvToHex(_hue, _sat, _val)

    // ── Wheel ─────────────────────────────────────────────────
    readonly property int wheelSize: 160
    readonly property int wheelR:    wheelSize / 2
    readonly property real innerR:   wheelR * 0.35   // hole radius

    Item {
        id: wheelArea
        anchors.horizontalCenter: parent.horizontalCenter
        width: picker.wheelSize; height: picker.wheelSize

        Canvas {
            id: wheelCanvas
            anchors.fill: parent
            Component.onCompleted: requestPaint()
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var cx = width/2, cy = height/2
                var outerR = cx - 2
                var steps  = 360

                for (var deg = 0; deg < steps; deg++) {
                    var startA = (deg - 0.5) * Math.PI / 180
                    var endA   = (deg + 1.5) * Math.PI / 180
                    var h      = deg / 360

                    // Gradient from white-center to full-hue outer
                    var grad = ctx.createRadialGradient(cx, cy, picker.innerR, cx, cy, outerR)
                    grad.addColorStop(0, "white")
                    grad.addColorStop(1, picker._hsvToHex(h, 1, 1))

                    ctx.beginPath()
                    ctx.moveTo(cx, cy)
                    ctx.arc(cx, cy, outerR, startA, endA)
                    ctx.closePath()
                    ctx.fillStyle = grad
                    ctx.fill()
                }

                // Dark overlay for value (brightness)
                var vGrad = ctx.createRadialGradient(cx, cy, picker.innerR, cx, cy, outerR)
                vGrad.addColorStop(0, Qt.rgba(0,0,0,0))
                vGrad.addColorStop(1, Qt.rgba(0,0,0, 1 - picker._val))
                ctx.beginPath()
                ctx.arc(cx, cy, outerR, 0, Math.PI*2)
                ctx.fillStyle = vGrad
                ctx.fill()

                // Punch out hole
                ctx.globalCompositeOperation = "destination-out"
                ctx.beginPath()
                ctx.arc(cx, cy, picker.innerR - 1, 0, Math.PI*2)
                ctx.fillStyle = "black"
                ctx.fill()
                ctx.globalCompositeOperation = "source-over"
            }
        }

        // Crosshair indicator on the wheel
        Item {
            id: crosshair
            x: {
                var cx = wheelR
                var r  = (wheelR - 4) * picker._sat + picker.innerR * (1 - picker._sat)
                return cx + r * Math.cos(picker._hue * 2 * Math.PI) - 6
            }
            y: {
                var cy = wheelR
                var r  = (wheelR - 4) * picker._sat + picker.innerR * (1 - picker._sat)
                return cy + r * Math.sin(picker._hue * 2 * Math.PI) - 6
            }
            width: 12; height: 12

            Rectangle {
                anchors.centerIn: parent
                width: 10; height: 10; radius: 5
                color: "transparent"
                border.color: "white"; border.width: 2
            }
            Rectangle {
                anchors.centerIn: parent
                width: 6; height: 6; radius: 3
                color: picker._previewHex
            }
        }

        MouseArea {
            anchors.fill: parent
            function pickAt(mx, my) {
                var cx = wheelR, cy = wheelR
                var dx = mx - cx, dy = my - cy
                var dist = Math.sqrt(dx*dx + dy*dy)
                if (dist < picker.innerR || dist > wheelR - 2) return
                picker._hue = ((Math.atan2(dy, dx) / (2 * Math.PI)) + 1) % 1
                picker._sat = Math.min(1, (dist - picker.innerR) / (wheelR - 2 - picker.innerR))
            }
            onPressed:      (mouse) => { pickAt(mouse.x, mouse.y) }
            onPositionChanged: (mouse) => { if (pressed) pickAt(mouse.x, mouse.y) }
        }
    }

    // ── Value (brightness) slider ──────────────────────────────
    Item {
        anchors.top:              wheelArea.bottom
        anchors.topMargin:        8
        anchors.horizontalCenter: parent.horizontalCenter
        width: picker.wheelSize; height: 14

        Canvas {
            id: valCanvas
            anchors.fill: parent
            Component.onCompleted: requestPaint()

            Connections {
                target: picker
                function on_HueChanged() { valCanvas.requestPaint() }
                function on_SatChanged() { valCanvas.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var grad = ctx.createLinearGradient(0, 0, width, 0)
                grad.addColorStop(0, "black")
                grad.addColorStop(1, picker._hsvToHex(picker._hue, picker._sat, 1))
                ctx.beginPath()
                ctx.roundRect ? ctx.roundRect(0, 0, width, height, 7) : ctx.rect(0, 0, width, height)
                ctx.fillStyle = grad
                ctx.fill()
            }
        }

        // Slider thumb
        Rectangle {
            x:      picker._val * (parent.width - 12)
            y:      1
            width:  12; height: 12; radius: 6
            color:  picker._previewHex
            border.color: "white"; border.width: 2
        }

        MouseArea {
            anchors.fill: parent
            onPressed:         (mouse) => { picker._val = Math.max(0, Math.min(1, mouse.x / width)) }
            onPositionChanged: (mouse) => { if (pressed) picker._val = Math.max(0, Math.min(1, mouse.x / width)) }
        }
    }

    // ── Preview swatch + confirm ───────────────────────────────
    Row {
        anchors.top:              parent.top
        anchors.topMargin:        picker.wheelSize + 28
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        // Live preview swatch
        Rectangle {
            width: 32; height: 24; radius: 6
            color: picker._previewHex
            border.color: Qt.rgba(1,1,1,0.2); border.width: 1
        }

        // Hex label
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: picker._previewHex
            color: Theme.textDim
            font { family: Theme.fontFamily; pixelSize: 11 }
        }

        // Confirm button
        Rectangle {
            width: 52; height: 24; radius: 6
            color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.3)
            border.color: Theme.borderActive; border.width: 1
            Text { anchors.centerIn: parent; text: "Use"; color: Theme.textPrimary
                   font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium } }
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: picker.colorPicked(picker._previewHex)
            }
        }
    }
}
