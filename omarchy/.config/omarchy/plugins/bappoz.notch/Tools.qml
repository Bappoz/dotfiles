import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "ui" as UI

Item {
    id: root

    property var host: null
    property var model: null
    property string mode: "main"
    property int confirmPid: 0

    function t(key) {
        return host ? host.t(key) : key;
    }

    function openMode(name) {
        host.openTab("tools/" + name);
        if (name === "ports")
            model.action("ports", []);

        if (name === "audio")
            model.action("audio-devices", []);

    }

    onModelChanged: {
        if (model) {
            model.action("ports", []);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            NotchButton {
                text: root.t("system")
                iconName: "cpu"
                compact: true
                selected: root.mode === "main"
                accent: "#505052"
                onClicked: root.openMode("main")
            }

            NotchButton {
                text: root.t("ports")
                iconName: "terminal"
                compact: true
                selected: root.mode === "ports"
                accent: "#505052"
                onClicked: root.openMode("ports")
            }

            NotchButton {
                text: root.t("audio")
                iconName: "headphones"
                compact: true
                selected: root.mode === "audio"
                accent: "#505052"
                onClicked: root.openMode("audio")
            }

            NotchButton {
                text: root.t("integrations")
                iconName: "globe"
                compact: true
                selected: root.mode === "extras"
                accent: "#505052"
                onClicked: root.openMode("extras")
            }

            Item {
                Layout.fillWidth: true
            }

            UI.IconButton {
                iconName: "camera"
                hint: root.t("camera")
                onClicked: root.host.openTab("camera")
            }

        }

        Loader {
            visible: root.mode === "extras"
            active: visible
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: Qt.resolvedUrl("Extras.qml")
            onLoaded: {
                item.host = root.host;
                item.model = root.model;
            }
        }

        RowLayout {
            visible: root.mode === "main"
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            ColumnLayout {
                Layout.preferredWidth: 210
                Layout.minimumWidth: 210
                Layout.maximumWidth: 210
                Layout.fillWidth: false
                Layout.fillHeight: true
                spacing: 8

                Surface {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            UI.Icon {
                                name: "cpu"
                                size: 13
                                opacity: 0.55
                            }

                            PlainLabel {
                                text: root.t("system")
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                Layout.fillWidth: true
                            }

                        }

                        RowLayout {
                            Layout.fillWidth: true

                            PlainLabel {
                                text: "CPU"
                                font.pixelSize: 10
                                color: "#85858c"
                                Layout.fillWidth: true
                            }

                            PlainLabel {
                                text: root.model ? (root.model.metrics.cpu || 0) + "%" : "—"
                                font.pixelSize: 19
                                font.weight: Font.DemiBold
                            }

                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 3
                            radius: 2
                            color: "#22ffffff"

                            Rectangle {
                                height: 3
                                radius: 2
                                width: parent.width * (root.model ? (root.model.metrics.cpu || 0) / 100 : 0)
                                color: "#30d158"
                            }

                        }

                        RowLayout {
                            Layout.fillWidth: true

                            PlainLabel {
                                text: root.t("memory")
                                font.pixelSize: 10
                                color: "#85858c"
                                Layout.fillWidth: true
                            }

                            PlainLabel {
                                text: root.model ? (root.model.metrics.memoryGB || 0) + " GB" : "—"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }

                        }

                        Item {
                            Layout.fillHeight: true
                        }

                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    PlainLabel {
                        text: root.t("brightness")
                        font.pixelSize: 9
                        color: "#85858c"
                    }

                    NotchSlider {
                        Layout.fillWidth: true
                        from: 5
                        to: 100
                        value: 50
                        onMoved: root.model.exec(["brightnessctl", "set", Math.round(value) + "%"])
                        Accessible.name: root.t("brightness")
                    }

                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 4
                    columnSpacing: 7
                    rowSpacing: 6

                    Repeater {
                        model: [{
                            "key": "record",
                            "icon": "circle-play",
                            "cmd": ["omarchy-menu", "toggle", "trigger.capture.screenrecord"]
                        }, {
                            "key": "stopRecord",
                            "icon": "power",
                            "cmd": ["omarchy-capture-screenrecording", "--stop-recording"]
                        }, {
                            "key": "reminder",
                            "icon": "timer",
                            "cmd": ["omarchy-reminder", "-i"]
                        }, {
                            "key": "night",
                            "icon": "moon",
                            "cmd": ["omarchy-shell", "nightlight", "toggle"]
                        }, {
                            "key": "dnd",
                            "icon": "bell-off",
                            "cmd": ["omarchy-shell", "notifications", "toggleDnd"]
                        }, {
                            "key": "awake",
                            "icon": "coffee",
                            "cmd": ["omarchy-shell", "idle", "toggle"]
                        }, {
                            "key": "screenOcr",
                            "icon": "scan-text",
                            "cmd": ["omarchy-capture-text"]
                        }, {
                            "key": "language",
                            "icon": "keyboard",
                            "cmd": ["hyprctl", "switchxkblayout", "all", "next"]
                        }]

                        Surface {
                            required property var modelData

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12

                            Column {
                                anchors.centerIn: parent
                                spacing: 7

                                UI.Icon {
                                    name: modelData.icon
                                    size: 17
                                    opacity: 0.8
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                PlainLabel {
                                    text: root.t(modelData.key)
                                    font.pixelSize: 8
                                    color: "#9f9fa5"
                                    width: 78
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.host.runAction(modelData.cmd)
                            }

                        }

                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    NotchButton {
                        text: "Bluetooth"
                        iconName: "bluetooth"
                        compact: true
                        Layout.fillWidth: true
                        onClicked: root.host.handoff("omarchy.bluetooth")
                    }

                    NotchButton {
                        text: root.t("color")
                        iconName: "sliders-horizontal"
                        compact: true
                        Layout.fillWidth: true
                        onClicked: {
                            root.host.close();
                            root.model.action("color", []);
                        }
                    }

                    UI.IconButton {
                        iconName: "share-2"
                        hint: root.t("share")
                        onClicked: {
                            root.host.close();
                            root.model.action("share", []);
                        }
                    }

                    UI.IconButton {
                        iconName: "refresh-cw"
                        hint: root.t("update")
                        onClicked: root.host.runAction(["omarchy-launch-floating-terminal-with-presentation", "omarchy-update"])
                    }

                    UI.IconButton {
                        iconName: "power"
                        hint: root.t("sudo")
                        onClicked: root.host.runAction(["omarchy-launch-floating-terminal-with-presentation", "omarchy-sudo-passwordless"])
                    }

                }

            }

        }

        ListView {
            visible: root.mode === "ports"
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5
            clip: true
            model: root.model ? root.model.ports : []

            ScrollBar.vertical: ScrollBar {
            }

            delegate: Surface {
                required property var modelData

                width: ListView.view.width
                height: 42
                radius: 10

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8

                    PlainLabel {
                        text: ":" + modelData.port
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        Layout.preferredWidth: 66
                    }

                    PlainLabel {
                        text: modelData.name + " · " + modelData.address
                        font.pixelSize: 10
                        color: "#8e8e93"
                        Layout.fillWidth: true
                    }

                    NotchButton {
                        text: root.confirmPid === modelData.pid ? root.t("confirmStop") : root.t("stop")
                        compact: true
                        destructive: true
                        enabled: modelData.pid > 0
                        onClicked: {
                            if (root.confirmPid === modelData.pid) {
                                root.model.action("port-stop", [String(modelData.pid), String(modelData.port)]);
                                root.confirmPid = 0;
                                root.model.action("ports", []);
                            } else {
                                root.confirmPid = modelData.pid;
                            }
                        }
                    }

                }

            }

        }

        ListView {
            visible: root.mode === "audio"
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            clip: true
            model: root.model ? root.model.audioDevices : []

            delegate: NotchButton {
                required property var modelData

                width: ListView.view.width
                text: modelData.name
                iconName: "headphones"
                onClicked: root.model.action("audio-set", [modelData.id])
            }

        }

    }

}
