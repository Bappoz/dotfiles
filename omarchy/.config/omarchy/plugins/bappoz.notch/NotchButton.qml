import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import "ui" as UI
import "ui/IconMap.js" as Icons

AbstractButton {
    id: root

    property string glyph: ""
    property string iconName: Icons.resolve(glyph)
    property bool selected: false
    property bool destructive: false
    property bool compact: false
    property bool plain: false
    property color accent: "#ffffff"
    readonly property bool darkContent: selected && accent.r > 0.9 && accent.g > 0.5

    Accessible.name: text
    Accessible.role: Accessible.Button
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitWidth: Math.max(compact ? 26 : 60, row.implicitWidth + (compact ? 16 : 22))
    implicitHeight: compact ? 24 : 28
    scale: down ? 0.97 : 1
    Keys.onReturnPressed: clicked()

    Behavior on scale {
        NumberAnimation {
            duration: Style.duration(130)
            easing.type: Easing.OutCubic
        }

    }

    contentItem: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        Row {
            id: row

            anchors.centerIn: parent
            spacing: 5

            UI.Icon {
                visible: root.iconName !== ""
                name: root.iconName
                size: root.compact ? 12 : 13
                color: root.darkContent ? "#000000" : root.destructive ? "#ff6961" : "#ffffff"
                opacity: root.enabled ? 1 : 0.3
                anchors.verticalCenter: parent.verticalCenter
            }

            PlainLabel {
                visible: root.text !== ""
                text: root.text
                font.pixelSize: root.compact ? 10 : 11
                font.weight: Font.Medium
                color: root.darkContent ? "#000000" : root.destructive ? "#ff6961" : "#efeff1"
                opacity: root.enabled ? 1 : 0.3
                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }

    background: Rectangle {
        radius: height / 2
        color: root.selected ? root.accent : root.hovered ? "#20ffffff" : root.plain ? "transparent" : "#14ffffff"
        border.color: root.activeFocus ? "#99ffffff" : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Style.duration(100)
            }

        }

    }

}
