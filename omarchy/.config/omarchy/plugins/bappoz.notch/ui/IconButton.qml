import QtQuick
import QtQuick.Controls
import qs.Commons

AbstractButton {
    id: root

    property string iconName: "sparkles"
    property int iconSize: 15
    property bool selected: false
    property bool circular: false
    property bool filled: false
    property color tint: "white"
    property string hint: ""

    implicitWidth: 28
    implicitHeight: 26
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: hint
    Accessible.role: Accessible.Button
    scale: down ? 0.9 : hovered && circular ? 1.06 : 1
    ToolTip.visible: hovered && hint !== ""
    ToolTip.delay: 500
    ToolTip.text: hint
    Keys.onReturnPressed: clicked()

    Behavior on scale {
        NumberAnimation {
            duration: Style.duration(150)
            easing.type: Easing.OutCubic
        }

    }

    contentItem: Item {
        Icon {
            anchors.centerIn: parent
            name: root.iconName
            size: root.iconSize
            color: root.filled ? "#000000" : root.tint
            opacity: root.enabled ? (root.selected || root.hovered || root.filled ? 1 : 0.58) : 0.2
        }

    }

    background: Rectangle {
        radius: root.circular ? width / 2 : 6
        color: root.filled ? "white" : root.selected ? "#2effffff" : root.hovered || root.activeFocus ? "#16ffffff" : "transparent"
        border.color: root.activeFocus ? "#88ffffff" : "transparent"
    }

}
