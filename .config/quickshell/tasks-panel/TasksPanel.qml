import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

PanelWindow {
    id: root

    anchors.right: true
    exclusiveZone: 0

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    readonly property int tabW:   10
    readonly property int panelW: 300
    readonly property int pickerW: 230
    readonly property int panelH: 500

    // Window always full width; clipping handles what's visible
    implicitWidth:  tabW + panelW + pickerW
    implicitHeight: panelH

    WlrLayershell.margins {
        top:    screen ? Math.round((screen.height - panelH) / 2) : 200
        bottom: screen ? Math.round((screen.height - panelH) / 2) : 200
    }

    color: "transparent"

    property bool panelOpen:      false
    property bool addingTask:     false
    property bool editingGroups:  false
    property int  selectedGroupIdx: 0
    property int  pickerTarget:  -1   // index into groups, or -2 for "new group"
    property bool   pickerOpen:      false
    property string newGroupColorVal: ""

    Timer {
        id: closeTimer
        interval: 400
        onTriggered: if (!pickerOpen) root.panelOpen = false
    }

    // Repaint rings after the open animation completes (opacity fades in over 160ms)
    Timer {
        id: repaintTimer
        interval: 180
        onTriggered: ringCanvas.requestPaint()
    }

    onPanelOpenChanged: {
        if (panelOpen) repaintTimer.restart()
    }

    // ── Data ──────────────────────────────────────────────────
    property var tasks:  []
    property var groups: []

    property var upcomingTasks: {
        var out = []
        for (var i = 0; i < tasks.length; i++) {
            var t = tasks[i]
            if (!t.done && t.due) out.push(t)
        }
        out.sort(function(a, b) { return a.due - b.due })
        return out.slice(0, 5)
    }

    // groupStats includes ALL groups; empty ones get total=0
    property var groupStats: {
        var stats = []
        for (var gi = 0; gi < groups.length; gi++) {
            var g = groups[gi]
            var total = 0
            var done  = 0
            for (var ti = 0; ti < tasks.length; ti++) {
                if ((tasks[ti].group || "Other") === g.name) {
                    total++
                    if (tasks[ti].done) done++
                }
            }
            stats.push({ name: g.name, color: g.color, total: total, done: done })
        }
        return stats
    }

    property int totalTasks: tasks.length
    property int doneTasks: {
        var n = 0
        for (var i = 0; i < tasks.length; i++) if (tasks[i].done) n++
        return n
    }
    property int pct: totalTasks > 0 ? Math.round(doneTasks / totalTasks * 100) : 0

    // ── File I/O ──────────────────────────────────────────────
    readonly property string taskFilePath: "/home/kazuki/.config/quickshell/tasks-panel/tasks.qtask"

    property bool _saving: false

    FileView {
        id: taskFile
        path: root.taskFilePath
        watchChanges: true
        onTextChanged: {
            if (root._saving) return
            var t = taskFile.text()
            if (t && t.length > 0) parseTaskFile(t)
        }
        onFileChanged: taskFile.reload()
    }

    Component.onCompleted: {
        var t = taskFile.text()
        if (t && t.length > 0) parseTaskFile(t)
    }

    Process {
        id: writeProc
        property string content: ""
        command: ["bash", "-c", "printf '%s' \"$QTASK_CONTENT\" > \"$QTASK_PATH\""]
        environment: ({
            "QTASK_CONTENT": writeProc.content,
            "QTASK_PATH":    taskFilePath
        })
        onExited: root._saving = false
    }

    // Serialize all tasks+groups back to the file
    function saveFile() {
        var out = ""
        for (var gi = 0; gi < groups.length; gi++) {
            var g = groups[gi]
            out += "BEGIN:VGROUP\nNAME:" + g.name + "\nCOLOR:" + g.color + "\nEND:VGROUP\n\n"
        }
        for (var ti = 0; ti < tasks.length; ti++) {
            var t = tasks[ti]
            var dueStr = t.due ? toDateStr(t.due) : ""
            out += "BEGIN:VTASK\nSUMMARY:" + t.summary
                 + "\nDUE:" + dueStr
                 + "\nGROUP:" + (t.group || "Other")
                 + "\nDONE:" + (t.done ? "true" : "false")
                 + "\nEND:VTASK\n\n"
        }
        writeProc.content = out
        root._saving = true
        writeProc.running = true
    }

    function addTask(summary, dueStr, group) {
        var newTasks = []
        for (var i = 0; i < tasks.length; i++) newTasks.push(tasks[i])
        newTasks.push({
            summary: summary,
            due:     parseDateVal(dueStr),
            group:   group || "Other",
            done:    false
        })
        tasks = newTasks
        saveFile()
    }

    function markDone(taskSummary, taskGroup) {
        var newTasks = []
        var changed = false
        for (var i = 0; i < tasks.length; i++) {
            var t = tasks[i]
            if (!changed && t.summary === taskSummary && (t.group || "Other") === taskGroup && !t.done) {
                newTasks.push({ summary: t.summary, due: t.due, group: t.group, done: true })
                changed = true
            } else {
                newTasks.push(t)
            }
        }
        tasks = newTasks
        saveFile()
    }

    function addGroup(name, color) {
        var newGroups = []
        for (var i = 0; i < groups.length; i++) newGroups.push(groups[i])
        newGroups.push({ name: name, color: color })
        groups = newGroups
        saveFile()
    }

    function deleteGroup(name) {
        var newGroups = []
        for (var i = 0; i < groups.length; i++)
            if (groups[i].name !== name) newGroups.push(groups[i])
        groups = newGroups
        saveFile()
    }

    function recolorGroup(name, color) {
        var newGroups = []
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].name === name)
                newGroups.push({ name: groups[i].name, color: color })
            else
                newGroups.push(groups[i])
        }
        groups = newGroups
        saveFile()
    }

    readonly property var autoColors: [
        "#9B94C4","#4C98D1","#FAFF99","#D95337","#B48EAD","#AFC5DA","#88C0D0","#A3BE8C"
    ]
    property int _autoIdx: 0

    function parseTaskFile(text) {
        var lines = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n")
        var newTasks  = []
        var newGroups = []
        var inTask = false; var inGroup = false; var cur = {}
        _autoIdx = 0
        for (var i = 0; i < lines.length; i++) {
            var ln = lines[i].trim()
            if      (ln === "BEGIN:VTASK")  { inTask  = true;  cur = {}; continue }
            else if (ln === "BEGIN:VGROUP") { inGroup = true;  cur = {}; continue }
            else if (ln === "END:VTASK") {
                inTask = false
                if (cur.summary)
                    newTasks.push({ summary: cur.summary, due: cur.due || null,
                                    group: cur.group || "Other", done: cur.done || false })
                cur = {}; continue
            }
            else if (ln === "END:VGROUP") {
                inGroup = false
                if (cur.name)
                    newGroups.push({ name: cur.name,
                                     color: cur.color || autoColors[_autoIdx++ % autoColors.length] })
                cur = {}; continue
            }
            if (!inTask && !inGroup) continue
            var colon = ln.indexOf(":")
            if (colon === -1) continue
            var key = ln.substring(0, colon).toUpperCase()
            var val = ln.substring(colon + 1).trim()
            if (inTask) {
                if      (key === "SUMMARY") cur.summary = val
                else if (key === "DUE")     { var p = parseDateVal(val); if (p) cur.due = p }
                else if (key === "GROUP")   cur.group   = val
                else if (key === "DONE")    cur.done    = (val.toLowerCase() === "true")
            }
            if (inGroup) {
                if      (key === "NAME")  cur.name  = val
                else if (key === "COLOR") cur.color = val
            }
        }
        // Auto-add groups for undeclared group names
        for (var ti = 0; ti < newTasks.length; ti++) {
            var tg = newTasks[ti].group; var found = false
            for (var gi = 0; gi < newGroups.length; gi++)
                if (newGroups[gi].name === tg) { found = true; break }
            if (!found) newGroups.push({ name: tg, color: autoColors[_autoIdx++ % autoColors.length] })
        }
        tasks  = newTasks
        groups = newGroups
    }

    function parseDateVal(val) {
        if (!val || val.length < 8) return null
        var v = val.trim()
        return new Date(parseInt(v.substring(0,4),10),
                        parseInt(v.substring(4,6),10) - 1,
                        parseInt(v.substring(6,8),10))
    }

    function toDateStr(d) {
        var mo = d.getMonth() + 1; var dy = d.getDate()
        return d.getFullYear() + (mo < 10 ? "0" : "") + mo + (dy < 10 ? "0" : "") + dy
    }

    function groupColor(name) {
        for (var i = 0; i < groups.length; i++)
            if (groups[i].name === name) return groups[i].color
        return "#9B94C4"
    }

    function dueLabel(due) {
        if (!due) return ""
        var now = new Date(); now.setHours(0,0,0,0)
        var diff = Math.round((due - now) / 86400000)
        if (diff < 0)   return "Overdue"
        if (diff === 0) return "Due today"
        if (diff === 1) return "Due tomorrow"
        if (diff < 7)   return "Due " + Qt.formatDate(due, "dddd")
        return "Due " + Qt.formatDate(due, "MMM d")
    }

    function dueUrgency(due) {
        if (!due) return Theme.textDim
        var hrs = (due - new Date()) / 3600000
        if (hrs < 0)  return "#FF6B6B"
        if (hrs < 24) return "#FF8B8B"
        if (hrs < 72) return Theme.accent
        return Theme.textDim
    }

    // Only intercept clicks over the visible clip area; rest passes through to desktop
    mask: Region {
        item: clipper
        Region {
            x:      0
            y:      0
            width:  pickerOpen ? pickerW : 0
            height: panelH
            intersection: Intersection.Combine
        }
    }

    // ── Visual ────────────────────────────────────────────────
    Item {
        anchors.fill: parent

        // Tab strip — only this triggers open
        Item {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: tabW
            z: 2

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) { closeTimer.stop(); root.panelOpen = true }
                    else closeTimer.restart()
                }
            }

            Text {
                anchors.centerIn: parent
                text: pct + "%"; color: Theme.violetBright; rotation: 90
                font { family: Theme.fontFamily; pixelSize: 8; weight: Font.Medium }
            }
        }

        // Clip wrapper — only grows wider, never moves
        Item {
            id: clipper
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: panelOpen ? tabW + panelW : tabW
            clip: true
            Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.InOutCubic } }

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: tabW + panelW
                color: "#2E3440"; radius: 8
                border.color: Theme.borderIdle; border.width: 1

                // Top accent
                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 2; radius: 8
                    color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.55)
                }

                // Keep panel open while hovering — HoverHandler doesn't eat mouse events
                HoverHandler {
                    onHoveredChanged: {
                        if (hovered) { closeTimer.stop(); root.panelOpen = true }
                        else closeTimer.restart()
                    }
                }

                // ── Content ────────────────────────────────────
                ColumnLayout {
                    anchors {
                        left: parent.left; right: parent.right
                        top: parent.top; bottom: parent.bottom
                        leftMargin: 14; rightMargin: tabW + 8
                        topMargin: 16; bottomMargin: 12
                    }
                    spacing: 10

                    opacity: panelOpen ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 160 } }

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Tasks"; color: Theme.textPrimary; Layout.fillWidth: true
                               font { family: Theme.fontFamily; pixelSize: 14; weight: Font.Medium } }
                        Text { text: Qt.formatDate(new Date(), "MMM d"); color: Theme.textDim
                               font { family: Theme.fontFamily; pixelSize: 11 } }
                    }

                    // ── Ring chart — single Canvas, draws all rings in a loop ──
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 160

                        Canvas {
                            id: ringCanvas
                            anchors.fill: parent

                            // Repaint whenever data or visibility changes
                            Connections {
                                target: root
                                function onGroupStatsChanged() { ringCanvas.requestPaint() }
                                function onPanelOpenChanged()  { ringCanvas.requestPaint() }
                            }
                            Component.onCompleted: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                var cx = width / 2
                                var cy = height / 2

                                for (var i = 0; i < groupStats.length; i++) {
                                    var gs   = groupStats[i]
                                    var r    = (width - 12) / 2 - i * 12
                                    if (r < 28) break
                                    var pct2 = gs.total > 0 ? gs.done / gs.total : 0

                                    // Parse group color for dim track
                                    var cr = parseInt(gs.color.substring(1,3),16)/255
                                    var cg = parseInt(gs.color.substring(3,5),16)/255
                                    var cb = parseInt(gs.color.substring(5,7),16)/255

                                    // Dim full-circle track (group color at 40% opacity)
                                    ctx.beginPath()
                                    ctx.arc(cx, cy, r, 0, Math.PI * 2)
                                    ctx.strokeStyle = Qt.rgba(cr, cg, cb, 0.25)
                                    ctx.lineWidth   = 9
                                    ctx.lineCap     = "round"
                                    ctx.stroke()

                                    // Filled progress arc on top (full opacity)
                                    if (pct2 > 0) {
                                        ctx.beginPath()
                                        ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * pct2)
                                        ctx.strokeStyle = gs.color
                                        ctx.lineWidth   = 9
                                        ctx.lineCap     = "round"
                                        ctx.stroke()
                                    }
                                }
                            }
                        }

                        // Centre labels
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0
                            Text { Layout.alignment: Qt.AlignHCenter; text: "✦"
                                   color: Theme.violetBright
                                   font { family: Theme.fontFamily; pixelSize: 20 } }
                        }
                    }

                    // Legend
                    Flow {
                        Layout.fillWidth: true; spacing: 6
                        Repeater {
                            model: groupStats
                            delegate: RowLayout {
                                spacing: 4
                                Rectangle { width: 7; height: 7; radius: 4; color: modelData.color }
                                Text { text: modelData.name; color: Theme.textDim
                                       font { family: Theme.fontFamily; pixelSize: 9 } }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderIdle; opacity: 0.5 }

                    Text {
                        text: upcomingTasks.length > 0 ? "Upcoming" : "No upcoming tasks"
                        color: Theme.textDim
                        font { family: Theme.fontFamily; pixelSize: 10 }
                    }

                    // ── Task list ──────────────────────────────
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Flickable {
                            anchors.fill: parent
                            contentHeight: taskCol.implicitHeight
                            clip: true

                            ColumnLayout {
                                id: taskCol
                                width: parent.width
                                spacing: 6

                                Repeater {
                                    model: upcomingTasks
                                    delegate: RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        // Group color bar
                                        Rectangle {
                                            width: 3; height: taskTitle.implicitHeight + 4
                                            radius: 2; color: groupColor(modelData.group)
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true; spacing: 1
                                            Text {
                                                id: taskTitle
                                                text: modelData.summary
                                                color: Theme.foreground; elide: Text.ElideRight
                                                font { family: Theme.fontFamily; pixelSize: 12 }
                                                Layout.fillWidth: true
                                            }
                                            RowLayout {
                                                spacing: 4
                                                Text { text: modelData.group; color: groupColor(modelData.group)
                                                       font { family: Theme.fontFamily; pixelSize: 9 } }
                                                Text { text: "·"; color: Theme.textDim
                                                       font { family: Theme.fontFamily; pixelSize: 9 } }
                                                Text { text: dueLabel(modelData.due); color: dueUrgency(modelData.due)
                                                       font { family: Theme.fontFamily; pixelSize: 9 } }
                                            }
                                        }

                                        // Checkbox — click to mark done
                                        Rectangle {
                                            width: 16; height: 16; radius: 4
                                            color: checkHover.containsMouse
                                                   ? Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.2)
                                                   : "transparent"
                                            border.color: groupColor(modelData.group)
                                            border.width: 1.5
                                            Behavior on color { ColorAnimation { duration: 100 } }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "\uf00c"; color: groupColor(modelData.group)
                                                font { family: Theme.fontFamily; pixelSize: 9 }
                                                visible: false  // tasks in upcomingTasks are always undone
                                            }

                                            MouseArea {
                                                id: checkHover
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: markDone(modelData.summary, modelData.group || "Other")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Bottom buttons ─────────────────────────
                    RowLayout {
                        Layout.fillWidth: true; spacing: 6

                        Rectangle {
                            implicitWidth: 28; implicitHeight: 28; radius: 6
                            color: egHover.containsMouse
                                   ? Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.28)
                                   : Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.10)
                            border.color: egHover.containsMouse ? Theme.borderActive : Theme.borderIdle
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text { anchors.centerIn: parent; text: "\uf044"; color: Theme.violetBright
                                   font { family: Theme.fontFamily; pixelSize: 11 } }
                            MouseArea {
                                id: egHover; anchors.fill: parent
                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: { editingGroups = !editingGroups; addingTask = false }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 28; radius: 6
                            color: atHover.containsMouse
                                   ? Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.28)
                                   : Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.10)
                            border.color: atHover.containsMouse ? Theme.borderActive : Theme.borderIdle
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                            RowLayout {
                                anchors.centerIn: parent; spacing: 5
                                Text { text: "+"; color: Theme.violetBright
                                       font { family: Theme.fontFamily; pixelSize: 14 } }
                                Text { text: "New Task"; color: Theme.foreground
                                       font { family: Theme.fontFamily; pixelSize: 11 } }
                            }
                            MouseArea {
                                id: atHover; anchors.fill: parent
                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (addingTask) {
                                        addingTask = false
                                        summaryInput.text = ""
                                    } else {
                                        addingTask    = true
                                        editingGroups = false
                                        selectedGroupIdx = 0
                                        summaryInput.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }

                    // ── Edit Groups form ───────────────────────
                    Rectangle {
                        visible: editingGroups
                        Layout.fillWidth: true
                        implicitHeight: egForm.implicitHeight + 16
                        radius: 6; color: Qt.rgba(1,1,1,0.04)
                        border.color: Theme.borderIdle; border.width: 1

                        ColumnLayout {
                            id: egForm
                            anchors { left: parent.left; right: parent.right; top: parent.top
                                      margins: 8; topMargin: 8 }
                            spacing: 6

                            Text { text: "Groups"; color: Theme.textDim
                                   font { family: Theme.fontFamily; pixelSize: 10; weight: Font.Medium } }

                            Repeater {
                                model: groups
                                delegate: RowLayout {
                                    Layout.fillWidth: true; spacing: 4
                                    id: groupRow

                                    // Color swatch — click to open wheel picker
                                    Rectangle {
                                        width: 18; height: 18; radius: 4
                                        color: modelData.color
                                        border.color: (pickerOpen && pickerTarget === index)
                                                      ? Theme.borderActive : Theme.borderIdle
                                        border.width: 1
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (pickerOpen && pickerTarget === index) {
                                                    pickerOpen = false
                                                } else {
                                                    pickerTarget  = index
                                                    pickerOpen    = true
                                                }
                                            }
                                        }
                                    }

                                    // Name (read-only)
                                    Text {
                                        text: modelData.name; color: Theme.foreground
                                        font { family: Theme.fontFamily; pixelSize: 11 }
                                        Layout.fillWidth: true; elide: Text.ElideRight
                                    }

                                    // Delete button
                                    Rectangle {
                                        implicitWidth: 18; implicitHeight: 18; radius: 4
                                        color: delHover.containsMouse
                                               ? Qt.rgba(0.85, 0.33, 0.22, 0.35)
                                               : Qt.rgba(1,1,1,0.06)
                                        border.color: delHover.containsMouse ? "#D95337" : Theme.borderIdle
                                        border.width: 1
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                        Text {
                                            anchors.centerIn: parent; text: ""
                                            color: delHover.containsMouse ? "#D95337" : Theme.textDim
                                            font { family: Theme.fontFamily; pixelSize: 8 }
                                        }
                                        MouseArea {
                                            id: delHover; anchors.fill: parent
                                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: deleteGroup(modelData.name)
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true; spacing: 6

                                Rectangle {
                                    Layout.fillWidth: true; implicitHeight: 24; radius: 4
                                    color: Qt.rgba(1,1,1,0.06); border.color: Theme.borderIdle; border.width: 1
                                    TextInput {
                                        id: newGroupName
                                        anchors { fill: parent; margins: 5 }
                                        color: Theme.foreground; selectionColor: Theme.violetBright
                                        font { family: Theme.fontFamily; pixelSize: 11 }
                                        clip: true
                                        Text { visible: newGroupName.text.length === 0; anchors.fill: parent
                                               text: "Name"; color: Theme.textDim
                                               font { family: Theme.fontFamily; pixelSize: 11 } }
                                    }
                                }

                                // New group color swatch
                                Rectangle {
                                    implicitWidth: 28; implicitHeight: 24; radius: 4
                                    color: newGroupColorVal.length === 7 ? newGroupColorVal : Qt.rgba(0.3,0.3,0.4,0.6)
                                    border.color: (pickerOpen && pickerTarget === -2)
                                                  ? Theme.borderActive : Theme.borderIdle
                                    border.width: 1
                                    Text {
                                        visible: newGroupColorVal.length !== 7
                                        anchors.centerIn: parent; text: "+"
                                        color: Theme.textDim
                                        font { family: Theme.fontFamily; pixelSize: 14 }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (pickerOpen && pickerTarget === -2) {
                                                pickerOpen = false
                                            } else {
                                                pickerTarget = -2
                                                pickerOpen   = true
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    implicitWidth: 36; implicitHeight: 24; radius: 4
                                    color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.25)
                                    Text { anchors.centerIn: parent; text: "Add"; color: Theme.textPrimary
                                           font { family: Theme.fontFamily; pixelSize: 10; weight: Font.Medium } }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            var n = newGroupName.text.trim()
                                            if (n.length === 0) return
                                            var c = newGroupColorVal.length === 7
                                                    ? newGroupColorVal
                                                    : autoColors[_autoIdx % autoColors.length]
                                            addGroup(n, c)
                                            newGroupName.text = ""
                                            newGroupColorVal  = ""
                                            pickerOpen = false
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Add Task form ──────────────────────────
                    Rectangle {
                        visible: addingTask
                        Layout.fillWidth: true
                        implicitHeight: atForm.implicitHeight + 16
                        radius: 6; color: Qt.rgba(1,1,1,0.04)
                        border.color: Theme.borderIdle; border.width: 1

                        ColumnLayout {
                            id: atForm
                            anchors { left: parent.left; right: parent.right; top: parent.top
                                      margins: 8; topMargin: 8 }
                            spacing: 6

                            // Summary
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 26; radius: 4
                                color: Qt.rgba(1,1,1,0.06); border.color: Theme.borderIdle; border.width: 1
                                TextInput {
                                    id: summaryInput
                                    anchors { fill: parent; margins: 6 }
                                    color: Theme.foreground; selectionColor: Theme.violetBright
                                    font { family: Theme.fontFamily; pixelSize: 12 }
                                    clip: true
                                    Keys.onTabPressed: event.accepted = true
                                    Text { visible: summaryInput.text.length === 0; anchors.fill: parent
                                           text: "Task name..."; color: Theme.textDim
                                           font { family: Theme.fontFamily; pixelSize: 12 } }
                                }
                            }

                            RowLayout {
                                id: dateGroupRow
                                Layout.fillWidth: true; spacing: 6

                                // Due date — tappable button opens inline calendar
                                property var _pickedDate: new Date()
                                property bool _calOpen: false

                                Rectangle {
                                    Layout.fillWidth: true; implicitHeight: 26; radius: 4
                                    color: Qt.rgba(1,1,1,0.06); border.color: dateGroupRow._calOpen ? Theme.violetBright : Theme.borderIdle; border.width: 1
                                    RowLayout {
                                        anchors { fill: parent; leftMargin: 8; rightMargin: 6 }
                                        Text {
                                            Layout.fillWidth: true
                                            text: Qt.formatDate(dateGroupRow._pickedDate, "MMM d, yyyy")
                                            color: Theme.foreground
                                            font { family: Theme.fontFamily; pixelSize: 11 }
                                        }
                                        Text {
                                            text: "▾"; color: Theme.violetBright
                                            font { family: Theme.fontFamily; pixelSize: 11 }
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: dateGroupRow._calOpen = !dateGroupRow._calOpen
                                    }
                                }

                                // Group — cycle with arrows, no text input
                                Rectangle {
                                    Layout.fillWidth: true; implicitHeight: 26; radius: 4
                                    color: Qt.rgba(1,1,1,0.06); border.color: Theme.borderIdle; border.width: 1

                                    RowLayout {
                                        anchors { fill: parent; leftMargin: 6; rightMargin: 4 }
                                        spacing: 2

                                        Rectangle {
                                            width: 8; height: 8; radius: 4
                                            color: groups.length > 0
                                                   ? groups[selectedGroupIdx % groups.length].color
                                                   : Theme.violetBright
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            leftPadding: 4
                                            text: groups.length > 0
                                                  ? groups[selectedGroupIdx % groups.length].name
                                                  : "Other"
                                            color: Theme.foreground
                                            font { family: Theme.fontFamily; pixelSize: 11 }
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: "◂"; color: Theme.violetBright
                                            font { family: Theme.fontFamily; pixelSize: 12 }
                                            MouseArea {
                                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (groups.length === 0) return
                                                    selectedGroupIdx = (selectedGroupIdx - 1 + groups.length) % groups.length
                                                }
                                            }
                                        }

                                        Text {
                                            text: "▸"; color: Theme.violetBright
                                            font { family: Theme.fontFamily; pixelSize: 12 }
                                            MouseArea {
                                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (groups.length === 0) return
                                                    selectedGroupIdx = (selectedGroupIdx + 1) % groups.length
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Add / Cancel
                            RowLayout {
                                Layout.fillWidth: true; spacing: 6

                                Rectangle {
                                    Layout.fillWidth: true; implicitHeight: 24; radius: 4
                                    color: Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.25)
                                    Text { anchors.centerIn: parent; text: "Add"; color: Theme.textPrimary
                                           font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium } }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (summaryInput.text.trim().length === 0) return
                                            var grp = groups.length > 0
                                                      ? groups[selectedGroupIdx % groups.length].name
                                                      : "Other"
                                            addTask(summaryInput.text.trim(), toDateStr(dateGroupRow._pickedDate), grp)
                                            summaryInput.text = ""
                                            addingTask = false
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true; implicitHeight: 24; radius: 4
                                    color: Qt.rgba(1,1,1,0.06)
                                    Text { anchors.centerIn: parent; text: "Cancel"; color: Theme.textDim
                                           font { family: Theme.fontFamily; pixelSize: 11 } }
                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: { addingTask = false; summaryInput.text = "" }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Color picker — slides out to the LEFT of the panel ──
        Item {
            id: pickerClipper
            anchors.right: parent.right
            anchors.top:   parent.top
            anchors.bottom: parent.bottom
            width: pickerOpen ? tabW + panelW + pickerW : tabW + panelW
            clip: true

            Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.InOutCubic } }

            // Covers the full sliding area — stops closeTimer even during animation
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) closeTimer.stop()
                    else closeTimer.restart()
                }
            }

            Rectangle {
                anchors.right:  parent.right
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                width: tabW + panelW + pickerW
                color: "transparent"

                // Picker panel background
                Rectangle {
                    anchors.left:   parent.left
                    anchors.top:    parent.top
                    anchors.bottom: parent.bottom
                    width: pickerW
                    color:        "#2E3440"
                    radius:       8
                    border.color: Theme.borderIdle
                    border.width: 1

                    // Separator line on right edge
                    Rectangle {
                        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                        width: 1; color: Theme.borderIdle; opacity: 0.5
                    }

                    ColorWheelPicker {
                        anchors.centerIn: parent
                        currentColor: {
                            if (pickerTarget === -2)
                                return newGroupColorVal.length === 7 ? newGroupColorVal : "#9B94C4"
                            if (pickerTarget >= 0 && pickerTarget < groups.length)
                                return groups[pickerTarget].color
                            return "#9B94C4"
                        }
                        onColorPicked: function(hex) {
                            if (pickerTarget === -2) {
                                newGroupColorVal = hex
                            } else if (pickerTarget >= 0 && pickerTarget < groups.length) {
                                recolorGroup(groups[pickerTarget].name, hex)
                            }
                            pickerOpen = false
                        }
                    }
                }
            }
        }
    }

    // ── Floating calendar popup ────────────────────────────────
    PopupWindow {
        id: calPopup
        visible: dateGroupRow._calOpen

        // Size to fit the calendar content
        implicitWidth:  220
        implicitHeight: 210

        // Position: centered over the panel
        anchor.window: root
        anchor.rect.x:      root.width - tabW - Math.round((panelW + implicitWidth) / 2)
        anchor.rect.y:      Math.round((root.height - implicitHeight) / 2)
        anchor.rect.width:  0
        anchor.rect.height: 0
        anchor.edges:       Qt.TopEdge | Qt.LeftEdge

        color: "transparent"

        HoverHandler {
            onHoveredChanged: {
                if (hovered) closeTimer.stop()
                else closeTimer.restart()
            }
        }

        Rectangle {
            anchors.fill: parent
            color:        "#2E3440"
            radius:       8
            border.color: Theme.borderIdle
            border.width: 1

            // Close on click outside
            MouseArea {
                anchors.fill: parent
                onClicked: {} // absorb — don't close
            }

            Column {
                id: calendarContent
                anchors { fill: parent; margins: 8 }
                spacing: 4

                property int _calYear:  new Date().getFullYear()
                property int _calMonth: new Date().getMonth()

                // Reset month/year to picked date whenever popup opens
                Connections {
                    target: dateGroupRow
                    function on_CalOpenChanged() {
                        if (dateGroupRow._calOpen) {
                            calendarContent._calYear  = dateGroupRow._pickedDate.getFullYear()
                            calendarContent._calMonth = dateGroupRow._pickedDate.getMonth()
                        }
                    }
                }

                // Month nav
                RowLayout {
                    width: parent.width
                    Text {
                        text: "◂"; color: Theme.violetBright
                        font { family: Theme.fontFamily; pixelSize: 13 }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (calendarContent._calMonth === 0) { calendarContent._calMonth = 11; calendarContent._calYear-- }
                                else calendarContent._calMonth--
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDate(new Date(calendarContent._calYear, calendarContent._calMonth, 1), "MMMM yyyy")
                        color: Theme.textPrimary
                        font { family: Theme.fontFamily; pixelSize: 11; weight: Font.Medium }
                    }
                    Text {
                        text: "▸"; color: Theme.violetBright
                        font { family: Theme.fontFamily; pixelSize: 13 }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (calendarContent._calMonth === 11) { calendarContent._calMonth = 0; calendarContent._calYear++ }
                                else calendarContent._calMonth++
                            }
                        }
                    }
                }

                // Day-of-week headers
                Row {
                    width: parent.width
                    Repeater {
                        model: ["Su","Mo","Tu","We","Th","Fr","Sa"]
                        Text {
                            width: calendarContent.width / 7
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData; color: Theme.textDim
                            font { family: Theme.fontFamily; pixelSize: 9 }
                        }
                    }
                }

                // Day grid
                Grid {
                    width: parent.width
                    columns: 7

                    Repeater {
                        model: {
                            var firstDay    = new Date(calendarContent._calYear, calendarContent._calMonth, 1).getDay()
                            var daysInMonth = new Date(calendarContent._calYear, calendarContent._calMonth + 1, 0).getDate()
                            return firstDay + daysInMonth
                        }

                        delegate: Item {
                            width:  calendarContent.width / 7
                            height: 22
                            property int  _firstDay: new Date(calendarContent._calYear, calendarContent._calMonth, 1).getDay()
                            property int  _day:   index - _firstDay + 1
                            property bool _valid: index >= _firstDay
                            property bool _isSelected: {
                                if (!_valid) return false
                                var pd = dateGroupRow._pickedDate
                                return pd.getFullYear() === calendarContent._calYear &&
                                       pd.getMonth()    === calendarContent._calMonth &&
                                       pd.getDate()     === _day
                            }
                            property bool _isToday: {
                                var now = new Date()
                                return _valid &&
                                       now.getFullYear() === calendarContent._calYear &&
                                       now.getMonth()    === calendarContent._calMonth &&
                                       now.getDate()     === _day
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 20; height: 20; radius: 10
                                color: _isSelected
                                       ? Qt.rgba(Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.4)
                                       : "transparent"
                                border.color: _isToday && !_isSelected ? Theme.violetBright : "transparent"
                                border.width: 1
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: _valid
                                text: _day
                                color: _isSelected ? Theme.textPrimary : (_isToday ? Theme.violetBright : Theme.foreground)
                                font { family: Theme.fontFamily; pixelSize: 10;
                                       weight: _isSelected ? Font.Medium : Font.Normal }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: _valid
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    dateGroupRow._pickedDate = new Date(calendarContent._calYear, calendarContent._calMonth, _day)
                                    dateGroupRow._calOpen = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
