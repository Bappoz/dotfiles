import QtQuick
import QtQuick.Effects

Item {
    id: root

    property string name: "sparkles"
    property color color: "white"
    property int size: 16

    implicitWidth: size
    implicitHeight: size

    Image {
        anchors.fill: parent
        source: root.name ? Qt.resolvedUrl("../assets/icons/" + root.name + ".svg") : ""
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        fillMode: Image.PreserveAspectFit
        layer.enabled: root.color !== Qt.rgba(1, 1, 1, 1)

        layer.effect: MultiEffect {
            colorization: 1
            colorizationColor: root.color
        }

    }

}
