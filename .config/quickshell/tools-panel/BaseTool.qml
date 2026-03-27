import QtQuick
import "../../theme"

// BaseTool.qml
// Every file in tools-panel/tools/ should be a component that extends this.
// Required properties tell ToolsPanel how to render the bubble.
// The Item body is loaded into the content pane when active.
//
// Example tool file (tools/JishoTool.qml):
//
//   import "../"      // imports BaseTool via qmldir
//   BaseTool {
//       toolLabel: "\u8F9E"
//       toolColor: Theme.lilac
//       toolTooltip: "Dictionary"
//       // ... content as children
//   }

Item {
    // -- Bubble identity (set by each tool) -----------------------------------
    property string toolLabel:   "?"
    property color  toolColor:   Theme.violetBright
    property string toolTooltip: ""

    // -- Injected by ToolsPanel at load time ----------------------------------
    property bool   toolActive:  false   // true when this tool's pane is showing
    property int    toolIndex:   -1      // position in the bar

    // -- Signal back to panel -------------------------------------------------
    signal requestFocus()   // tool can ask for keyboard focus on open

    anchors.fill: parent
}
