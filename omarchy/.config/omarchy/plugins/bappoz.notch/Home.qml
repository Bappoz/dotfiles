import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import "ui" as UI

Item {
    id: root

    property var host: null
    property var model: null
    property string mode: "main"
    readonly property var player: model ? model.player : null
    readonly property bool hasTrack: !!player && !!(player.trackTitle || player.trackArtist)
    readonly property bool lyricsMode: mode === "lyrics"
    readonly property bool videoMode: mode === "video"
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int activeLyric: {
        if (!model || !model.lyricsSynced)
            return -1;

        var lines = model ? model.lyrics : [], position = player ? player.position : 0, index = -1;
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].time > position)
                break;

            index = i;
        }
        return index;
    }
    readonly property string lyricsKey: model ? model.lyricsTrackKey : ""

    function ensureLyrics() {
        if (host && host.opened && lyricsMode && hasTrack && model)
            model.loadLyrics(false);

    }

    function t(key) {
        return host ? host.t(key) : key;
    }

    function stamp(seconds) {
        var n = Math.max(0, Math.floor(seconds || 0));
        return Math.floor(n / 60) + ":" + String(n % 60).padStart(2, "0");
    }

    onModeChanged: Qt.callLater(ensureLyrics)
    onModelChanged: Qt.callLater(ensureLyrics)
    onLyricsKeyChanged: Qt.callLater(ensureLyrics)
    onHasTrackChanged: Qt.callLater(ensureLyrics)
    onActiveLyricChanged: {
        if (lyricsMode && activeLyric >= 0)
            lyrics.positionViewAtIndex(activeLyric, ListView.Center);

    }

    Connections {
        function onOpenedChanged() {
            if (root.host.opened)
                Qt.callLater(root.ensureLyrics);

        }

        target: root.host
    }

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    Timer {
        interval: 500
        running: root.visible && !!root.player && root.player.isPlaying
        repeat: true
        onTriggered: {
            if (root.player.positionSupported)
                root.player.positionChanged();

        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 18

        Item {
            Layout.preferredWidth: root.videoMode ? 199 : 124
            Layout.fillHeight: true

            UI.Vinyl {
                width: 112
                height: 112
                anchors.verticalCenter: parent.verticalCenter
                artwork: root.hasTrack ? root.player.trackArtUrl : ""
                playing: !!root.player && root.player.isPlaying
                motionEnabled: !!root.host && root.host.motion
                visible: !root.videoMode
                onActivated: {
                    if (root.model)
                        root.model.toggleMedia();

                }
            }

            UI.WindowPreview {
                visible: root.videoMode
                width: 199
                height: 112
                anchors.verticalCenter: parent.verticalCenter
            }

            UI.IconButton {
                anchors.right: parent.right
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: -58
                iconName: root.videoMode ? "music-2" : "captions"
                iconSize: 13
                circular: true
                implicitWidth: 26
                implicitHeight: 26
                selected: root.lyricsMode
                hint: root.t(root.videoMode ? "listen" : "lyricsSearch")
                onClicked: root.host.openTab(root.videoMode ? "home" : root.lyricsMode ? "home" : "home/lyrics")

                background: Rectangle {
                    radius: width / 2
                    color: "#ed080809"
                    border.color: "#2effffff"
                    border.width: 1
                }

            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 14
                anchors.bottomMargin: 10
                spacing: 6
                visible: !root.lyricsMode && root.hasTrack

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    PlainLabel {
                        text: root.player ? root.player.trackTitle : ""
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }

                    PlainLabel {
                        text: root.player ? root.player.trackArtist : ""
                        font.pixelSize: 12
                        color: "#a3a3a7"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    PlainLabel {
                        text: root.stamp(root.player ? root.player.position : 0)
                        font.pixelSize: 10
                        color: "#96969b"
                    }

                    NotchSlider {
                        Layout.fillWidth: true
                        implicitHeight: 12
                        from: 0
                        to: root.player && root.player.length > 0 ? root.player.length : 1
                        value: root.player ? root.player.position : 0
                        enabled: !!root.player && root.player.canSeek
                        onMoved: root.player.position = value
                        Accessible.name: root.t("position")
                    }

                    PlainLabel {
                        text: root.stamp(root.player ? root.player.length : 0)
                        font.pixelSize: 10
                        color: "#96969b"
                    }

                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    UI.IconButton {
                        iconName: "shuffle"
                        iconSize: 13
                        selected: !!root.player && root.player.shuffle
                        enabled: !!root.player && root.player.shuffleSupported
                        hint: "Shuffle"
                        onClicked: root.player.shuffle = !root.player.shuffle
                    }

                    UI.IconButton {
                        iconName: "backward-fill"
                        iconSize: 20
                        enabled: !!root.player && root.player.canGoPrevious
                        hint: root.t("previous")
                        onClicked: root.model.previous()
                    }

                    UI.IconButton {
                        iconName: root.player && root.player.isPlaying ? "pause-fill" : "play-fill"
                        iconSize: 13
                        implicitWidth: 32
                        implicitHeight: 32
                        filled: true
                        circular: true
                        enabled: !!root.player && root.player.canTogglePlaying
                        hint: root.t("play")
                        onClicked: root.model.toggleMedia()
                    }

                    UI.IconButton {
                        iconName: "forward-fill"
                        iconSize: 20
                        enabled: !!root.player && root.player.canGoNext
                        hint: root.t("next")
                        onClicked: root.model.next()
                    }

                    UI.IconButton {
                        iconName: "repeat"
                        iconSize: 13
                        selected: !!root.player && root.player.loopState !== MprisLoopState.None
                        enabled: !!root.player && root.player.loopSupported
                        hint: "Repeat"
                        onClicked: root.player.loopState = root.player.loopState === MprisLoopState.None ? MprisLoopState.Playlist : MprisLoopState.None
                    }

                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    UI.IconButton {
                        iconName: "app-window"
                        iconSize: 12
                        implicitWidth: 24
                        implicitHeight: 22
                        hint: root.t("video")
                        onClicked: root.host.openTab(root.videoMode ? "home" : "home/video")
                    }

                    UI.IconButton {
                        iconName: "music-2"
                        iconSize: 12
                        implicitWidth: 24
                        implicitHeight: 22
                        hint: root.t("devices")
                        onClicked: root.host.handoff("omarchy.audio")
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    UI.IconButton {
                        iconName: root.sink && root.sink.audio && root.sink.audio.muted ? "volume-x" : "volume-2"
                        iconSize: 11
                        implicitWidth: 16
                        implicitHeight: 16
                        hint: root.t("volume")
                        onClicked: {
                            if (root.sink && root.sink.audio)
                                root.sink.audio.muted = !root.sink.audio.muted;

                        }
                    }

                    NotchSlider {
                        Layout.preferredWidth: 64
                        implicitHeight: 12
                        from: 0
                        to: 1
                        value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
                        enabled: !!root.sink
                        onMoved: {
                            if (root.sink && root.sink.audio)
                                root.sink.audio.volume = value;

                        }
                        Accessible.name: root.t("volume")
                    }

                    PlainLabel {
                        text: root.sink && root.sink.audio ? Math.round(root.sink.audio.volume * 100) + "%" : "—"
                        font.pixelSize: 8
                        color: "#77777c"
                        Layout.preferredWidth: 24
                        horizontalAlignment: Text.AlignRight
                    }

                }

            }

            ColumnLayout {
                visible: !root.lyricsMode && !root.hasTrack
                anchors.centerIn: parent
                width: parent.width
                spacing: 10

                PlainLabel {
                    text: root.t("musicStopped")
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                PlainLabel {
                    text: root.t("playHint")
                    font.pixelSize: 11
                    color: "#8e8e93"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6

                    Repeater {
                        model: root.model ? root.model.players : []

                        NotchButton {
                            required property var modelData

                            text: modelData.identity
                            iconName: "music-2"
                            compact: true
                            selected: root.player === modelData
                            onClicked: {
                                root.model.selectedPlayer = modelData.uniqueId;
                                if (modelData.canRaise)
                                    modelData.raise();

                            }
                        }

                    }

                }

                NotchButton {
                    text: root.t("video")
                    iconName: "app-window"
                    compact: true
                    plain: true
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: root.host.openTab(root.videoMode ? "home" : "home/video")
                }

            }

            ColumnLayout {
                visible: root.lyricsMode
                anchors.fill: parent
                anchors.topMargin: 6
                anchors.bottomMargin: 6
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    PlainLabel {
                        text: root.t("lyrics") + (root.model && root.model.lyricsState === "ready" && !root.model.lyricsSynced ? " · " + root.t("lyricsPlain") : "")
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    UI.IconButton {
                        iconName: "download"
                        hint: root.t("lyricsRetry")
                        iconSize: 12
                        implicitWidth: 24
                        implicitHeight: 22
                        enabled: root.hasTrack && !!root.model && root.model.lyricsState !== "loading"
                        onClicked: root.model.loadLyrics(true)
                    }

                    UI.IconButton {
                        iconName: "folder-open"
                        hint: root.t("loadLyrics")
                        iconSize: 12
                        implicitWidth: 24
                        implicitHeight: 22
                        onClicked: root.model.action("lyrics-file", [])
                    }

                }

                ListView {
                    id: lyrics

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 10
                    model: root.model ? root.model.lyrics : []

                    PlainLabel {
                        visible: lyrics.count === 0
                        anchors.centerIn: parent
                        width: parent.width
                        text: !root.hasTrack ? root.t("lyricsNoTrack") : root.model && root.model.lyricsState === "loading" ? root.t("lyricsLoading") : root.model && root.model.lyricsState === "error" ? root.model.lyricsError : root.t("loadLyrics")
                        font.pixelSize: 12
                        color: "#77777c"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }

                    Behavior on contentY {
                        NumberAnimation {
                            duration: root.host && root.host.motion ? 240 : 0
                            easing.type: Easing.OutCubic
                        }

                    }

                    delegate: PlainLabel {
                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        text: modelData.text
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                        color: "white"
                        opacity: root.model && !root.model.lyricsSynced ? 1 : index === root.activeLyric ? 1 : Math.abs(index - root.activeLyric) === 1 ? 0.55 : 0.28
                        layer.enabled: !!root.model && root.model.lyricsSynced && Math.abs(index - root.activeLyric) > 1

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (root.player && root.player.canSeek && root.model.lyricsSynced && modelData.time !== null)
                                    root.player.position = modelData.time;

                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 220
                            }

                        }

                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blurMax: 8
                            blur: 0.12
                            autoPaddingEnabled: false
                        }

                    }

                }

            }

        }

        Item {
            Layout.preferredWidth: 124
            Layout.fillHeight: true

            UI.DeskCalendar {
                width: 112
                height: 112
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: !root.lyricsMode
                onActivated: root.host.openTab("calendar")
            }

            Surface {
                visible: root.lyricsMode
                width: 112
                height: 112
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 6

                    UI.Waveform {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillHeight: true
                        playing: !!root.player && root.player.isPlaying
                        maximumHeight: 35
                        motionEnabled: !!root.host && root.host.motion
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 1

                        UI.IconButton {
                            iconName: "backward-fill"
                            implicitWidth: 25
                            iconSize: 15
                            enabled: !!root.player && root.player.canGoPrevious
                            hint: root.t("previous")
                            onClicked: root.model.previous()
                        }

                        UI.IconButton {
                            iconName: root.player && root.player.isPlaying ? "pause-fill" : "play-fill"
                            implicitWidth: 26
                            iconSize: 12
                            enabled: !!root.player && root.player.canTogglePlaying
                            hint: root.t("play")
                            onClicked: root.model.toggleMedia()
                        }

                        UI.IconButton {
                            iconName: "forward-fill"
                            implicitWidth: 25
                            iconSize: 15
                            enabled: !!root.player && root.player.canGoNext
                            hint: root.t("next")
                            onClicked: root.model.next()
                        }

                    }

                    PlainLabel {
                        text: root.stamp(root.player ? root.player.position : 0)
                        font.pixelSize: 9
                        color: "#88888d"
                        Layout.alignment: Qt.AlignHCenter
                    }

                }

            }

        }

    }

}
