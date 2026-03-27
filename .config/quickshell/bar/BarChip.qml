import QtQuick
import QtQuick.Layouts
import "../theme"

// BarChip — hover chip wrapper for bar modules
// Content goes in the default slot and sizes the chip via childrenRect.
Rectangle {
    id: root

    default property alias content: inner.children
    property bool leftAccent: false
    property bool hovered:    false

    // implicitWidth comes from inner childrenRect + padding
    // inner is not a layout so there's no binding loop
    implicitHeight: Theme.barHeight - 6
    implicitWidth:  inner.childrenRect.width + 12

    color:        hovered ? Theme.glassViolet : "transparent"
    radius:       5
    border.color: hovered ? Theme.borderHover : "transparent"
    border.width: 1

    // Gold left accent on hover
    Rectangle {
        visible: root.leftAccent && root.hovered
        width:   2
        height:  parent.height
        color:   Theme.accent
        radius:  2
    }

    // Plain Item — not a Layout, so childrenRect works without a binding loop
    Item {
        id: inner
        anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
    }

    HoverHandler { onHoveredChanged: root.hovered = hovered }

    Behavior on color        { ColorAnimation { duration: 180 } }
    Behavior on border.color { ColorAnimation { duration: 180 } }
}
