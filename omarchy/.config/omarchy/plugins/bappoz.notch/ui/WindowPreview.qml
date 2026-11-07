import QtQuick
import Quickshell.Wayland
import ".." as App

Item {
    id: root

    property int selected: 0
    readonly property var windows: ToplevelManager.toplevels.values

    implicitWidth: 199
    implicitHeight: 112

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#09090b"
        clip: true

        ScreencopyView {
            id: copy

            anchors.fill: parent
            captureSource: root.visible && root.windows.length ? root.windows[root.selected % root.windows.length] : null
            live: root.visible
            paintCursor: false
            constraintSize: Qt.size(width * 1.5, height * 1.5)
        }

        App.PlainLabel {
            visible: !copy.hasContent
            anchors.centerIn: parent
            text: "Preview"
            color: "#77777b"
            font.pixelSize: 10
        }

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: "transparent"
            border.color: "#2affffff"
            border.width: 1
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.selected++
        }

    }

}
