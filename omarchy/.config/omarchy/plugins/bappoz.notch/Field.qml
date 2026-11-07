import QtQuick
import QtQuick.Controls

TextField {
  id: root
  color: "#f6f6f8"
  placeholderTextColor: "#81818f"
  font.family: "Inter"
  font.pixelSize: 13
  padding: 11
  selectByMouse: true
  background: Rectangle { color: "#0affffff"; radius: 11; border.color: root.activeFocus ? "#809be0" : "#16ffffff" }
}
