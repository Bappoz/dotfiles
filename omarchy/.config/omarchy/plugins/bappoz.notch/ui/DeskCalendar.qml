import QtQuick
import QtQuick.Layouts
import qs.Commons
import ".." as App

App.Surface {
    id: root

    property date today: new Date()
    readonly property var locale: Qt.locale(I18n.formatLocale)

    signal activated()

    implicitWidth: 112
    implicitHeight: 112

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 0

        RowLayout {
            Layout.fillWidth: true

            App.PlainLabel {
                text: root.today.toLocaleDateString(root.locale, "ddd").toUpperCase()
                font.pixelSize: 9
                font.weight: Font.Bold
                color: "#ff453a"
            }

            Item {
                Layout.fillWidth: true
            }

            App.PlainLabel {
                text: root.today.toLocaleDateString(root.locale, "MMM").toUpperCase()
                font.pixelSize: 9
                font.weight: Font.DemiBold
                color: "#929294"
            }

        }

        App.PlainLabel {
            text: root.today.getDate()
            font.pixelSize: 38
            font.weight: Font.Bold
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        App.PlainLabel {
            text: root.today.toLocaleDateString(root.locale, "dddd")
            font.pixelSize: 10
            color: "#929294"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

}
