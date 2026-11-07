import QtQuick
import QtQuick.Layouts
import ".." as App
import qs.Commons

Item {
    id: root

    property var host: null
    property var model: null
    property int revision: 0
    readonly property var tabs: [{
        "id": "home",
        "icon": "house"
    }, {
        "id": "files",
        "icon": "inbox"
    }, {
        "id": "clipboard",
        "icon": "clipboard-list"
    }, {
        "id": "focus",
        "icon": "timer"
    }, {
        "id": "camera",
        "icon": "camera"
    }, {
        "id": "agents",
        "icon": "sparkles"
    }]
    readonly property int activeIndex: host ? tabs.map(function(x) {
        return x.id;
    }).indexOf(host.currentTab) : 0
    readonly property var selectedItem: {
        var rev = revision;
        return tabItems.itemAt(activeIndex);
    }

    signal moreRequested()

    implicitHeight: 28

    Rectangle {
        x: root.selectedItem ? root.selectedItem.x : 0
        y: 2
        width: root.selectedItem ? root.selectedItem.width : 0
        height: 23
        radius: 6
        color: "#2effffff"
        visible: root.activeIndex >= 0

        Behavior on x {
            NumberAnimation {
                duration: Style.duration(230)
                easing.type: Easing.OutCubic
            }

        }

        Behavior on width {
            NumberAnimation {
                duration: Style.duration(230)
                easing.type: Easing.OutCubic
            }

        }

    }

    Row {
        id: nav

        spacing: 2
        height: 28

        Repeater {
            id: tabItems

            model: root.tabs
            onItemAdded: root.revision++

            Item {
                id: tab

                required property var modelData
                readonly property bool selected: root.host && root.host.currentTab === modelData.id

                width: selected ? content.implicitWidth + 14 : 27
                height: 28
                Accessible.role: Accessible.Button
                Accessible.name: root.host ? root.host.t("nav." + modelData.id) : modelData.id
                Accessible.onPressAction: {
                    if (root.host)
                        root.host.openTab(modelData.id);

                }

                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 2
                    anchors.bottomMargin: 3
                    radius: 6
                    color: "#14ffffff"
                    visible: hover.hovered && !tab.selected
                }

                Row {
                    id: content

                    anchors.centerIn: parent
                    spacing: 4

                    Icon {
                        name: tab.modelData.icon
                        size: 13
                        opacity: tab.selected || hover.hovered ? 1 : 0.5
                    }

                    App.PlainLabel {
                        visible: tab.selected
                        text: root.host ? root.host.t("nav." + tab.modelData.id) : ""
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    App.PlainLabel {
                        visible: tab.modelData.id === "files" && root.model && root.model.shelf.length > 0
                        text: root.model ? root.model.shelf.length : ""
                        font.pixelSize: 8
                        color: "#bfbfc3"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                HoverHandler {
                    id: hover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.host)
                            root.host.openTab(tab.modelData.id);

                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: Style.duration(210)
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

    }

    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 7

        App.PlainLabel {
            text: root.host ? root.host.compactTime : ""
            font.pixelSize: 11
            color: "#b3b3b7"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.host)
                        root.host.openTab("calendar");

                }
            }

        }

        Battery {
            visible: !!root.model && !!root.model.systemBattery
            level: root.model && root.model.systemBattery ? root.model.systemBattery.percent : 0
            charging: !!root.model && !!root.model.systemBattery && root.model.systemBattery.charging
        }

        IconButton {
            iconName: "ellipsis"
            hint: root.host ? root.host.t("more") : "More"
            implicitWidth: 24
            implicitHeight: 24
            onClicked: root.moreRequested()
        }

    }

}
