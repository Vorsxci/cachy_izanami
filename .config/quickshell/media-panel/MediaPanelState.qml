pragma Singleton
import QtQuick

// MediaPanelState.qml — lives in root (alongside other singletons)
// Shared open/close state for MediaPanel.
QtObject {
    property bool open:         false
    property bool panelHovered: false

    function toggle() { open = !open }
}
