import QtQuick
import "ui" as UI

Text {
    textFormat: Text.PlainText
    color: "#ffffff"
    font.family: UI.Design.fontFamily
    font.pixelSize: 12
    elide: Text.ElideRight
    renderType: Text.NativeRendering
}
