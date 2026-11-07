import QtQuick
import QtQuick.Effects
import qs.Commons

Item {
    id: root

    property url artwork: ""
    property bool playing: false
    property bool motionEnabled: true
    property real phase: 0
    property bool tonearm: true

    signal activated()

    implicitWidth: 112
    implicitHeight: 112

    Item {
        id: disc

        width: parent.width * 0.94
        height: width
        anchors.centerIn: parent
        rotation: root.phase

        FrameAnimation {
            running: root.visible && root.playing && root.motionEnabled
            onTriggered: root.phase = (root.phase + 45 * frameTime) % 360
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            border.width: 1
            border.color: "#28282a"

            Repeater {
                model: [0.94, 0.86, 0.78, 0.7, 0.62, 0.54]

                Rectangle {
                    required property real modelData

                    anchors.centerIn: parent
                    width: parent.width * modelData
                    height: width
                    radius: width / 2
                    color: "transparent"
                    border.width: 1
                    border.color: "#12ffffff"
                }

            }

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: "#252527"
                }

                GradientStop {
                    position: 0.46
                    color: "#101012"
                }

                GradientStop {
                    position: 1
                    color: "#262629"
                }

            }

        }

        Rectangle {
            id: label

            anchors.centerIn: parent
            width: parent.width * 0.42
            height: width
            radius: width / 2
            color: "#bfc7b6"
            clip: true

            Image {
                anchors.fill: parent
                source: root.artwork
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(128, 128)
                visible: root.artwork.toString() !== ""
                layer.enabled: true

                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: circleMask
                }

            }

            Item {
                id: circleMask

                anchors.fill: parent
                layer.enabled: true
                visible: false

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "white"
                }

            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.artwork.toString() === "" ? "#a2bca5" : "transparent"
                opacity: 0.35
            }

        }

        Rectangle {
            anchors.centerIn: parent
            width: 5
            height: 5
            radius: 3
            color: "#050506"
            border.color: "#555555"
            border.width: 1
        }

    }

    Item {
        visible: root.tonearm
        x: parent.width * 0.84
        y: parent.height * 0.01
        width: 15
        height: parent.height * 0.66

        Rectangle {
            x: 0
            y: 0
            width: 15
            height: 15
            radius: 8
            border.color: "#70ffffff"
            border.width: 1

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#a5a5a6"
                }

                GradientStop {
                    position: 0.5
                    color: "#4b4b4e"
                }

                GradientStop {
                    position: 1
                    color: "#212124"
                }

            }

        }

        Rectangle {
            x: 5.5
            y: 5.5
            width: 4
            height: 4
            radius: 2
            color: "#343437"
        }

        Item {
            x: 6
            y: 7
            width: 6
            height: root.height * 0.46
            rotation: root.playing ? 28 : 2
            transformOrigin: Item.Top

            Rectangle {
                x: 1.5
                width: 2.2
                height: root.height * 0.46
                radius: 1.1

                gradient: Gradient {
                    orientation: Gradient.Horizontal

                    GradientStop {
                        position: 0
                        color: "#dfdfe0"
                    }

                    GradientStop {
                        position: 0.5
                        color: "#99999c"
                    }

                    GradientStop {
                        position: 1
                        color: "#cccccf"
                    }

                }

            }

            Rectangle {
                x: 0
                y: root.height * 0.46 - 3
                width: 5
                height: 10
                radius: 1.5
                color: "#2a2a2e"
                border.color: "#66ffffff"
                border.width: 1

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -2
                    width: 2.5
                    height: 2.5
                    radius: 2
                    color: "#f24740"
                }

            }

            Behavior on rotation {
                NumberAnimation {
                    duration: root.motionEnabled ? Style.duration(550) : 0
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.32, 1.25, 0.45, 1, 1, 1]
                }

            }

        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

}
