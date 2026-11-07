import QtQuick
import QtQuick.Layouts
import ".." as App

RowLayout {
    id: root

    property int level: 0
    property bool charging: false

    spacing: 5

    App.PlainLabel {
        text: root.level + "%"
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }

    Item {
        implicitWidth: 25
        implicitHeight: 11

        Rectangle {
            width: 22
            height: 10
            y: 0.5
            radius: 3
            color: "transparent"
            border.color: "#8cffffff"
            border.width: 1

            Rectangle {
                x: 2
                y: 2
                height: 6
                radius: 1.4
                width: 18 * Math.max(0, Math.min(100, root.level)) / 100
                color: root.charging ? "#30d158" : root.level < 15 ? "#ff453a" : "#ffffff"
            }

        }

        Rectangle {
            x: 23
            y: 4
            width: 1.5
            height: 3
            radius: 1
            color: "#77ffffff"
        }

    }

}
