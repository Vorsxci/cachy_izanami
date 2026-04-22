// =============================================================
// MissionPanel.qml — Bottom-left mission status panel
// Reads ~/to-do.txt and populates objective lines
// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    id: root
    height: col.implicitHeight

    property string todoText:     ""
    property string locationText: "CACHY-OS [SECTOR 0-1]"

    Timer {
        interval: 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: loadTodo()
    }

    function loadTodo() {
        // Try ~/to-do.txt first, then ~/.todo
        var paths = [
            "file:///home/kazuki/to-do.txt",
            "file:///home/kazuki/.todo",
            "file:///home/kazuki/TODO"
        ]
        tryNext(paths, 0)
    }

    function tryNext(paths, i) {
        if (i >= paths.length) {
            root.todoText = "No active objectives."
            return
        }
        var xhr = new XMLHttpRequest()
        xhr.open("GET", paths[i], true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var text = xhr.responseText.trim()
                if (text !== "") {
                    root.todoText = text
                } else {
                    tryNext(paths, i + 1)
                }
            }
        }
        xhr.send()
    }

    Column {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 18

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: P.border1
        }

        Text {
            text: "CURRENT LOCATION: " + root.locationText
            color: P.textDim
            font.family: P.fontFamily
            font.pixelSize: 22
            font.letterSpacing: 1
        }

        Text {
            text: "MISSION STATUS: <font color='" + P.accent + "'>ACTIVE</font>"
            color: P.textPrimary
            font.family: P.fontFamily
            font.pixelSize: 28
            font.weight: Font.Medium
            textFormat: Text.RichText
        }

        Text {
            text: "Objective:"
            color: P.textDim
            font.family: P.fontFamily
            font.pixelSize: 22
            font.letterSpacing: 1
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10

            Repeater {
                model: root.todoText !== ""
                     ? root.todoText.split("\n").slice(0, 6)
                     : ["No active objectives."]

                Row {
                    spacing: 16
                    anchors.left: parent ? parent.left : undefined
                    anchors.right: parent ? parent.right : undefined

                    Text {
                        text: modelData.startsWith("x ") || modelData.startsWith("✓") ? "◆" : "◇"
                        color: modelData.startsWith("x ") || modelData.startsWith("✓")
                             ? P.textDim : P.accent
                        font.pixelSize: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        width: root.width - 40
                        text: modelData.replace(/^x /, "").replace(/^✓\s*/, "")
                        color: modelData.startsWith("x ") || modelData.startsWith("✓")
                             ? P.textDim : P.textPrimary
                        font.family: P.fontFamily
                        font.pixelSize: 24
                        font.strikeout: modelData.startsWith("x ")
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        Text {
            text: "SYSTEM SYNCHRONIZATION: OPERATIONAL"
            color: P.textDim
            font.family: P.fontFamily
            font.pixelSize: 20
            font.letterSpacing: 2
        }

        Text {
            text: "POD 042 / 153  SYNC: 98.4%"
            color: P.accent
            font.family: P.fontFamily
            font.pixelSize: 28
            font.weight: Font.Medium
        }
    }
}
