import QtQuick
import QtQuick.Controls
import qs.Commons
import ".." as App

AbstractButton {
    id: root

    property bool selected: false
    property color swatch: "#363638"
    property string iconName: ""
    property string hint: ""

    implicitWidth: 30
    implicitHeight: 30
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: hint
    Accessible.role: Accessible.RadioButton
    Accessible.checkable: true
    Accessible.checked: selected
    Keys.onReturnPressed: clicked()
    ToolTip.visible: hovered && hint !== ""
    ToolTip.text: hint
    ToolTip.delay: 350
    scale: down ? 0.93 : 1

    Behavior on scale {
        NumberAnimation {
            duration: Style.duration(120)
            easing.type: Easing.OutCubic
        }

    }

    background: Rectangle {
        radius: width / 2
        color: "transparent"
        border.width: root.selected || root.activeFocus ? 2 : 1
        border.color: root.selected || root.activeFocus ? "#f4f4f5" : root.hovered ? "#65ffffff" : "#22ffffff"

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: width / 2
            color: root.swatch
        }

    }

    contentItem: Item {
        Icon {
            anchors.centerIn: parent
            visible: root.iconName !== ""
            name: root.iconName
            size: 12
            opacity: root.selected ? 1 : 0.6
        }

    }

}
