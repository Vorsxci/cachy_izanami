pragma Singleton
import QtQuick

QtObject {
    // ── Palette ──────────────────────────────────────────────
    readonly property color foreground:    "#D8DEE9"
    readonly property color background:    "#2E3440"
    readonly property color textPrimary:   "#FEFBD0"
    readonly property color textDim:       "#8A90A0"
    readonly property color accent:        "#FAFF99"
    readonly property color mutedblue:     "#AFC5DA"
    readonly property color lilac:         "#B48EAD"
    readonly property color violet:        "#605A80"
    readonly property color violetMid:     "#7A7298"
    readonly property color violetBright:  "#9B94C4"

    readonly property color glass:       Qt.rgba(0.180, 0.204, 0.251, 0.78)
    readonly property color glassViolet: Qt.rgba(0.235, 0.212, 0.345, 0.82)
    readonly property color glassDeep:   Qt.rgba(0.164, 0.168, 0.239, 0.92)

    readonly property color borderIdle:   Qt.rgba(0.376, 0.353, 0.502, 0.50)
    readonly property color borderHover:  Qt.rgba(0.996, 0.984, 0.816, 0.80)
    readonly property color borderActive: Qt.rgba(0.608, 0.580, 0.769, 0.80)
    readonly property color borderAccent: Qt.rgba(0.980, 1.000, 0.600, 0.40)

    // ── Typography ───────────────────────────────────────────
    readonly property string fontFamily: "CaskaydiaCove Nerd Font"
    readonly property string fontMono:   "CaskaydiaMono Nerd Font"
    readonly property int    fontSize:   14

    // ── Geometry ─────────────────────────────────────────────
    readonly property int barHeight:    42
    readonly property int pillMarginV:   5
    readonly property int pillMarginH:  10
    readonly property int pillPadding:   6
    readonly property int chipPadding:   6
    readonly property int chipSpacing:   0
}
