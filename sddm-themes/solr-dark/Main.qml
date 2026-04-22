// =============================================================
// Main.qml — SOLR OS SDDM Theme
// Layout: Solar / SOLR aesthetic
// =============================================================

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0
import "palette.js" as P

Item {
    id: root
    width: 1920
    height: 1080

    // ── Background ────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#0D0F18"

        Image {
            anchors.fill: parent
            source: P.backgroundImage
            fillMode: Image.PreserveAspectCrop
            opacity: 1.0
            smooth: true
        }
    }

    // ── Diagonal animated streaks ────────────────────────────
    DiagonalStreaks {}

    // ── Corner moon reticle — top left ───────────────────────
    CornerSun {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 30
        anchors.leftMargin: 30
        width: 420
        height: 420
    }

    // ── Dot border top ────────────────────────────────────────
    DotBorder {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    // ── Dot border bottom ─────────────────────────────────────
    DotBorder {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        flipped: true
    }

    // ── SYSTEM ACCESS vertical label ─────────────────────────
    SideLabel {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    // ── Corner accents ────────────────────────────────────────
    CornerAccents {}

    // ── LEFT PANEL — Login ────────────────────────────────────
    LoginPanel {
        id: loginPanel
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenter: parent.verticalCenter
        width: 520
    }

    // ── CENTER — Clock ────────────────────────────────────────
    ClockPanel {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -40
    }

    // ── TOP RIGHT — Status widgets ────────────────────────────
    StatusPanel {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 80
        width: 520
    }

    // ── BOTTOM RIGHT — Auth + power ───────────────────────────
    AuthPanel {
        id: authPanel
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 120
        anchors.rightMargin: 80
        width: 520
        username:     loginPanel.selectedUser
        sessionIndex: loginPanel.selectedSessionIndex
    }

    // ── BOTTOM LEFT — Mission / To-Do ─────────────────────────
    MissionPanel {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: 54
        anchors.leftMargin: 80
        width: 520
    }

    // ── Dissolve effect overlay ───────────────────────────────
    DissolveEffect {
        id: dissolve
    }

    // ── SDDM signals ──────────────────────────────────────────
    Connections {
        target: sddm

        function onLoginSucceeded() {
            dissolve.dissolve()
        }

        function onLoginFailed() {
            // AuthPanel handles its own fail state
        }
    }

    // ── Global keyboard focus ─────────────────────────────────
    Component.onCompleted: authPanel.focusPassword()
}
