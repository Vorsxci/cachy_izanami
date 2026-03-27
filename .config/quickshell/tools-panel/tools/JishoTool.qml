import QtQuick
import Quickshell.Io
import "../../theme"

// JishoTool.qml
// EN <-> JP dictionary powered by jisho.org public API.
// Loaded by ToolsPanel into the content pane when active.
//
// To create a new tool, copy this file, rename it, and:
//   - Change toolLabel and toolColor
//   - Replace the content inside the Rectangle with your tool's UI
//   - Register it in ToolsPanel.qml (toolDefs + Component + qmldir)

Item {
    id: tool

    // -- Tool identity (read by ToolsPanel for the bubble) --------------------
    readonly property string toolLabel:   "\u8F9E"
    readonly property color  toolColor:   Theme.lilac
    readonly property string toolTooltip: "Dictionary"

    // -- Injected by ToolsPanel -----------------------------------------------
    property bool toolActive: false
    property int  toolIndex:  -1

    // -- Local state ----------------------------------------------------------
    property string query:       ""
    property var    results:     []
    property bool   loading:     false
    property string errorMsg:    ""
    property int    activeSense: 0

    onToolActiveChanged: {
        if (toolActive) {
            focusTimer.restart()
        } else {
            searchInput.text = ""
            query        = ""
            results      = []
            errorMsg     = ""
            loading      = false
            activeSense  = 0
        }
    }

    Timer { id: focusTimer; interval: 80; onTriggered: searchInput.forceActiveFocus() }

    Timer {
        id: debounce
        interval: 450
        onTriggered: {
            var q = tool.query.trim()
            if (q.length === 0) { tool.results = []; tool.errorMsg = ""; return }
            tool.fetch(q)
        }
    }

    Process {
        id: fetchProc
        running: false
        command: []
        onRunningChanged: {
            if (!running) { tool.loading = false; resultFile.reload() }
        }
    }

    FileView {
        id: resultFile
        path: "/tmp/jisho_result.json"
        onTextChanged: {
            var raw = resultFile.text()
            if (raw && raw.length > 0) tool.parse(raw)
        }
    }

    function fetch(q) {
        tool.loading     = true
        tool.results     = []
        tool.errorMsg    = ""
        tool.activeSense = 0
        fetchProc.command = [
            "bash", "-c",
            "curl -s --max-time 8 --get --data-urlencode 'keyword=" + q + "' " +
            "'https://jisho.org/api/v1/search/words' > /tmp/jisho_result.json"
        ]
        fetchProc.running = true
    }

    function parse(raw) {
        try {
            var obj  = JSON.parse(raw)
            var data = obj.data || []
            if (data.length === 0) {
                tool.errorMsg = "No results for: " + tool.query
                tool.results  = []
                return
            }
            var out = []
            for (var i = 0; i < Math.min(data.length, 8); i++) {
                var entry    = data[i]
                var kana     = ""
                var kanji    = ""
                var japanese = entry.japanese || []
                if (japanese.length > 0) {
                    kanji = japanese[0].word    || ""
                    kana  = japanese[0].reading || ""
                    if (!kanji) { kanji = kana; kana = "" }
                }
                var altForms = []
                for (var a = 1; a < Math.min(japanese.length, 4); a++) {
                    var w = japanese[a].word || japanese[a].reading || ""
                    if (w && w !== kanji) altForms.push(w)
                }
                var senses = []
                var rawSenses = entry.senses || []
                for (var s = 0; s < rawSenses.length; s++) {
                    var rs   = rawSenses[s]
                    var defs = (rs.english_definitions || []).join("; ")
                    var tags = []
                    var pos  = rs.parts_of_speech || []
                    for (var p = 0; p < pos.length; p++) tags.push(pos[p])
                    var misc = rs.tags || []
                    for (var m = 0; m < misc.length; m++) tags.push(misc[m])
                    senses.push({ defs: defs, tags: tags })
                }
                out.push({
                    kanji:  kanji,
                    kana:   kana,
                    altForms: altForms,
                    senses: senses,
                    jlpt:   (entry.jlpt || []).join(", ").toUpperCase(),
                    common: entry.is_common || false
                })
            }
            tool.results = out
        } catch (e) {
            tool.errorMsg = "Parse error: " + e.message
        }
    }

    // -- UI -------------------------------------------------------------------
    Rectangle {
        anchors.fill: parent
        color:        Theme.glassDeep
        radius:       8
        border.color: Theme.borderIdle
        border.width: 1

        // Lilac accent stripe
        Rectangle {
            anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
            width: 2; radius: 8
            color: Qt.rgba(Theme.lilac.r, Theme.lilac.g, Theme.lilac.b, 0.6)
        }

        Item {
            anchors {
                left:   parent.left;   leftMargin:   14
                right:  parent.right;  rightMargin:  12
                top:    parent.top;    topMargin:    10
                bottom: parent.bottom; bottomMargin: 10
            }

            // Header + search bar
            Column {
                id: topSection
                anchors { left: parent.left; right: parent.right; top: parent.top }
                spacing: 8

                Row {
                    spacing: 6
                    Text {
                        text:  "\u8F9E\u66F8"
                        color: Theme.lilac
                        font { family: Theme.fontFamily; pixelSize: 15; weight: Font.Medium }
                    }
                    Text {
                        text:  "\u00B7"
                        color: Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: 13 }
                    }
                    Text {
                        text:  "EN \u2194 JA"
                        color: Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: 10 }
                    }
                }

                Rectangle {
                    width:  parent.width
                    height: 30
                    radius: 5
                    color:  Qt.rgba(1, 1, 1, 0.05)
                    border.color: searchInput.activeFocus
                        ? Qt.rgba(Theme.lilac.r, Theme.lilac.g, Theme.lilac.b, 0.70)
                        : Theme.borderIdle
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Row {
                        anchors {
                            left: parent.left; leftMargin: 8
                            right: parent.right; rightMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 6

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:  "/"
                            color: Theme.lilac
                            font { family: Theme.fontFamily; pixelSize: 13; weight: Font.Medium }
                        }

                        TextInput {
                            id: searchInput
                            width: parent.width - 20
                            anchors.verticalCenter: parent.verticalCenter
                            color:          Theme.textPrimary
                            selectionColor: Theme.lilac
                            font { family: Theme.fontFamily; pixelSize: 13 }
                            clip: true

                            Text {
                                visible: searchInput.text.length === 0 && !searchInput.activeFocus
                                anchors.fill: parent
                                text:  "search English or Japanese..."
                                color: Theme.textDim
                                font:  searchInput.font
                                verticalAlignment: Text.AlignVCenter
                            }

                            onTextChanged: {
                                tool.query = text
                                debounce.restart()
                            }
                            Keys.onReturnPressed: {
                                debounce.stop()
                                var q = tool.query.trim()
                                if (q.length > 0) tool.fetch(q)
                            }
                        }
                    }
                }
            }

            // Results
            Item {
                anchors {
                    left:   parent.left
                    right:  parent.right
                    top:    topSection.bottom; topMargin: 8
                    bottom: parent.bottom
                }

                Text {
                    anchors.centerIn: parent
                    visible: tool.loading
                    text:    "searching..."
                    color:   Theme.textDim
                    font { family: Theme.fontFamily; pixelSize: 12 }
                }

                Text {
                    anchors.centerIn: parent
                    visible: !tool.loading && tool.errorMsg.length > 0
                    text:    tool.errorMsg
                    color:   Theme.textDim
                    font { family: Theme.fontFamily; pixelSize: 12 }
                    wrapMode: Text.WordWrap
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    visible: !tool.loading && tool.results.length === 0
                             && tool.errorMsg.length === 0
                             && tool.query.length === 0
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:  "\u65E5\u672C\u8A9E"
                        color: Qt.rgba(Theme.lilac.r, Theme.lilac.g, Theme.lilac.b, 0.3)
                        font { family: Theme.fontFamily; pixelSize: 28 }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:  "type to look up a word"
                        color: Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: 11 }
                    }
                }

                ListView {
                    id: resultList
                    anchors.fill: parent
                    visible:  !tool.loading && tool.results.length > 0
                    model:    tool.results
                    spacing:  6
                    clip:     true

                    delegate: Item {
                        id: entryDelegate
                        width:  resultList.width
                        property bool expanded: tool.activeSense === index
                        property var  entry:    modelData
                        height: entryCard.implicitHeight + 2

                        Rectangle {
                            id: entryCard
                            anchors { left: parent.left; right: parent.right }
                            radius: 6
                            color: entryDelegate.expanded
                                ? Qt.rgba(Theme.lilac.r, Theme.lilac.g, Theme.lilac.b, 0.10)
                                : Qt.rgba(1, 1, 1, 0.04)
                            border.color: entryDelegate.expanded
                                ? Qt.rgba(Theme.lilac.r, Theme.lilac.g, Theme.lilac.b, 0.35)
                                : Qt.rgba(1, 1, 1, 0.07)
                            border.width: 1
                            implicitHeight: cardContent.implicitHeight + 16
                            Behavior on color        { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    tool.activeSense = entryDelegate.expanded ? -1 : index
                            }

                            Column {
                                id: cardContent
                                anchors {
                                    left:  parent.left;  leftMargin:  10
                                    right: parent.right; rightMargin: 10
                                    top:   parent.top;   topMargin:   8
                                }
                                spacing: 4

                                Row {
                                    width: parent.width
                                    spacing: 6
                                    Text {
                                        text:  entry.kanji !== "" ? entry.kanji : entry.kana
                                        color: Theme.textPrimary
                                        font { family: Theme.fontFamily; pixelSize: 18; weight: Font.Medium }
                                    }
                                    Text {
                                        visible: entry.kana !== ""
                                        anchors.verticalCenter: parent.verticalCenter
                                        text:  "\u3010" + entry.kana + "\u3011"
                                        color: Theme.mutedblue
                                        font { family: Theme.fontFamily; pixelSize: 12 }
                                    }
                                    Rectangle {
                                        visible: entry.common
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 48; height: 14; radius: 3
                                        color:        Qt.rgba(0.18, 0.55, 0.34, 0.35)
                                        border.color: Qt.rgba(0.18, 0.55, 0.34, 0.60)
                                        border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text:  "common"
                                            color: "#6ecf9e"
                                            font { family: Theme.fontFamily; pixelSize: 8 }
                                        }
                                    }
                                    Rectangle {
                                        visible: entry.jlpt !== ""
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 36; height: 14; radius: 3
                                        color:        Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12)
                                        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.40)
                                        border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text:  entry.jlpt
                                            color: Theme.accent
                                            font { family: Theme.fontFamily; pixelSize: 8; weight: Font.Medium }
                                        }
                                    }
                                }

                                Row {
                                    visible: entry.senses.length > 0 && entry.senses[0].tags.length > 0
                                    spacing: 4
                                    Repeater {
                                        model: entry.senses.length > 0 ? Math.min(entry.senses[0].tags.length, 2) : 0
                                        delegate: Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            height: 14; radius: 3
                                            width: posTag.implicitWidth + 8
                                            color:        Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.15)
                                            border.color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.35)
                                            border.width: 1
                                            Text {
                                                id: posTag
                                                anchors.centerIn: parent
                                                text:  entry.senses[0].tags[index]
                                                color: Theme.violetBright
                                                font { family: Theme.fontFamily; pixelSize: 8 }
                                                elide: Text.ElideRight
                                                width: Math.min(implicitWidth, 90)
                                            }
                                        }
                                    }
                                }

                                Text {
                                    visible: entry.senses.length > 0
                                    width: parent.width
                                    text:  entry.senses.length > 0 ? entry.senses[0].defs : ""
                                    color: Theme.foreground
                                    font { family: Theme.fontFamily; pixelSize: 12 }
                                    wrapMode: Text.WordWrap
                                    elide: entryDelegate.expanded ? Text.ElideNone : Text.ElideRight
                                    maximumLineCount: entryDelegate.expanded ? 99 : 1
                                }

                                Column {
                                    visible: entryDelegate.expanded && entry.senses.length > 1
                                    width: parent.width
                                    spacing: 6
                                    topPadding: 4

                                    Repeater {
                                        model: (entryDelegate.expanded && entry.senses.length > 1)
                                               ? entry.senses.length - 1 : 0
                                        delegate: Column {
                                            width: parent.width
                                            spacing: 2
                                            property var sense: entry.senses[index + 1]

                                            Row {
                                                spacing: 4
                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text:  (index + 2) + "."
                                                    color: Theme.textDim
                                                    font { family: Theme.fontFamily; pixelSize: 10 }
                                                }
                                                Repeater {
                                                    model: Math.min(sense.tags.length, 2)
                                                    delegate: Rectangle {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        height: 14; radius: 3
                                                        width: senseTag.implicitWidth + 8
                                                        color:        Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.12)
                                                        border.color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.28)
                                                        border.width: 1
                                                        Text {
                                                            id: senseTag
                                                            anchors.centerIn: parent
                                                            text:  sense.tags[index]
                                                            color: Theme.violetBright
                                                            font { family: Theme.fontFamily; pixelSize: 8 }
                                                            elide: Text.ElideRight
                                                            width: Math.min(implicitWidth, 90)
                                                        }
                                                    }
                                                }
                                            }

                                            Text {
                                                width: parent.width
                                                text:  sense.defs
                                                color: Theme.foreground
                                                font { family: Theme.fontFamily; pixelSize: 12 }
                                                wrapMode: Text.WordWrap
                                            }
                                        }
                                    }

                                    Row {
                                        visible: entry.altForms.length > 0
                                        spacing: 4
                                        topPadding: 2
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text:  "Other forms:"
                                            color: Theme.textDim
                                            font { family: Theme.fontFamily; pixelSize: 10 }
                                        }
                                        Repeater {
                                            model: entry.altForms
                                            delegate: Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text:  modelData
                                                color: Theme.mutedblue
                                                font { family: Theme.fontFamily; pixelSize: 11 }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
