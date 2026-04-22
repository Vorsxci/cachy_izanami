// =============================================================
// CornerAccents.qml — Geometric corner bracket accents
// =============================================================

import QtQuick 2.15
import "palette.js" as P

Item {
    anchors.fill: parent

    // ── Top-left ──────────────────────────────────────────────
    Rectangle { x: 36; y: 28; width: 44; height: 1; color: P.border1 }
    Rectangle { x: 36; y: 28; width: 1;  height: 44; color: P.border1 }

    // ── Top-right ─────────────────────────────────────────────
    Rectangle { x: parent.width - 80; y: 28; width: 44; height: 1; color: P.border1 }
    Rectangle { x: parent.width - 37; y: 28; width: 1;  height: 44; color: P.border1 }

    // ── Bottom-left ───────────────────────────────────────────
    Rectangle { x: 36; y: parent.height - 29; width: 44; height: 1; color: P.border1 }
    Rectangle { x: 36; y: parent.height - 72; width: 1;  height: 44; color: P.border1 }

    // ── Bottom-right ──────────────────────────────────────────
    Rectangle { x: parent.width - 80; y: parent.height - 29; width: 44; height: 1; color: P.border1 }
    Rectangle { x: parent.width - 37; y: parent.height - 72; width: 1;  height: 44; color: P.border1 }
}
