import QtQuick

// Adapted from OpenNotchi's NotchShape.swift + NotchBackground, MIT.
Canvas {
    id: root

    property color fill: "#c71c1c1e"
    property color stroke: "#2effffff"
    property real topRadius: 14
    property real bottomRadius: 30
    property bool glass: true

    function outline(c, w, h, t, b) {
        c.beginPath();
        c.moveTo(0, 0);
        c.quadraticCurveTo(t, 0, t, t);
        c.lineTo(t, h - b);
        c.quadraticCurveTo(t, h, t + b, h);
        c.lineTo(w - t - b, h);
        c.quadraticCurveTo(w - t, h, w - t, h - b);
        c.lineTo(w - t, t);
        c.quadraticCurveTo(w - t, 0, w, 0);
    }

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onFillChanged: requestPaint()
    onStrokeChanged: requestPaint()
    onTopRadiusChanged: requestPaint()
    onBottomRadiusChanged: requestPaint()
    onGlassChanged: requestPaint()
    onPaint: {
        var c = getContext("2d"), w = width, h = height, t = Math.min(topRadius, h / 3), b = Math.min(bottomRadius, (h - t) / 2, (w - 2 * t) / 2);
        c.reset();
        outline(c, w, h, t, b);
        c.closePath();
        c.fillStyle = fill;
        c.fill();
        if (glass) {
            var sheen = c.createLinearGradient(0, 0, 0, h);
            sheen.addColorStop(0, "rgba(255,255,255,0.045)");
            sheen.addColorStop(0.4, "rgba(255,255,255,0.005)");
            sheen.addColorStop(1, "rgba(0,0,0,0.06)");
            c.fillStyle = sheen;
            c.fill();
        }
        outline(c, w, h, t, b);
        var rim = c.createLinearGradient(0, 0, 0, h);
        rim.addColorStop(0, stroke.toString());
        rim.addColorStop(0.55, "rgba(255,255,255,0.075)");
        rim.addColorStop(1, "rgba(255,255,255,0.035)");
        c.strokeStyle = rim;
        c.lineWidth = 0.75;
        c.stroke();
    }
}
