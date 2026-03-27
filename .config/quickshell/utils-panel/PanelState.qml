pragma Singleton
import QtQuick

// PanelState.qml — lives in utils-panel/
// Shared open/close state for UtilsPanel.
// panelHovered is set by UtilsPanel's HoverHandler so the gear
// collapse timer knows not to close the panel while the cursor is inside.
QtObject {
    property bool open:         false
    property bool panelHovered: false

    function toggle() { open = !open }
}
