import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../../../theme"

// WindowTitleModule — lives in bar/modules/left/
Item {
    implicitHeight: Theme.barHeight
    implicitWidth:  row.implicitWidth + 16

    property string windowTitle: ""
    property string windowClass: ""

    Process {
        id: activeWinProc
        command: ["hyprctl", "activewindow", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j       = JSON.parse(text.trim())
                    windowTitle   = j.title ?? ""
                    windowClass   = j.class  ?? ""
                } catch(e) {
                    windowTitle = ""
                    windowClass = ""
                }
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            const n = event.name
            if (n === "activewindow" || n === "activewindowv2"
                    || n === "focusedmon" || n === "closewindow"
                    || n === "openwindow")
                activeWinProc.running = true
        }
    }

    // Formatted title text
    readonly property int maxTitleChars: 20
    function truncate(s) {
        return s.length > maxTitleChars ? s.substring(0, maxTitleChars) + "…" : s
    }
    property string displayTitle: {
        const t = windowTitle
        if (!t || t === "") return "Desktop"
        if (/- YouTube/.test(t))  return "YouTube"
        if (/- nvim$/.test(t))    return truncate(t.replace(/ - nvim$/, ""))
        if (/^nvim/.test(t))      return truncate(t)
        if (/- kitty$/.test(t))   return truncate(t.replace(/ - kitty$/, ""))
        return truncate(t)
    }

    // Icon path — try class name directly, fall back to empty string (no broken square)
    property string iconPath: windowClass !== ""
        ? Quickshell.iconPath(windowClass, "")
        : ""

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        x: 10
        spacing: 6

        // App icon
        Image {
            visible:          iconPath !== "" && status === Image.Ready
            source:           iconPath
            Layout.preferredWidth:  16
            Layout.preferredHeight: 16
            fillMode:         Image.PreserveAspectFit
            smooth:           true
            Layout.alignment: Qt.AlignVCenter
        }

        // Title text
        Text {
            text:  displayTitle
            color: Theme.textDim
            font {
                family:    Theme.fontFamily
                pixelSize: Theme.fontSize
                italic:    true
            }
            maximumLineCount: 1
            elide:            Text.ElideRight
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
