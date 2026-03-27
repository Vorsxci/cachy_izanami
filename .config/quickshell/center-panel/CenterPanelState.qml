pragma Singleton
import QtQuick

// CenterPanelState.qml — lives in center-panel/
QtObject {
    property bool open: false
    function toggle() { open = !open }
}
