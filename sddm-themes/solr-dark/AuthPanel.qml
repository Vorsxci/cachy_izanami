// =============================================================
// AuthPanel.qml — Password input + action buttons
// Hover glow effects + clickable power/reboot via scripts
// =============================================================

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0
import "palette.js" as P

Item {
    id: root
    height: 640

    property string username:     ""
    property int    sessionIndex: 0
    property bool   authFailed:   false

    function focusPassword() { passwordField.forceActiveFocus() }

    // ── "Authentication" header ───────────────────────────────
    Rectangle {
        id: authHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        radius: 8
        color: P.glass
        border.color: P.border1
        border.width: 1

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 28
            anchors.verticalCenter: parent.verticalCenter
            text: "Authentication"
            color: P.textPrimary
            font.family: P.fontFamily
            font.pixelSize: 28
            font.weight: Font.Medium
        }
    }

    // ── Password row ──────────────────────────────────────────
    Rectangle {
        id: passwordRow
        anchors.top: authHeader.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.right: parent.right
        height: 96
        radius: 8
        color: P.fieldBg
        border.color: passwordField.activeFocus ? P.hoverBorder
                    : root.authFailed            ? P.errorColor
                    : P.border1
        border.width: 1
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // Glow effect on focus
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: 12
            color: "transparent"
            border.color: passwordField.activeFocus ? P.accentGlow : "transparent"
            border.width: 4
            Behavior on border.color { ColorAnimation { duration: 150 } }
        }

        TextInput {
            id: passwordField
            anchors.left: parent.left
            anchors.leftMargin: 28
            anchors.right: submitBtn.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            echoMode: TextInput.Password
            passwordCharacter: "●"
            color: P.textPrimary
            font.family: P.fontFamily
            font.pixelSize: 32
            selectionColor: P.accentGlow
            selectedTextColor: P.textPrimary
            clip: true

            // Placeholder
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: root.authFailed ? "ACCESS DENIED" : ""
                color: P.errorColor
                font.family: P.fontFamily
                font.pixelSize: 28
                font.italic: true
                visible: passwordField.text === "" && root.authFailed
            }

            Keys.onReturnPressed: root.tryLogin()
            Keys.onEnterPressed:  root.tryLogin()
        }

        // Submit arrow button
        Rectangle {
            id: submitBtn
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 72; height: 72
            radius: 8
            color: submitHover.containsMouse ? P.hoverBg : "transparent"
            border.color: submitHover.containsMouse ? P.hoverBorder : P.border1
            border.width: 1
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: "▶"
                color: submitHover.containsMouse ? P.accent : P.textDim
                font.pixelSize: 26
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            MouseArea {
                id: submitHover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.tryLogin()
            }
        }
    }

    // ── Auth fail message ─────────────────────────────────────
    Text {
        id: failMsg
        anchors.top: passwordRow.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 6
        text: "⚠  Authentication failed — try again"
        color: P.errorColor
        font.family: P.fontFamily
        font.pixelSize: 22
        visible: root.authFailed
        opacity: root.authFailed ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    // ── Action buttons ────────────────────────────────────────
    Column {
        anchors.top: passwordRow.bottom
        anchors.topMargin: 80
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 14

        ActionButton {
            width: parent.width
            label: "Power Off"
            onActivated: Qt.openUrlExternally("exec://" + P.scriptPowerOff)
        }

        ActionButton {
            width: parent.width
            label: "Reboot"
            onActivated: Qt.openUrlExternally("exec://" + P.scriptReboot)
        }

        ActionButton {
            width: parent.width
            label: "Suspend"
            onActivated: sddm.suspend()
        }
    }

    // ── Auth logic ────────────────────────────────────────────
    function tryLogin() {
        if (passwordField.text === "") return
        root.authFailed = false
        sddm.login(root.username, passwordField.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.authFailed = true
            passwordField.text = ""
            passwordField.forceActiveFocus()
            failTimer.restart()
        }
    }

    Timer {
        id: failTimer
        interval: 3000
        onTriggered: root.authFailed = false
    }
}
