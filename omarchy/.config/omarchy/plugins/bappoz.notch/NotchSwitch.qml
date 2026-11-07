import QtQuick
import QtQuick.Controls
import qs.Commons

AbstractButton {
  id:root
  checkable:true
  implicitWidth:42;implicitHeight:25
  focusPolicy:Qt.StrongFocus
  background:Rectangle {radius:height/2;color:root.checked?"#b9c8ed":"#3c3f4b";border.color:root.activeFocus?"#e2e9ff":"transparent"}
  contentItem:Item {
    Rectangle {x:root.checked?20:3;y:3;width:19;height:19;radius:10;color:root.checked?"#1b2030":"#d3d5df";Behavior on x{NumberAnimation{duration:Style.duration(130);easing.type:Easing.OutCubic}}}
  }
  Keys.onReturnPressed:toggle()
}
