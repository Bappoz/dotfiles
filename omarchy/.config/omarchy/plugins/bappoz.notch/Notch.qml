import "." as Local
import "ui" as UI
import "ui/Motion.js" as Motion
import "ui/CardTransform.js" as CardTransform
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
    id: root

    readonly property var model: Local.Runtime.model
    readonly property var player: model ? model.player : null
    property bool opened: false
    property bool held: false
    property bool replayPinned: false
    property bool grabReady: false
    property bool focusPrimed: false
    property string currentTab: "home"
    property string subtab: ""
    property int direction: 1
    readonly property var tabs: ["home", "files", "clipboard", "focus", "camera", "agents", "calendar", "tools"]
    readonly property bool motion: setting("animations", true) && (!model || model.preferences.animations !== "false")
    readonly property string theme: model && model.preferences.theme ? model.preferences.theme : setting("theme", "glass")
    readonly property string animationStyle: model && model.preferences.animationStyle ? model.preferences.animationStyle : setting("animationStyle", "fluid")
    readonly property var animationProfile: Motion.profile(animationStyle)
    readonly property bool spatial: animationStyle.indexOf("3D") >= 0
    readonly property bool hoverEnabled: !model || model.preferences.hover !== "false"
    readonly property string screenName: pill.QsWindow.window && pill.QsWindow.window.screen ? pill.QsWindow.window.screen.name : ""
    readonly property bool focusedScreen: !Hyprland.focusedMonitor || Hyprland.focusedMonitor.name === screenName
    readonly property string compactTime: clock.date.toLocaleTimeString(Qt.locale(I18n.formatLocale), "HH:mm")
    readonly property string compactDate: clock.date.toLocaleDateString(Qt.locale(I18n.formatLocale), "ddd, d MMM")
    readonly property int expandedWidth: currentTab === "agents" ? 748 : 708
    readonly property int expandedHeight: Math.min(Motion.height(currentTab, subtab), window.height - 40)
    readonly property int pillWidth: model && model.remaining > 0 ? 284 : 268
    readonly property bool pageReady: page.status === Loader.Ready
    readonly property bool pageError: page.status === Loader.Error
    property real reveal: opened ? 1 : 0
    readonly property real progress: Math.max(0, Math.min(1, reveal))

    function t(key) {
        return strings.t(key);
    }

    function openOnFocusedScreen() {
        if (focusedScreen) {
            held = true;
            open();
        }
    }

    function toggleOnFocusedScreen() {
        if (focusedScreen)
            toggle();

    }

    function showRequestedTab() {
        if (focusedScreen) {
            held = true;
            openTab(model ? model.requestedTab : "home");
        }

    }

    function open() {
        if (opened)
            return ;

        if (bar && bar.requestPopout)
            bar.requestPopout(root);

        opened = true;
        if (model)
            model.expanded(true);

    }

    function close() {
        if (!opened)
            return ;

        opened = false;
        held = false;
        if (model)
            model.expanded(false);

        if (bar && bar.releasePopout)
            bar.releasePopout(root);

    }

    function toggle() {
        if (opened) {
            close();
        } else {
            held = true;
            open();
        }
    }

    function openTab(tab) {
        var parts = String(tab).split("/");
        if (parts[0] === "tools" && parts[1] === "camera")
            parts = ["camera"];

        var next = tabs.indexOf(parts[0]) >= 0 || parts[0] === "settings" ? parts[0] : "home";
        direction = tabs.indexOf(next) >= tabs.indexOf(currentTab) ? 1 : -1;
        subtab = parts[1] || "";
        currentTab = next;
        // Navigation preserves whether the panel was opened by hover or pinned.
        moreMenu.close();
        open();
        Qt.callLater(page.inject);
        if (!held) leaveTimer.restart();
    }

    function replay() {
        replayPinned = held;
        close();
        replayTimer.restart();
    }

    function handoff(id) {
        close();
        if (model)
            model.panel(id);

    }

    function runAction(args) {
        close();
        if (model)
            model.exec(args);

    }

    moduleName: "bappoz.notch"
    implicitWidth: pillWidth
    implicitHeight: barSize
    onOpenedChanged: {
        grabReady = false;
        focusPrimed = false;
        if (opened)
            primeTimer.restart();
        else
            moreMenu.close();
    }
    onHeldChanged: {
        if (held && opened) {
            primeTimer.restart();
        } else if (opened) {
            leaveTimer.restart();
        }
    }
    Component.onDestruction: {
        if (opened && model) {
            model.expanded(false);
        }
    }

    ShellIpc {
        target: "bappoz.notch"

        function open(): void { root.broadcast("openOnFocusedScreen"); }
        function close(): void { root.broadcast("close"); }
        function toggle(): void { root.broadcast("toggleOnFocusedScreen"); }
        function tab(name: string): void {
            if (root.model) root.model.requestedTab = name;
            root.broadcast("showRequestedTab");
        }
        function status(): string {
            var widgets = root.bar && root.bar.moduleWidgets
                ? root.bar.moduleWidgets(root.moduleName) : [root];
            return JSON.stringify({
                opened: root.opened, tab: root.currentTab, screen: root.screenName,
                service: !!root.model, pageReady: root.pageReady, pageError: root.pageError,
                pageMode: page.item && "mode" in page.item ? page.item.mode : "",
                pageHasModel: !!page.item && !!page.item.model,
                animation: root.animationStyle, width: card.width, height: card.height,
                instances: widgets.map(function(widget) {
                    return {screen: widget.screenName, opened: widget.opened,
                        tab: widget.currentTab, pageReady: widget.pageReady,
                        pageError: widget.pageError};
                })
            });
        }
    }

    Translations {
        id: strings

        directory: Qt.resolvedUrl("i18n")
    }

    QtObject {
        id: clock

        property date date: new Date()
    }

    Timer {
        interval: Math.max(50, 60000 - Date.now() % 60000)
        running: true
        repeat: false
        onTriggered: {
            clock.date = new Date();
            interval = Math.max(50, 60000 - Date.now() % 60000);
            restart();
        }
    }

    Timer {
        id: replayTimer

        interval: 350
        onTriggered: {
            root.held = root.replayPinned;
            root.open();
            if (!root.held) leaveTimer.restart();
        }
    }

    Item {
        id: pill

        anchors.fill: parent
        opacity: 1 - root.progress

        NotchShape {
            anchors.fill: parent
            topRadius: 6
            bottomRadius: 10
            fill: root.theme === "midnight" ? "#000000" : "#ed09090b"
            stroke: "#22ffffff"
            glass: false
        }

        UI.Vinyl {
            width: 22
            height: 22
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            tonearm: false
            playing: !!root.player && root.player.isPlaying
            artwork: root.player ? root.player.trackArtUrl : ""
            motionEnabled: root.motion
        }

        PlainLabel {
            anchors.centerIn: parent
            text: root.model && root.model.remaining > 0 ? root.compactTime + "  ·  " + root.model.countdown : root.compactTime + "  ·  " + root.compactDate
            font.pixelSize: 10
            font.weight: Font.Medium
            color: "#d1d1d6"
        }

        UI.Waveform {
            x: parent.width - width - 17
            anchors.verticalCenter: parent.verticalCenter
            width: 23
            height: 18
            maximumHeight: 18
            playing: !!root.player && root.player.isPlaying
            motionEnabled: root.motion
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                if (root.hoverEnabled) {
                    hoverTimer.restart();
                }
            }
            onExited: hoverTimer.stop()
            onClicked: root.toggle()
            onWheel: function(event) {
                if (root.model)
                    root.model.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", event.angleDelta.y > 0 ? "2%+" : "2%-"]);

            }
        }

    }

    Timer {
        id: primeTimer

        interval: 100
        onTriggered: {
            root.focusPrimed = true;
            root.grabReady = true;
            card.forceActiveFocus();
        }
    }

    Timer {
        id: hoverTimer

        interval: Math.max(100, Math.min(1000, Number(root.setting("hoverDelay", 150))))
        onTriggered: {
            if (root.hoverEnabled) {
                root.open();
            }
        }
    }

    Timer {
        id: leaveTimer

        interval: 330
        onTriggered: {
            if (!root.held && !surfaceHover.hovered && !moreMenu.visible) {
                root.close();
            }
        }
    }

    PanelWindow {
        id: window

        screen: pill.QsWindow.window ? pill.QsWindow.window.screen : null
        visible: root.opened || root.progress > 0.001 || revealAnimation.running
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "bappoz-notch"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.opened ? (root.held && !root.focusPrimed ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand) : WlrKeyboardFocus.None

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        HyprlandFocusGrab {
            windows: pill.QsWindow.window ? [window, pill.QsWindow.window] : [window]
            active: root.opened && root.held && root.grabReady
            onCleared: root.close()
        }

        Item {
            id: card

            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            width: root.spatial ? Math.min(root.expandedWidth, window.width - 24) : root.pillWidth + (Math.min(root.expandedWidth, window.width - 24) - root.pillWidth) * root.reveal
            height: root.spatial ? root.expandedHeight : root.barSize + (root.expandedHeight - root.barSize) * root.reveal
            clip: true
            opacity: root.spatial ? Math.min(1, root.progress * 3) : 1
            focus: root.opened
            Keys.onEscapePressed: root.close()
            Keys.onPressed: function(event) {
                if ((event.modifiers & Qt.ControlModifier) && event.key >= Qt.Key_1 && event.key <= Qt.Key_8) {
                    root.openTab(root.tabs[event.key - Qt.Key_1]);
                    event.accepted = true;
                }
            }

            NotchShape {
                id: background

                anchors.fill: parent
                topRadius: 14
                bottomRadius: 30
                fill: root.theme === "midnight" ? "#000000" : root.theme === "frosted" ? "#ee252527" : "#d51c1c1e"
                glass: root.theme !== "midnight"
                stroke: root.theme === "midnight" ? "#24ffffff" : "#46ffffff"
            }

            HoverHandler {
                id: surfaceHover

                onHoveredChanged: {
                    if (hovered) {
                        leaveTimer.stop();
                    } else {
                        leaveTimer.restart();
                    }
                }
            }

            DropArea {
                anchors.fill: parent
                onEntered: function(drag) {
                    if (drag.hasUrls) {
                        root.openTab("files");
                    }
                }
                onDropped: function(drop) {
                    if (root.model && drop.hasUrls) {
                        root.model.action("shelf-add", drop.urls.map(String));
                        drop.acceptProposedAction();
                    }
                }
            }

            Item {
                id: content

                width: Math.min(root.expandedWidth, window.width - 24) - 64
                height: root.expandedHeight - 14
                anchors.horizontalCenter: parent.horizontalCenter
                y: root.spatial ? 0 : root.animationProfile.offset * (1 - root.progress)
                opacity: Math.max(0, Math.min(1, (root.progress - 0.1) / 0.65))
                scale: root.spatial ? 1 : root.animationProfile.scale + (1 - root.animationProfile.scale) * root.progress
                transformOrigin: Item.Top
                layer.enabled: root.motion && root.progress < 0.999 && root.progress > 0.01

                UI.Header {
                    id: header

                    anchors.top: parent.top
                    width: parent.width
                    host: root
                    model: root.model
                    onMoreRequested: {
                        moreMenu.open();
                    }
                }

                Loader {
                    id: page

                    property real arrival: 1

                    function inject() {
                        if (item) {
                            item.host = root;
                            item.model = Qt.binding(function() {
                                return root.model;
                            });
                            if ("mode" in item)
                                item.mode = root.subtab || "main";

                        }
                    }

                    clip: true
                    opacity: arrival
                    source: {
                        var files = {
                            "home": "Home.qml",
                            "calendar": "Calendar.qml",
                            "files": "Files.qml",
                            "clipboard": "Clipboard.qml",
                            "focus": "Focus.qml",
                            "camera": "Mirror.qml",
                            "agents": "Agents.qml",
                            "tools": "Tools.qml",
                            "settings": "Settings.qml"
                        };
                        return Qt.resolvedUrl(files[root.currentTab] || "Home.qml");
                    }
                    onLoaded: {
                        inject();
                        arrival = 0;
                        arrive.restart();
                    }

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: header.bottom
                        topMargin: 4
                        bottom: parent.bottom
                    }

                    NumberAnimation {
                        id: arrive

                        target: page
                        property: "arrival"
                        to: 1
                        duration: root.motion ? Style.duration(210) : 0
                        easing.type: Easing.OutCubic
                    }

                    transform: Translate {
                        x: root.direction * 14 * (1 - page.arrival)
                    }

                }

                layer.effect: MultiEffect {
                    blurEnabled: true
                    blurMax: 16
                    blur: root.animationProfile.blur / 16 * (1 - root.progress)
                    autoPaddingEnabled: false
                }

            }

            NotchShape {
                anchors.fill: parent
                topRadius: 14
                bottomRadius: 30
                fill: Qt.rgba(0, 0, 0, root.spatial ? Math.max(0, (root.animationProfile.shade || 0) * (1 - root.progress)) : 0)
                stroke: "transparent"
                glass: false
                visible: root.spatial && root.progress < 0.995
            }

            transform: Matrix4x4 {
                matrix: root.spatial ? CardTransform.matrix(card.width, root.reveal, root.animationProfile) : Qt.matrix4x4()
            }

        }

        Popup {
            id: moreMenu
            onClosed: if (root.opened && !root.held) leaveTimer.restart()

            parent: window.contentItem
            x: card.x + card.width - 230
            y: 30
            width: 204
            padding: 6
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: "#fa29292b"
                radius: 12
                border.color: "#35ffffff"
                border.width: 1
            }

            contentItem: Column {
                spacing: 2

                Repeater {
                    model: [{
                        "id": "calendar",
                        "icon": "calendar",
                        "key": "calendar"
                    }, {
                        "id": "tools",
                        "icon": "terminal",
                        "key": "tools"
                    }, {
                        "id": "settings",
                        "icon": "settings",
                        "key": "settings"
                    }, {
                        "id": "pin",
                        "icon": root.held ? "pin-off" : "pin",
                        "key": root.held ? "unpin" : "pin"
                    }, {
                        "id": "close",
                        "icon": "x",
                        "key": "close"
                    }]

                    Rectangle {
                        required property var modelData

                        width: 192
                        height: 28
                        radius: 6
                        color: menuHover.hovered ? "#22ffffff" : "transparent"

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 9
                            spacing: 9

                            UI.Icon {
                                name: modelData.icon
                                size: 14
                                opacity: 0.8
                            }

                            PlainLabel {
                                text: root.t(modelData.key)
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                        HoverHandler {
                            id: menuHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (modelData.id === "pin") {
                                    root.held = !root.held;
                                    moreMenu.close();
                                } else if (modelData.id === "close") {
                                    root.close();
                                } else {
                                    root.openTab(modelData.id);
                                }
                            }
                        }

                    }

                }

            }

        }

        Rectangle {
            visible: root.opened && !!root.model && root.model.feedback !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            y: card.height + 8
            width: Math.min(480, feedback.implicitWidth + 30)
            height: 30
            radius: 15
            color: "#f029292b"
            border.color: "#22ffffff"

            PlainLabel {
                id: feedback

                anchors.fill: parent
                anchors.margins: 10
                text: root.model ? root.model.feedback : ""
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

        mask: Region {
            item: root.opened ? card : null

            Region {
                item: moreMenu.visible ? moreMenu.contentItem : null
                intersection: Intersection.Combine
            }

        }

    }

    Behavior on reveal {
        NumberAnimation {
            id: revealAnimation

            duration: root.motion ? Style.duration(root.opened ? root.animationProfile.duration : Math.min(260, root.animationProfile.duration * 0.7)) : 0
            easing.type: Easing.Bezier
            easing.bezierCurve: root.opened ? root.animationProfile.curve : Motion.closingCurve
        }

    }

}
