pragma Singleton
import QtQuick

QtObject {
    readonly property color text: "#ffffff"
    readonly property color secondary: "#929294"
    readonly property color tertiary: "#606064"
    readonly property color surface: "#0dffffff"
    readonly property color stroke: "#1fffffff"
    readonly property color accent: "#ff9f0a"
    readonly property color green: "#30d158"
    readonly property color red: "#ff453a"
    readonly property string fontFamily: bundledFont.status === FontLoader.Ready ? bundledFont.name : "Adwaita Sans"
    readonly property int sideColumn: 124
    readonly property int columnSpacing: 18
    readonly property int bodyWidth: 680
    readonly property int defaultHeight: 200
    property FontLoader bundledFont

    bundledFont: FontLoader {
        source: Qt.resolvedUrl("../assets/fonts/InterVariable.ttf")
    }

}
