import QtQuick
import QtQuick.Controls

Slider {
    id: root

    implicitHeight: 16
    leftPadding: 0
    rightPadding: 0

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: root.pressed ? 6 : 3.5
        radius: height / 2
        color: "#33ffffff"

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: height / 2
            color: root.enabled ? "white" : "#66666a"
        }

    }

    handle: Item {
        implicitWidth: 1
        implicitHeight: 1
    }

}
