// =============================================================
// DissolveEffect.qml — Pixel dissolve on login success
// Overlays the entire screen and animates a GLSL dissolve
// Trigger by calling dissolve()
// =============================================================

import QtQuick 2.15

Item {
    id: root
    anchors.fill: parent
    visible: false
    z: 9999

    // Call this when login succeeds
    function dissolve() {
        root.visible = true
        dissolveAnim.restart()
    }

    // Noise texture — generated procedurally via Canvas
    Canvas {
        id: noiseCanvas
        width: 512
        height: 512
        visible: false

        onPaint: {
            var ctx = getContext("2d")
            var imageData = ctx.createImageData(width, height)
            var data = imageData.data
            for (var i = 0; i < data.length; i += 4) {
                var val = Math.random() * 255
                data[i]     = val
                data[i + 1] = val
                data[i + 2] = val
                data[i + 3] = 255
            }
            ctx.putImageData(imageData, 0, 0)
        }

        Component.onCompleted: requestPaint()
    }

    // Screenshot-like source of the whole screen
    ShaderEffectSource {
        id: screenCapture
        sourceItem: root.parent
        anchors.fill: parent
        visible: false
        live: false  // frozen snapshot — captured at dissolve() call
    }

    // The actual dissolve shader
    ShaderEffect {
        id: shader
        anchors.fill: parent
        visible: root.visible

        property variant src:       screenCapture
        property variant noiseTex:  noiseCanvas
        property real    threshold: 0.0      // animated 0.0 → 1.0
        property real    edgeWidth: 0.04     // glow edge thickness
        property color   edgeColor: "#FF6557" // accent gold glow

        // Pixel block size for the blocky dissolve feel
        property real blockSize: 6.0         // pixels per block

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D src;
            uniform sampler2D noiseTex;
            uniform highp float threshold;
            uniform highp float edgeWidth;
            uniform highp vec4  edgeColor;
            uniform highp float blockSize;
            uniform highp float qt_Opacity;
            uniform highp vec2  qt_MultiplyAlpha;

            void main() {
                // Snap to block grid for pixelated dissolve
                highp vec2 blockCoord = floor(qt_TexCoord0 * (1.0 / blockSize) * 512.0) / (512.0 / blockSize);
                highp float noise = texture2D(noiseTex, blockCoord).r;

                highp vec4 color = texture2D(src, qt_TexCoord0);

                if (noise < threshold - edgeWidth) {
                    // Fully dissolved — transparent
                    gl_FragColor = vec4(0.0);
                } else if (noise < threshold) {
                    // Edge glow band
                    highp float t = (noise - (threshold - edgeWidth)) / edgeWidth;
                    gl_FragColor = mix(vec4(0.0), edgeColor, t) * qt_Opacity;
                } else {
                    // Still visible
                    gl_FragColor = color * qt_Opacity;
                }
            }
        "

        // Dissolve animation — runs over 1.4 seconds
        NumberAnimation {
            id: dissolveAnim
            target: shader
            property: "threshold"
            from: 0.0
            to: 1.1
            duration: 1400
            easing.type: Easing.InCubic
        }
    }

    // Flash of white light at the very start — like a shockwave
    Rectangle {
        id: flashOverlay
        anchors.fill: parent
        color: "white"
        opacity: 0.0

        SequentialAnimation {
            id: flashAnim
            running: false
            NumberAnimation { target: flashOverlay; property: "opacity"; from: 0.0; to: 0.35; duration: 80 }
            NumberAnimation { target: flashOverlay; property: "opacity"; from: 0.35; to: 0.0; duration: 220 }
        }
    }

    // Trigger flash alongside dissolve
    onVisibleChanged: {
        if (visible) {
            screenCapture.scheduleUpdate()
            flashAnim.restart()
        }
    }
}
