import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
  id:root
  property var host:null
  property var model:null
  property string section:"weather"
  function t(key){return host?host.t(key):key}
  function refresh(){if(model)model.action(({weather:"weather",markets:"markets",home:"home-states",prayers:"prayers",spotify:"spotify-devices"})[section],[])}
  ColumnLayout {
    anchors.fill:parent;spacing:12
    RowLayout {
      Layout.fillWidth:true;spacing:5
      Repeater {
        model:[{id:"weather",name:root.t("weather")},{id:"markets",name:root.t("markets")},{id:"home",name:"Home Assistant"},{id:"prayers",name:root.t("prayers")},{id:"spotify",name:"Spotify Connect"}]
        NotchButton {required property var modelData;text:modelData.name;selected:root.section===modelData.id;compact:true;Layout.fillWidth:true;onClicked:root.section=modelData.id}
      }
    }
    PlainLabel {text:root.t("onlineHint");Layout.fillWidth:true;wrapMode:Text.Wrap;color:"#959caf";font.pixelSize:11}
    RowLayout {
      Layout.fillWidth:true;spacing:7
      NotchButton {text:root.t("refresh");selected:true;Layout.fillWidth:true;onClicked:root.refresh()}
      NotchButton {text:root.t("connect");Layout.fillWidth:true;onClicked:root.host.openTab("settings/connections")}
    }
    Flickable {
      Layout.fillWidth:true;Layout.fillHeight:true;contentHeight:content.implicitHeight;clip:true
      ScrollBar.vertical:ScrollBar{}
      ColumnLayout {
        id:content;width:parent.width;spacing:10
        PlainLabel {visible:root.section==="weather";text:root.model&&root.model.weather.temperature!==undefined?root.model.weather.temperature+"°":"—";font.pixelSize:70;font.weight:Font.Light;Layout.alignment:Qt.AlignHCenter}
        PlainLabel {visible:root.section==="weather";text:root.model&&root.model.weather.humidity!==undefined?root.model.weather.humidity+"%  ·  "+root.model.weather.wind+" km/h":"Open-Meteo";color:"#a2aabd";Layout.alignment:Qt.AlignHCenter}
        NotchButton {visible:root.section==="weather";text:root.t("weather");Layout.fillWidth:true;onClicked:root.host.handoff("omarchy.weather")}
        Repeater {
          model:root.section==="markets"&&root.model?root.model.markets:[]
          Surface {
            required property var modelData
            Layout.fillWidth:true;implicitHeight:62
            RowLayout {anchors.fill:parent;anchors.margins:12
              ColumnLayout {Layout.fillWidth:true;PlainLabel{text:modelData.name;font.pixelSize:15}PlainLabel{text:modelData.detail;font.pixelSize:10;color:"#959daf"}}
              PlainLabel {text:modelData.value===null?"—":Number(modelData.value).toLocaleString(Qt.locale(),"f",2);font.pixelSize:18}
              PlainLabel {visible:modelData.change!==null;text:Number(modelData.change).toFixed(2)+"%";color:Number(modelData.change)<0?"#ec9ca3":"#a5dac2";font.pixelSize:11}
            }
          }
        }
        PlainLabel {visible:root.section==="markets"&&!!root.model&&root.model.marketWarnings.length>0;text:root.model?root.model.marketWarnings.join("\n"):"";wrapMode:Text.Wrap;Layout.fillWidth:true;color:"#b6a5a5";font.pixelSize:11}
        Repeater {
          model:root.section==="prayers"&&root.model?root.model.prayers:[]
          RowLayout {required property var modelData;Layout.fillWidth:true;PlainLabel{text:modelData.name;Layout.fillWidth:true;color:"#a4aec4"}PlainLabel{text:modelData.time;font.pixelSize:23}}
        }
        NotchButton {visible:root.section==="prayers";text:root.t("prayerAlerts");Layout.fillWidth:true;enabled:!!root.model&&root.model.prayers.length>0;onClicked:root.model.action("prayer-alerts",[])}
        Repeater {
          model:root.section==="home"&&root.model?root.model.homeDevices:[]
          Surface {
            required property var modelData
            Layout.fillWidth:true;implicitHeight:deviceColumn.implicitHeight+24
            ColumnLayout {
              id:deviceColumn;anchors.left:parent.left;anchors.right:parent.right;anchors.top:parent.top;anchors.margins:12
              RowLayout {
                PlainLabel {text:modelData.name;Layout.fillWidth:true;font.pixelSize:15}
                PlainLabel {text:modelData.state;font.pixelSize:11;color:"#97abc7"}
                NotchButton {text:modelData.state==="off"?root.t("on"):root.t("off");compact:true;onClicked:root.model.action("home-command",[modelData.id,modelData.state==="off"?"turn_on":"turn_off",""])}
              }
              NotchSlider {visible:modelData.domain==="light";Layout.fillWidth:true;from:0;to:100;value:(modelData.brightness||0)/255*100;onPressedChanged:if(!pressed&&visible)root.model.action("home-command",[modelData.id,"brightness",String(Math.round(value))])}
              RowLayout {
                visible:modelData.domain==="climate"
                PlainLabel {text:modelData.temperature===null?"—":modelData.temperature+"°";font.pixelSize:20;Layout.fillWidth:true}
                NotchButton {text:"−";compact:true;onClicked:root.model.action("home-command",[modelData.id,"temperature",String((modelData.temperature||22)-1)])}
                NotchButton {text:"+";compact:true;onClicked:root.model.action("home-command",[modelData.id,"temperature",String((modelData.temperature||22)+1)])}
                Repeater {model:modelData.modes||[];NotchButton{required property string modelData;text:modelData;compact:true;onClicked:root.model.action("home-command",[deviceColumn.parent.modelData.id,"mode",modelData])}}
              }
            }
          }
        }
        Repeater {
          model:root.section==="spotify"&&root.model?root.model.spotifyDevices:[]
          NotchButton {required property var modelData;text:modelData.name;selected:modelData.active;Layout.fillWidth:true;onClicked:root.model.action("spotify-transfer",[modelData.id])}
        }
      }
    }
  }
}
