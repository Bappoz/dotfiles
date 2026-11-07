import QtQuick
import QtQuick.Layouts
import ".." as App

Rectangle {
    id: root

    property string iconName: "airplay"
    property string title: ""
    property string detail: ""
    property color tint: "#5e9eff"
    property bool targeted: false

    signal activated()
    signal filesDropped(var urls)

    radius: 14
    color: Qt.rgba(tint.r, tint.g, tint.b, targeted ? 0.18 : 0.07)
    border.color: Qt.rgba(tint.r, tint.g, tint.b, targeted ? 0.9 : 0.23)
    border.width: 1

    Column {
        anchors.centerIn: parent
        spacing: 3

        Icon {
            name: root.iconName
            size: 21
            color: root.tint
            anchors.horizontalCenter: parent.horizontalCenter
        }

        App.PlainLabel {
            text: root.title
            font.pixelSize: 11
            font.weight: Font.Medium
            anchors.horizontalCenter: parent.horizontalCenter
        }

        App.PlainLabel {
            visible: root.detail !== ""
            text: root.detail
            font.pixelSize: 8
            color: "#7d7d83"
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    DropArea {
        anchors.fill: parent
        onEntered: function(drag) {
            root.targeted = drag.hasUrls;
        }
        onExited: root.targeted = false
        onDropped: function(drop) {
            root.targeted = false;
            if (drop.hasUrls) {
                root.filesDropped(drop.urls.map(String));
                drop.acceptProposedAction();
            }
        }
    }

}
