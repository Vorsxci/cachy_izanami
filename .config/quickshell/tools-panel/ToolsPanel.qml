import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"
import "./tools"

// ToolsPanel.qml
//
// Slide-out bar (RunPanel style). Hovering opens the bar; clicking a bubble
// expands that tool's content pane downward below the bar.
//
// TO ADD A TOOL:
//   1. Create tools/MyTool.qml  (see JishoTool.qml as a template)
//   2. Add it to the toolComponents list below (one line)
//   3. Bump bubbleCount by 1
//
// shell.qml:
//   import "tools-panel"
//   ToolsPanel {}

PanelWindow {
    id: root

    anchors.left: true
    anchors.top:  true
    exclusiveZone: 0

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    WlrLayershell.margins { 
      top: 100
      left: -4
    }

    // -- Geometry -------------------------------------------------------------
    readonly property int tabW:          20
    readonly property int tabH:          44
    readonly property int barH:          44
    readonly property int bubbleSize:    32
    readonly property int bubbleSpacing: 6
    readonly property int toolW:         320
    readonly property int toolH:         480

    // ** INCREMENT this when adding a tool **
    readonly property int bubbleCount: 3

    readonly property int barInnerW: bubbleCount * bubbleSize
                                   + (bubbleCount - 1) * bubbleSpacing
                                   + 24

    implicitWidth:  tabW + Math.max(barInnerW, toolW)
    implicitHeight: barH + toolH

    color: "transparent"

    // -- State ----------------------------------------------------------------
    property bool panelOpen: false
    property int  activeTool: -1

    function toggleTool(idx) {
        if (!panelOpen) panelOpen = true
        activeTool = (activeTool === idx) ? -1 : idx
    }

    onPanelOpenChanged: {
        if (!panelOpen) activeTool = -1
    }

    Timer {
        id: closeTimer
        interval: 400
        onTriggered: { if (root.activeTool === -1) root.panelOpen = false }
    }

    // -- Tool registry --------------------------------------------------------
    // Each entry maps to one file in tools/.
    // label and accentColor are declared inside each tool component itself,
    // but we also list them here so the bubble row can read them without
    // instantiating the full content component just for the icon.
    //
    // "component" is the QML Component (imported from tools/) to load into
    // the content pane when this tool is active.

    property var toolDefs: [
        {
          label:       "\u8F9E",
            accentColor: Theme.lilac,
            component:   jishoComponent
        },
        {
            label:       "\u21c4" + "\u3042",
            accentColor: Theme.mutedblue,
            component:   deeplComponent
        },
        {
            label:       "+=",
            accentColor: Theme.accent,
            component:   calcComponent
        }
    ]

    Component { id: jishoComponent; JishoTool {} }
    Component { id: deeplComponent; DeepLTool {} }
    Component { id: calcComponent;  CalcTool  {} }    
    // Component { id: myToolComponent; MyTool {} }

    // -- Mask -----------------------------------------------------------------
    mask: Region { item: maskRoot }

    // -- Visual ---------------------------------------------------------------
    Item {
        id: maskRoot
        anchors.left: parent.left
        anchors.top:  parent.top
        width:  root.panelOpen
            ? root.tabW + Math.max(root.barInnerW, root.toolW)
            : root.tabW
        height: root.barH + (root.activeTool >= 0 ? root.toolH : 0)

        Behavior on width  { NumberAnimation { duration: 260; easing.type: Easing.InOutCubic } }
        Behavior on height { NumberAnimation { duration: 260; easing.type: Easing.InOutCubic } }

        // -- Tab pill (identical to RunPanel) ---------------------------------
        Item {
            anchors.left: parent.left
            anchors.top:  parent.top
            width:  root.tabW
            height: root.tabH
            z: 2

            HoverHandler {
                id: tabHover
                onHoveredChanged: {
                    if (hovered) { closeTimer.stop(); root.panelOpen = true }
                    else closeTimer.restart()
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(
                    Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b,
                    tabHover.hovered || root.panelOpen ? 0.6 : 0.35
                )
                border.color: Theme.borderIdle
                border.width: 1
                Behavior on color { ColorAnimation { duration: 160 } }

                Text {
                    anchors.centerIn: parent
                    text:    "\u229E"
                    color:   Theme.textPrimary
                    opacity: root.panelOpen ? 0.0 : 0.8
                    font { family: Theme.fontFamily; pixelSize: 20; weight: Font.Medium }
                    Behavior on opacity { NumberAnimation { duration: 160 } }
                }
            }
        }

        // -- Horizontal clip wrapper ------------------------------------------
        Item {
            anchors.left:   parent.left
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width: parent.width
            clip:  true

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) { closeTimer.stop(); root.panelOpen = true }
                    else closeTimer.restart()
                }
            }

            // -- Bar ----------------------------------------------------------
            Rectangle {
                id: barRect
                anchors.left: parent.left
                anchors.top:  parent.top
                width:  root.tabW + Math.max(root.barInnerW, root.toolW)
                height: root.barH
                color:        "#2E3440"
                radius:       8
                border.color: Theme.borderIdle
                border.width: 1

                // Accent stripe
                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                    width: 2; radius: 8
                    color: Qt.rgba(
                        Theme.violetBright.r, Theme.violetBright.g, Theme.violetBright.b, 0.55
                    )
                }

                // Bubble row -- driven by toolDefs
                Row {
                    anchors {
                        left: parent.left; leftMargin: root.tabW + 12
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: root.bubbleSpacing
                    opacity: root.panelOpen ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 160 } }

                    Repeater {
                        model: root.toolDefs
                        delegate: ToolBubble {
                            label:       modelData.label
                            accentColor: modelData.accentColor
                            size:        root.bubbleSize
                            active:      root.activeTool === index
                            onClicked:   root.toggleTool(index)
                        }
                    }
                }
            }

            // -- Tool content pane (drops below bar) --------------------------
            Item {
                anchors.left: parent.left
                anchors.top:  barRect.bottom
                anchors.topMargin: 4
                width:  root.tabW + Math.max(root.barInnerW, root.toolW)
                height: root.toolH

                // One Loader per tool slot -- only the active one is active
                Repeater {
                    model: root.toolDefs
                    delegate: Loader {
                        anchors.fill: parent

                        // Load the component only while it's the active tool
                        // (saves resources when closed)
                        active:    root.activeTool === index
                        sourceComponent: modelData.component

                        // Pass context into the loaded tool
                        onLoaded: {
                            item.toolActive = Qt.binding(function() {
                                return root.activeTool === index
                            })
                            item.toolIndex = index
                        }
                    }
                }
            }
        }
    }
}
