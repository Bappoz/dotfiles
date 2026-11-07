import QtQuick
import QtQuick.Effects
import "CameraLooks.js" as Looks

// GPU preview uses the same named looks as the non-destructive photo exporter.
MultiEffect {
    id: root

    property string look: "natural"
    readonly property var profile: Looks.profile(look)

    brightness: profile.brightness || 0
    contrast: profile.contrast || 0
    saturation: profile.saturation || 0
    colorization: profile.colorization || 0
    colorizationColor: profile.tint || "white"
    autoPaddingEnabled: false
}
