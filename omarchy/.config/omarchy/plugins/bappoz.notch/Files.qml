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

    function share(files) {
        if (host)
            host.close();

        if (model)
            model.action("share", files || []);

    }

    RowLayout {
        anchors.fill: parent
        spacing: 14

        ColumnLayout {
            Layout.preferredWidth: 130
            Layout.minimumWidth: 130
            Layout.maximumWidth: 130
            Layout.fillWidth: false
            Layout.fillHeight: true
            spacing: 8

            UI.DropZone {
                title: "LocalSend"
                detail: root.t("share")
                iconName: "airplay"
                tint: "#5e9eff"
                Layout.fillWidth: true
                Layout.fillHeight: true
                onActivated: root.share([])
                onFilesDropped: function(urls) {
                    root.share(urls);
                }
            }

            UI.DropZone {
                title: "Instant OCR"
                detail: root.t("copyText")
                iconName: "scan-text"
                tint: "#ab8cff"
                Layout.fillWidth: true
                Layout.fillHeight: true
                onActivated: root.host.runAction(["omarchy-capture-text"])
                onFilesDropped: function(urls) {
                    if (urls.length)
                        root.model.action("ocr", [urls[0]]);

                }
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Canvas {
                visible: !root.model || root.model.shelf.length === 0
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    var c = getContext("2d"), w = width - 2, h = height - 2, r = 14;
                    c.reset();
                    c.beginPath();
                    c.moveTo(r, 1);
                    c.lineTo(w - r, 1);
                    c.quadraticCurveTo(w, 1, w, r);
                    c.lineTo(w, h - r);
                    c.quadraticCurveTo(w, h, w - r, h);
                    c.lineTo(r, h);
                    c.quadraticCurveTo(1, h, 1, h - r);
                    c.lineTo(1, r);
                    c.quadraticCurveTo(1, 1, r, 1);
                    c.strokeStyle = "rgba(255,255,255,.18)";
                    c.lineWidth = 1.2;
                    c.setLineDash([6, 4]);
                    c.stroke();
                }
            }

            Column {
                visible: !root.model || root.model.shelf.length === 0
                anchors.centerIn: parent
                spacing: 7

                UI.Icon {
                    name: "inbox"
                    size: 27
                    opacity: 0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                PlainLabel {
                    text: root.t("drop")
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: "#a1a1a6"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                PlainLabel {
                    text: root.t("dropHint")
                    font.pixelSize: 10
                    color: "#63636a"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

            }

            ColumnLayout {
                visible: !!root.model && root.model.shelf.length > 0
                anchors.fill: parent
                spacing: 4

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    orientation: ListView.Horizontal
                    spacing: 10
                    clip: true
                    model: root.model ? root.model.shelf : []

                    delegate: Item {
                        id: tile

                        required property var modelData

                        width: 86
                        height: 112
                        Drag.active: fileDrag.active
                        Drag.dragType: Drag.Automatic
                        Drag.supportedActions: Qt.CopyAction
                        Drag.mimeData: ({
                            "text/uri-list": String(modelData.url || "")
                        })

                        DragHandler {
                            id: fileDrag

                            target: null
                        }

                        Rectangle {
                            width: 76
                            height: 76
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 12
                            color: "#0dffffff"
                            border.color: "#1fffffff"
                            border.width: 1
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 5
                                source: tile.modelData.image ? tile.modelData.url : ""
                                sourceSize: Qt.size(144, 144)
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            UI.Icon {
                                visible: !tile.modelData.image
                                anchors.centerIn: parent
                                name: "file-text"
                                size: 30
                                opacity: 0.65
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: function(mouse) {
                                    if (mouse.button === Qt.RightButton)
                                        fileMenu.popup();
                                    else
                                        root.model.action("open", [tile.modelData.path]);
                                }
                            }

                        }

                        PlainLabel {
                            y: 82
                            width: parent.width
                            text: modelData.name
                            font.pixelSize: 10
                            color: "#b4b4ba"
                            horizontalAlignment: Text.AlignHCenter
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                        }

                        Menu {
                            id: fileMenu

                            MenuItem {
                                text: root.t("open")
                                onTriggered: root.model.action("open", [tile.modelData.path])
                            }

                            MenuItem {
                                text: root.t("reveal")
                                onTriggered: root.model.action("reveal", [tile.modelData.path])
                            }

                            MenuItem {
                                text: root.t("ocr")
                                onTriggered: root.model.action("ocr", [tile.modelData.path])
                            }

                            MenuItem {
                                text: "WebP"
                                enabled: !!tile.modelData.image
                                onTriggered: root.model.action("convert", [tile.modelData.path, "webp"])
                            }

                            MenuItem {
                                text: "PNG"
                                enabled: !!tile.modelData.image
                                onTriggered: root.model.action("convert", [tile.modelData.path, "png"])
                            }

                            MenuItem {
                                text: "JPEG"
                                enabled: !!tile.modelData.image
                                onTriggered: root.model.action("convert", [tile.modelData.path, "jpg"])
                            }

                            MenuItem {
                                text: root.t("share")
                                onTriggered: root.share([tile.modelData.path])
                            }

                            MenuSeparator {
                            }

                            MenuItem {
                                text: root.t("remove")
                                onTriggered: root.model.action("shelf-remove", [tile.modelData.path])
                            }

                            background: Rectangle {
                                color: "#fa29292b"
                                radius: 9
                                border.color: "#35ffffff"
                                border.width: 1
                            }

                        }

                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    NotchButton {
                        text: root.t("share")
                        plain: true
                        compact: true
                        onClicked: root.share(root.model.shelf.map(function(row) {
                            return row.path;
                        }))
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    NotchButton {
                        text: root.t("clear")
                        plain: true
                        compact: true
                        onClicked: root.model.action("shelf-clear", [])
                    }

                }

            }

            UI.IconButton {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 5
                visible: !root.model || root.model.shelf.length === 0
                iconName: "plus"
                hint: root.t("addFile")
                onClicked: root.model.action("shelf-pick", [])
            }

        }

    }

}
