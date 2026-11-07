import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "ui" as UI

Item {
    id: root

    property var host: null
    property var model: null
    property string mode: "main"
    property string section: "appearance"
    readonly property var styles: [{
        "id": "fluid",
        "name": "Fluid Classic",
        "icon": "waves"
    }, {
        "id": "bouncy",
        "name": "Bouncy Island",
        "icon": "circle-dot"
    }, {
        "id": "waterfall",
        "name": "Waterfall Drop",
        "icon": "arrow-down-to-line"
    }, {
        "id": "snappy",
        "name": "Snappy Pro",
        "icon": "zap"
    }, {
        "id": "pop",
        "name": "Elastic Pop",
        "icon": "circle-play"
    }, {
        "id": "gentle",
        "name": "Gentle Float",
        "icon": "wind"
    }, {
        "id": "flip3D",
        "name": "3D Trapdoor Flip",
        "icon": "box"
    }, {
        "id": "depth3D",
        "name": "Holographic Depth",
        "icon": "layers"
    }, {
        "id": "cube3D",
        "name": "3D Cube Roll",
        "icon": "package"
    }]

    function t(key) {
        return host ? host.t(key) : key;
    }

    onModeChanged: section = mode === "connections" ? "connections" : "appearance"

    RowLayout {
        anchors.fill: parent
        spacing: 18

        Rectangle {
            Layout.preferredWidth: 140
            Layout.minimumWidth: 140
            Layout.maximumWidth: 140
            Layout.fillWidth: false
            Layout.fillHeight: true
            radius: 12
            color: "#08ffffff"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 3

                PlainLabel {
                    text: "OpenNotchi"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    Layout.leftMargin: 8
                    Layout.topMargin: 9
                    Layout.bottomMargin: 12
                }

                Repeater {
                    model: [{
                        "id": "appearance",
                        "icon": "sliders-horizontal",
                        "key": "appearance"
                    }, {
                        "id": "connections",
                        "icon": "globe",
                        "key": "connect"
                    }, {
                        "id": "about",
                        "icon": "circle-help",
                        "key": "aboutLabel"
                    }]

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 29
                        radius: 7
                        color: root.section === modelData.id ? "#20ffffff" : "transparent"

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 8
                            spacing: 7

                            UI.Icon {
                                name: modelData.icon
                                size: 13
                                opacity: root.section === modelData.id ? 1 : 0.5
                            }

                            PlainLabel {
                                text: root.t(modelData.key)
                                font.pixelSize: 10
                                anchors.verticalCenter: parent.verticalCenter
                                color: root.section === modelData.id ? "white" : "#929298"
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.section = modelData.id
                        }

                    }

                }

                Item {
                    Layout.fillHeight: true
                }

                PlainLabel {
                    text: "for Omarchy"
                    font.pixelSize: 9
                    color: "#626268"
                    Layout.leftMargin: 8
                    Layout.bottomMargin: 7
                }

            }

        }

        Loader {
            visible: root.section === "connections"
            active: visible
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: Qt.resolvedUrl("Connections.qml")
            onLoaded: {
                item.host = root.host;
                item.model = root.model;
            }
        }

        Flickable {
            visible: root.section === "appearance"
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: appearance.implicitHeight
            clip: true

            ColumnLayout {
                id: appearance

                width: parent.width
                spacing: 13

                PlainLabel {
                    text: root.t("appearance")
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }

                PlainLabel {
                    text: root.t("theme")
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#a5a5ac"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [{
                            "id": "glass",
                            "name": "Liquid Glass",
                            "fill": "#b5323236"
                        }, {
                            "id": "midnight",
                            "name": "Classic Black",
                            "fill": "#000000"
                        }, {
                            "id": "frosted",
                            "name": "Frosted",
                            "fill": "#ee3b3b3f"
                        }]

                        Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: 57
                            radius: 10
                            color: modelData.fill
                            border.width: 1
                            border.color: root.host && root.host.theme === modelData.id ? "#aaffffff" : "#26ffffff"

                            Column {
                                anchors.centerIn: parent
                                spacing: 7

                                Rectangle {
                                    width: 36
                                    height: 12
                                    radius: 6
                                    color: "#80ffffff"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                PlainLabel {
                                    text: modelData.name
                                    font.pixelSize: 10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.model.action("setting", ["theme", modelData.id])
                            }

                        }

                    }

                }

                PlainLabel {
                    text: root.t("animationStyle")
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#a5a5ac"
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 7
                    rowSpacing: 7

                    Repeater {
                        model: root.styles

                        Rectangle {
                            required property var modelData
                            readonly property bool selected: !!root.host && root.host.animationStyle === modelData.id

                            Layout.fillWidth: true
                            Layout.preferredHeight: 49
                            radius: 9
                            color: selected ? "#24ffffff" : "#0dffffff"
                            border.color: selected ? "#80ffffff" : "#14ffffff"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                UI.Icon {
                                    name: modelData.icon
                                    size: 14
                                    opacity: parent.parent.selected ? 1 : 0.55
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                PlainLabel {
                                    text: modelData.name
                                    font.pixelSize: 8
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: parent.parent.selected ? "white" : "#9999a0"
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.model.action("setting", ["animationStyle", modelData.id], function(data) {
                                    if (data.ok)
                                        root.host.replay();

                                })
                            }

                        }

                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    PlainLabel {
                        text: root.t("motion")
                        font.pixelSize: 11
                        Layout.fillWidth: true
                    }

                    NotchSwitch {
                        checked: !!root.host && root.host.motion
                        Accessible.name: root.t("motion")
                        onToggled: root.model.action("setting", ["animations", String(checked)])
                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    PlainLabel {
                        text: root.t("hover")
                        font.pixelSize: 11
                        Layout.fillWidth: true
                    }

                    NotchSwitch {
                        checked: !!root.host && root.host.hoverEnabled
                        Accessible.name: root.t("hover")
                        onToggled: root.model.action("setting", ["hover", String(checked)])
                    }

                }

                PlainLabel {
                    text: root.t("shortcuts")
                    font.pixelSize: 9
                    color: "#6f6f76"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

            }

            ScrollBar.vertical: ScrollBar {
            }

        }

        ColumnLayout {
            visible: root.section === "about"
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            UI.Icon {
                name: "sparkles"
                size: 32
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 32
            }

            PlainLabel {
                text: "OpenNotchi for Omarchy"
                font.pixelSize: 19
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter
            }

            PlainLabel {
                text: root.t("about")
                font.pixelSize: 11
                color: "#929298"
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            NotchButton {
                text: root.t("attribution")
                iconName: "arrow-up-right"
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.model.exec(["xdg-open", "https://github.com/nannndev/OpenNotchi"])
            }

            Item {
                Layout.fillHeight: true
            }

        }

    }

}
