import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "ui" as UI

Item {
    id: root

    property var host: null
    property var model: null

    function t(key) {
        return host ? host.t(key) : key;
    }

    onModelChanged: {
        if (model) {
            model.action("clipboard", []);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Field {
                id: search

                Layout.fillWidth: true
                implicitHeight: 26
                placeholderText: root.t("search")
                leftPadding: 28
                font.pixelSize: 11

                UI.Icon {
                    anchors.left: parent.left
                    anchors.leftMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    name: "search"
                    size: 12
                    opacity: 0.45
                }

            }

            UI.IconButton {
                iconName: "arrow-up-right"
                iconSize: 12
                hint: root.t("clip")
                onClicked: root.host.handoff("omarchy.clipboard")
            }

            UI.IconButton {
                iconName: "refresh-cw"
                iconSize: 12
                hint: root.t("refresh")
                onClicked: root.model.action("clipboard", [])
            }

        }

        ListView {
            id: list

            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 8
            clip: true
            model: (root.model ? root.model.clips : []).filter(function(row) {
                return row.text.toLowerCase().indexOf(search.text.toLowerCase()) >= 0;
            })

            PlainLabel {
                visible: list.count === 0
                anchors.centerIn: parent
                text: root.t("noClips")
                font.pixelSize: 12
                color: "#727279"
            }

            delegate: Surface {
                id: tile

                required property var modelData

                width: 170
                height: list.height

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true

                        UI.Icon {
                            name: tile.modelData.kind === "image" ? "image" : "file-text"
                            size: 11
                            opacity: 0.45
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        UI.Icon {
                            name: "copy"
                            size: 10
                            opacity: 0.35
                        }

                    }

                    PlainLabel {
                        visible: tile.modelData.kind !== "image"
                        text: tile.modelData.text
                        font.pixelSize: 11
                        color: "#c5c5ca"
                        wrapMode: Text.Wrap
                        maximumLineCount: 5
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Image {
                        visible: tile.modelData.kind === "image"
                        source: tile.modelData.kind === "image" ? "file://" + tile.modelData.path : ""
                        sourceSize: Qt.size(240, 160)
                        fillMode: Image.PreserveAspectFit
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.model.action("clipboard-copy", [String(tile.modelData.index)])
                }

            }

        }

    }

}
