import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "ui" as UI

Item {
    id: root

    property var host: null
    property var model: null
    property string provider: ""
    readonly property var agents: model ? model.agents : []
    readonly property int limitCount: agents.reduce(function(sum, row) {
        return sum + row.limits.length;
    }, 0)

    function t(key) {
        return host ? host.t(key) : key;
    }

    function providerIcon(id) {
        var key = String(id).toLowerCase();
        return key.indexOf("claude") >= 0 ? "claude" : key.indexOf("codex") >= 0 ? "codex" : key === "agy" || key.indexOf("antigravity") >= 0 ? "antigravity" : key.indexOf("command") >= 0 ? "commandcode" : "";
    }

    function resetText(value) {
        var end = new Date(value).getTime() / 1000, now = model ? model.now : Date.now() / 1000;
        if (!isFinite(end) || end < now)
            return "";

        var m = Math.ceil((end - now) / 60);
        return t("resetsIn").arg(m >= 1440 ? Math.floor(m / 1440) + "d " + Math.floor(m % 1440 / 60) + "h" : m >= 60 ? Math.floor(m / 60) + "h " + m % 60 + "m" : m + "m");
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Surface {
                implicitHeight: 27
                implicitWidth: 284
                radius: 14

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 3

                    NotchButton {
                        text: root.t("quotaAccounts")
                        iconName: "chart-no-axes-combined"
                        compact: true
                        selected: true
                        accent: "#505052"
                        Layout.fillWidth: true
                        onClicked: root.provider = ""
                    }

                    NotchButton {
                        text: root.t("agents")
                        iconName: "cpu"
                        compact: true
                        plain: true
                        Layout.fillWidth: true
                        onClicked: root.host.handoff("omarchy.agents")
                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            NotchButton {
                text: root.t("expand")
                iconName: "maximize-2"
                compact: true
                onClicked: root.host.handoff("omarchy.agents")
            }

        }

        Surface {
            Layout.fillWidth: true
            Layout.preferredHeight: 37
            radius: 10

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 16

                Rectangle {
                    implicitWidth: omarchy.implicitWidth + 16
                    implicitHeight: 21
                    radius: 10
                    color: "#1430d158"

                    PlainLabel {
                        id: omarchy

                        anchors.centerIn: parent
                        text: "● Omarchy (" + root.agents.length + ")"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: "#30d158"
                    }

                }

                Column {
                    spacing: 1

                    PlainLabel {
                        text: root.t("providers").toUpperCase()
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        color: "#77777c"
                    }

                    PlainLabel {
                        text: root.agents.length
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                }

                Column {
                    spacing: 1

                    PlainLabel {
                        text: root.t("limits").toUpperCase()
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        color: "#77777c"
                    }

                    PlainLabel {
                        text: root.limitCount
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                }

                Column {
                    spacing: 1

                    PlainLabel {
                        text: root.t("source").toUpperCase()
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        color: "#77777c"
                    }

                    PlainLabel {
                        text: root.t("local")
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#30d158"
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                NotchButton {
                    text: root.t("refresh")
                    iconName: "refresh-cw"
                    compact: true
                    onClicked: root.model.refresh()
                }

            }

        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            NotchButton {
                text: root.t("all") + "  " + root.agents.length
                compact: true
                selected: root.provider === ""
                accent: "#505052"
                onClicked: root.provider = ""
            }

            Repeater {
                model: root.agents

                NotchButton {
                    required property var modelData

                    text: modelData.name
                    compact: true
                    selected: root.provider === modelData.id
                    accent: "#505052"
                    Layout.maximumWidth: 120
                    onClicked: root.provider = modelData.id
                }

            }

            Item {
                Layout.fillWidth: true
            }

        }

        ListView {
            id: cards

            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 9
            clip: true
            model: root.agents.filter(function(row) {
                return root.provider === "" || row.id === root.provider;
            })

            PlainLabel {
                visible: cards.count === 0
                anchors.centerIn: parent
                width: parent.width - 50
                text: root.t("noAgents")
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                color: "#77777c"
            }

            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: Surface {
                id: card

                required property var modelData

                width: Math.floor((cards.width - 18) / 3)
                height: cards.height
                radius: 14
                border.color: "#2830d158"
                color: "#080a09"
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 7

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 6
                            color: "#16ffffff"

                            Image {
                                anchors.fill: parent
                                anchors.margins: 3
                                source: root.providerIcon(card.modelData.id) !== "" ? Qt.resolvedUrl("assets/providers/" + root.providerIcon(card.modelData.id) + ".png") : ""
                                sourceSize: Qt.size(48, 48)
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            UI.Icon {
                                visible: root.providerIcon(card.modelData.id) === ""
                                anchors.centerIn: parent
                                name: "sparkles"
                                size: 14
                                color: "#b1a0df"
                            }

                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            PlainLabel {
                                text: card.modelData.name
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                Layout.fillWidth: true
                            }

                            PlainLabel {
                                text: root.t("quota")
                                font.pixelSize: 9
                                color: "#8e8e93"
                            }

                        }

                        Rectangle {
                            width: 28
                            height: 14
                            radius: 7
                            color: "#1830d158"

                            PlainLabel {
                                anchors.centerIn: parent
                                text: "● ON"
                                font.pixelSize: 7
                                font.weight: Font.Bold
                                color: "#30d158"
                            }

                        }

                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentHeight: limits.implicitHeight

                        ColumnLayout {
                            id: limits

                            width: parent.width
                            spacing: 7

                            Repeater {
                                model: card.modelData.limits

                                ColumnLayout {
                                    id: quotaLine

                                    required property var modelData
                                    readonly property int remainingPercent: Math.max(0, Math.round(100 - modelData.percent))
                                    readonly property color tint: remainingPercent > 20 ? "#30d158" : remainingPercent > 8 ? "#ff9f0a" : "#ff453a"

                                    Layout.fillWidth: true
                                    spacing: 3

                                    RowLayout {
                                        Layout.fillWidth: true

                                        PlainLabel {
                                            text: modelData.label
                                            font.pixelSize: 9
                                            color: "#929297"
                                            Layout.fillWidth: true
                                        }

                                        PlainLabel {
                                            text: quotaLine.remainingPercent + "% " + root.t("left")
                                            font.pixelSize: 9
                                            font.weight: Font.DemiBold
                                            color: quotaLine.tint
                                        }

                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 4
                                        radius: 2
                                        color: "#24ffffff"

                                        Rectangle {
                                            width: parent.width * quotaLine.remainingPercent / 100
                                            height: 4
                                            radius: 2
                                            color: quotaLine.tint
                                        }

                                    }

                                    PlainLabel {
                                        text: root.resetText(modelData.resetsAt)
                                        visible: text !== ""
                                        font.pixelSize: 8
                                        color: "#a8a8ae"
                                        Layout.fillWidth: true
                                    }

                                }

                            }

                        }

                    }

                    NotchButton {
                        text: root.t("agentFull")
                        plain: true
                        compact: true
                        Layout.fillWidth: true
                        onClicked: root.host.handoff("omarchy.agents")
                    }

                }

            }

        }

    }

}
