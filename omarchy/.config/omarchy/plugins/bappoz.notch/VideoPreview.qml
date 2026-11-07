import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

Item {
  id:root
  property var host:null
  property var model:null
  property int selected:0
  readonly property var windows:ToplevelManager.toplevels.values
  ColumnLayout {
    anchors.fill:parent;spacing:9
    RowLayout {
      PlainLabel {text:root.host?root.host.t("videoPreview"):"Video";font.pixelSize:18;font.weight:Font.Medium;Layout.fillWidth:true}
      NotchButton {text:windows.length?windows[root.selected%windows.length].title:"—";compact:true;Layout.maximumWidth:280;onClicked:root.selected++}
    }
    Rectangle {
      Layout.fillWidth:true;Layout.fillHeight:true;color:"#050608";radius:15;clip:true
      ScreencopyView {id:copy;anchors.fill:parent;captureSource:root.visible&&root.windows.length?root.windows[root.selected%root.windows.length]:null;live:root.visible;paintCursor:false;constraintSize:Qt.size(width,height)}
      PlainLabel {visible:!copy.hasContent;anchors.centerIn:parent;width:parent.width-32;text:root.host?root.host.t("videoHint"):"Choose a window";wrapMode:Text.Wrap;horizontalAlignment:Text.AlignHCenter;color:"#909aaf"}
    }
  }
}
