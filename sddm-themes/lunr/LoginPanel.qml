// =============================================================
// LoginPanel.qml — Left panel: username input + session picker
// Uses SDDM's native ComboBox + TextBox from SddmComponents 2.0
// =============================================================

import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0
import "palette.js" as P

Item {
    id: root
    height: 760

    property alias selectedUser:         usernameBox.text
    property alias selectedSessionIndex: sessionBox.index

    // ── "LOGIN" heading ───────────────────────────────────────
    Text {
        id: heading
        text: "LOGIN"
        color: P.textPrimary
        font.family: P.fontFamily
        font.pixelSize: 72
        font.weight: Font.Medium
        anchors.top: parent.top
        anchors.left: parent.left
    }

    // ── Dotted separator ──────────────────────────────────────
    Row {
        id: separator
        anchors.top: heading.bottom
        anchors.topMargin: 14
        anchors.left: parent.left
        spacing: 6
        Repeater {
            model: 52
            Rectangle { width: 6; height: 6; radius: 3; color: P.textDim; opacity: 0.5 }
        }
    }

    // ── USERNAME label ────────────────────────────────────────
    Text {
        id: userLabel
        anchors.top: separator.bottom
        anchors.topMargin: 36
        anchors.left: parent.left
        text: "USER"
        color: P.textDim
        font.family: P.fontFamily
        font.pixelSize: 22
        font.letterSpacing: 4
    }

    // ── Username input ────────────────────────────────────────
    TextBox {
        id: usernameBox
        anchors.top: userLabel.bottom
        anchors.topMargin: 14
        text: "kazuki"
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80

        color:       P.fieldBg
        borderColor: P.border1
        focusColor:  P.hoverBorder
        hoverColor:  P.glassBright
        textColor:   P.textPrimary

        font.family:    P.fontFamily
        font.pixelSize: 30

        KeyNavigation.tab: sessionBox
    }

    // ── SESSION label ─────────────────────────────────────────
    Text {
        id: sessionLabel
        anchors.top: usernameBox.bottom
        anchors.topMargin: 40
        anchors.left: parent.left
        text: "SESSION"
        color: P.textDim
        font.family: P.fontFamily
        font.pixelSize: 22
        font.letterSpacing: 4
    }

    // ── Session picker ────────────────────────────────────────
    ComboBox {
        id: sessionBox
        anchors.top: sessionLabel.bottom
        anchors.topMargin: 14
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80

        model: sessionModel
        index: sessionModel.lastIndex

        color:       P.fieldBg
        borderColor: P.border1
        focusColor:  P.hoverBorder
        hoverColor:  P.glassBright
        menuColor:   P.panelBg
        textColor:   P.textPrimary

        font.family:    P.fontFamily
        font.pixelSize: 28

        KeyNavigation.tab: usernameBox
    }
}
