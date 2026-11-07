import QtQuick
import QtQuick.Layouts
import QtMultimedia
import "ui" as UI
import "ui/CameraLooks.js" as Looks

Item {
    id: root

    property var host: null
    property var model: null
    property bool enabledCamera: false
    property string look: "natural"
    property string decoration: "none"
    property bool drawing: false
    property bool saving: false
    property var captureStyle: ({
    })
    property var strokes: []
    property var currentStroke: []
    readonly property rect imageRect: Qt.rect(preview.x + preview.contentRect.x, preview.y + preview.contentRect.y, preview.contentRect.width, preview.contentRect.height)

    function t(key) {
        return host ? host.t(key) : key;
    }

    function selectLook(name) {
        look = Looks.profile(name).id;
    }

    function selectDecoration(name) {
        if (["none", "polaroid", "stars", "tape"].indexOf(name) >= 0)
            decoration = name;

    }

    function photograph() {
        if (!model || !enabledCamera || !capture.readyForCapture || saving)
            return ;

        saving = true;
        captureStyle = {
            "look": look,
            "decoration": decoration,
            "strokes": JSON.stringify(strokes)
        };
        model.action("photo-path", [], function(data) {
            if (data.ok && root.enabledCamera)
                capture.captureToFile(data.path);
            else
                root.saving = false;
        });
    }

    onDecorationChanged: ornaments.requestPaint()
    onImageRectChanged: ornaments.requestPaint()

    Connections {
        function onOpenedChanged() {
            if (!root.host.opened)
                root.enabledCamera = false;

        }

        target: root.host
    }

    MediaDevices {
        id: devices
    }

    Camera {
        id: camera

        cameraDevice: devices.defaultVideoInput
        active: root.enabledCamera && !!root.host && root.host.opened
        onErrorOccurred: function(error, errorString) {
            if (root.model)
                root.model.feedback = errorString;

            root.enabledCamera = false;
            root.saving = false;
        }
    }

    ImageCapture {
        id: capture

        onImageSaved: function(id, path) {
            if (!root.model) {
                root.saving = false;
                return ;
            }
            var style = root.captureStyle;
            root.model.action("photo-style", [path, style.look, style.decoration, style.strokes], function() {
                root.saving = false;
            });
        }
        onErrorOccurred: function(id, error, message) {
            root.saving = false;
            if (root.model)
                root.model.feedback = message;

        }
    }

    CaptureSession {
        camera: camera
        videoOutput: preview
        imageCapture: capture
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 9

        Rectangle {
            id: stage

            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: root.enabledCamera && root.decoration === "polaroid" ? "#f7f4ee" : "#080809"
            clip: true

            VideoOutput {
                id: preview

                anchors.fill: parent
                anchors.margins: root.decoration === "polaroid" ? 8 : 0
                anchors.bottomMargin: root.decoration === "polaroid" ? 28 : 0
                fillMode: VideoOutput.PreserveAspectFit
                layer.enabled: root.look !== "natural"

                layer.effect: UI.CameraEffect {
                    look: root.look
                }

            }

            Canvas {
                id: ornaments

                anchors.fill: parent
                visible: root.enabledCamera
                onPaint: {
                    var c = getContext("2d"), r = root.imageRect;
                    c.reset();
                    if (r.width <= 0 || r.height <= 0)
                        return ;

                    c.translate(r.x, r.y);
                    if (root.decoration === "stars") {
                        c.fillStyle = "#fff6db";
                        var stars = [[0.08, 0.12], [0.9, 0.17], [0.85, 0.85], [0.14, 0.8]];
                        for (var k = 0; k < stars.length; k++) {
                            c.beginPath();
                            for (var i = 0; i < 10; i++) {
                                var a = (i * 36 - 90) * Math.PI / 180, rad = r.width * (i % 2 === 0 ? 0.025 : 0.011);
                                var x = stars[k][0] * r.width + rad * Math.cos(a), y = stars[k][1] * r.height + rad * Math.sin(a);
                                if (i === 0)
                                    c.moveTo(x, y);
                                else
                                    c.lineTo(x, y);
                            }
                            c.closePath();
                            c.fill();
                        }
                    } else if (root.decoration === "tape") {
                        c.fillStyle = "rgba(201,183,160,.7)";
                        var shapes = [[[0.1, 0], [0.4, 0], [0.4, 0.035], [0.1, 0.06]], [[0.65, 0], [0.95, 0], [0.9, 0.05], [0.6, 0.03]]];
                        for (var j = 0; j < shapes.length; j++) {
                            c.beginPath();
                            for (var n = 0; n < shapes[j].length; n++) {
                                var p = shapes[j][n];
                                if (n === 0)
                                    c.moveTo(p[0] * r.width, p[1] * r.height);
                                else
                                    c.lineTo(p[0] * r.width, p[1] * r.height);
                            }
                            c.closePath();
                            c.fill();
                        }
                    }
                }
            }

            Canvas {
                id: ink

                x: root.imageRect.x
                y: root.imageRect.y
                width: root.imageRect.width
                height: root.imageRect.height
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    var c = getContext("2d");
                    c.reset();
                    c.strokeStyle = "#fff6db";
                    c.lineWidth = 3;
                    c.lineCap = "round";
                    var paths = root.strokes.concat([root.currentStroke]);
                    for (var i = 0; i < paths.length; i++) {
                        if (paths[i].length < 2)
                            continue;

                        c.beginPath();
                        c.moveTo(paths[i][0][0] * width, paths[i][0][1] * height);
                        for (var j = 1; j < paths[i].length; j++) c.lineTo(paths[i][j][0] * width, paths[i][j][1] * height)
                        c.stroke();
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.drawing && root.enabledCamera
                    onPressed: function(mouse) {
                        root.currentStroke = [[mouse.x / width, mouse.y / height]];
                        ink.requestPaint();
                    }
                    onPositionChanged: function(mouse) {
                        if (pressed && root.currentStroke.length < 1000) {
                            root.currentStroke = root.currentStroke.concat([[Math.max(0, Math.min(1, mouse.x / width)), Math.max(0, Math.min(1, mouse.y / height))]]);
                            ink.requestPaint();
                        }
                    }
                    onReleased: {
                        root.strokes = root.strokes.concat([root.currentStroke]);
                        root.currentStroke = [];
                        ink.requestPaint();
                    }
                }

            }

            PlainLabel {
                visible: !root.enabledCamera
                anchors.centerIn: parent
                text: devices.videoInputs.length ? root.t("cameraPrivacy") : root.t("cameraMissing")
                color: "#929298"
                width: parent.width - 60
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 12
            }

        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Column {
                Layout.preferredWidth: 90
                spacing: 2

                PlainLabel {
                    text: root.t("cameraLooks")
                    font.pixelSize: 9
                    color: "#77777d"
                }

                PlainLabel {
                    text: root.t("look." + root.look)
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

            }

            ListView {
                id: looks

                Layout.fillWidth: true
                Layout.preferredHeight: 34
                orientation: ListView.Horizontal
                spacing: 4
                clip: true
                model: Looks.looks

                delegate: UI.CircleChoice {
                    required property var modelData

                    implicitWidth: 26
                    implicitHeight: 26
                    objectName: "look-" + modelData.id
                    selected: root.look === modelData.id
                    swatch: modelData.swatch
                    hint: root.t("look." + modelData.id)
                    onClicked: root.selectLook(modelData.id)
                }

            }

        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [{
                    "id": "none",
                    "icon": "circle-dot"
                }, {
                    "id": "polaroid",
                    "icon": "image"
                }, {
                    "id": "stars",
                    "icon": "sparkles"
                }, {
                    "id": "tape",
                    "icon": "grip-vertical"
                }]

                UI.CircleChoice {
                    required property var modelData

                    objectName: "frame-" + modelData.id
                    selected: root.decoration === modelData.id
                    iconName: modelData.icon
                    hint: root.t("frame." + modelData.id)
                    onClicked: root.selectDecoration(modelData.id)
                }

            }

            PlainLabel {
                text: root.t("frame." + root.decoration)
                font.pixelSize: 10
                color: "#9d9da3"
                Layout.preferredWidth: 70
            }

            UI.IconButton {
                iconName: "pencil"
                selected: root.drawing
                hint: root.t("cameraDraw")
                onClicked: root.drawing = !root.drawing
            }

            UI.IconButton {
                iconName: "undo-2"
                hint: root.t("cameraUndo")
                enabled: root.strokes.length > 0
                onClicked: {
                    root.strokes = root.strokes.slice(0, -1);
                    ink.requestPaint();
                }
            }

            Item {
                Layout.fillWidth: true
            }

            NotchButton {
                text: root.t(root.enabledCamera ? "cameraStop" : "cameraStart")
                iconName: root.enabledCamera ? "power" : "camera"
                compact: true
                enabled: devices.videoInputs.length > 0
                onClicked: root.enabledCamera = !root.enabledCamera
            }

            UI.IconButton {
                iconName: "camera"
                hint: root.t("photograph")
                filled: true
                circular: true
                implicitWidth: 34
                implicitHeight: 34
                enabled: root.enabledCamera && capture.readyForCapture && !root.saving
                onClicked: root.photograph()
            }

        }

    }

}
