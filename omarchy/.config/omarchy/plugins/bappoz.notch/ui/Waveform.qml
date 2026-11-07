import QtQuick

Item {
    id: root

    property bool playing: false
    property bool motionEnabled: true
    property real phase: 0
    property color color: "white"
    property int barCount: 5
    property real maximumHeight: height

    implicitWidth: 26
    implicitHeight: 20

    FrameAnimation {
        running: root.visible && root.playing && root.motionEnabled
        onTriggered: root.phase += frameTime
    }

    Row {
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: root.barCount

            Item {
                required property int index

                width: 3
                height: root.maximumHeight

                Rectangle {
                    // FrameAnimation already supplies a new height each frame.
                    // A second animation here restarts before its first tick,
                    // freezing the bars at their initial height on fast displays.

                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    radius: 2
                    height: root.playing ? Math.max(4, root.maximumHeight * (0.35 + 0.65 * Math.abs(Math.sin(root.phase * (3 + index * 0.7) + index * 1.3)))) : 4
                    color: root.color
                    opacity: root.playing ? 0.9 : 0.35
                }

            }

        }

    }

}
