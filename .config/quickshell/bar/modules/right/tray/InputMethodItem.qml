import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../../../theme"

// InputMethodItem.qml — lives in bar/modules/right/tray/
RowLayout {
    spacing: 8

    property string currentIm:  "keyboard-us"
    property bool   isJapanese: currentIm === "mozc"

    Process {
        id: imProc
        command: ["fcitx5-remote", "-n"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: currentIm = text.trim()
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: imProc.running = true
    }

    // IM block indicator
    Rectangle {
        width:  24; height: 18
        radius: 3
        color:        isJapanese ? Theme.lilac    : Theme.violetMid
        border.color: isJapanese ? Theme.violetBright : Theme.borderIdle
        border.width: 1
        Layout.alignment: Qt.AlignVCenter

        Text {
            anchors.centerIn: parent
            text:  isJapanese ? "あ" : "A"
            color: Theme.textPrimary
            font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium }
        }

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    // Label
    Text {
        text:  isJapanese ? "Japanese (Mozc)" : "English (US)"
        color: Theme.foreground
        font { family: Theme.fontFamily; pixelSize: 12 }
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
    }

    // Toggle button
    Rectangle {
        width: 36; height: 18
        radius: 9
        color:  isJapanese ? Theme.glassViolet : Theme.violet
        border.color: isJapanese ? Theme.violetBright : Theme.borderIdle
        border.width: 1
        Layout.alignment: Qt.AlignVCenter

        Text {
            anchors.centerIn: parent
            text:  isJapanese ? "JP" : "EN"
            color: isJapanese ? Theme.accent : Theme.textDim
            font { family: Theme.fontFamily; pixelSize: 10 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                const next = isJapanese ? "keyboard-us" : "mozc"
                Quickshell.execDetached(["fcitx5-remote", "-s", next])
                currentIm = next
            }
        }

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
