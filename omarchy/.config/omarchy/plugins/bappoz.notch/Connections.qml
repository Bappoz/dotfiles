import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
  id:root
  property var host:null
  property var model:null
  property bool seeded:false
  function t(key){return host?host.t(key):key}
  function seed(){
    if(!model)return
    model.action("integration-settings",[],function(data){
      if(!data.ok)return
      var values=data.integrationSettings,loc=values.location||{}
      latitude.text=loc.latitude===null||loc.latitude===undefined?"":String(loc.latitude)
      longitude.text=loc.longitude===null||loc.longitude===undefined?"":String(loc.longitude)
      zone.text=loc.timezone||"America/Sao_Paulo";method.text=values.prayerMethod||"MWL"
      homeUrl.text=values.homeUrl||"";base.text=values.base||"BRL"
      currencies.text=(values.currencies||[]).join(", ");coins.text=(values.coins||[]).join(", ");stocks.text=(values.stocks||[]).join(", ")
      root.seeded=true
    })
  }
  onModelChanged:if(model&&!seeded)seed()
  function save(){model.action("integration-save",[],function(data){if(data.ok){homeToken.clear();spotifyToken.clear();stockKey.clear();coinKey.clear()}},JSON.stringify({latitude:latitude.text,longitude:longitude.text,timezone:zone.text,prayerMethod:method.text,homeUrl:homeUrl.text,homeToken:homeToken.text,spotifyToken:spotifyToken.text,base:base.text,currencies:currencies.text,coins:coins.text,stocks:stocks.text,stockKey:stockKey.text,coinKey:coinKey.text}))}
  ColumnLayout {
    anchors.fill:parent;spacing:12
    RowLayout {PlainLabel{text:root.t("connect");font.pixelSize:24;font.weight:Font.DemiBold;Layout.fillWidth:true}NotchButton{glyph:"‹";compact:true;Accessible.name:root.t("settings");onClicked:root.host.openTab("settings")}}
    PlainLabel {text:root.t("keyPrivacy");font.pixelSize:11;color:"#9aa4b9";Layout.fillWidth:true;wrapMode:Text.Wrap}
    Flickable {
      Layout.fillWidth:true;Layout.fillHeight:true;clip:true;contentHeight:column.implicitHeight
      ScrollBar.vertical:ScrollBar{}
      ColumnLayout {
        id:column;width:parent.width;spacing:10
        PlainLabel {text:root.t("location");font.pixelSize:15}
        RowLayout {Layout.fillWidth:true;Field{id:latitude;Layout.fillWidth:true;placeholderText:"Latitude"}Field{id:longitude;Layout.fillWidth:true;placeholderText:"Longitude"}}
        RowLayout {Layout.fillWidth:true;Field{id:zone;Layout.fillWidth:true;placeholderText:"America/Sao_Paulo"}Field{id:method;Layout.preferredWidth:105;placeholderText:"MWL"}}
        PlainLabel {text:"Home Assistant";font.pixelSize:15}
        Field {id:homeUrl;Layout.fillWidth:true;placeholderText:"https://homeassistant.local:8123"}
        Field {id:homeToken;Layout.fillWidth:true;echoMode:TextInput.Password;placeholderText:root.model&&root.model.integrationSettings.hasHomeToken?root.t("keySaved"):"Long-lived access token"}
        PlainLabel {text:"Spotify Connect";font.pixelSize:15}
        Field {id:spotifyToken;Layout.fillWidth:true;echoMode:TextInput.Password;placeholderText:root.model&&root.model.integrationSettings.hasSpotifyToken?root.t("keySaved"):"Spotify OAuth token"}
        PlainLabel {text:root.t("markets");font.pixelSize:15}
        RowLayout {Layout.fillWidth:true;Field{id:base;Layout.preferredWidth:75;placeholderText:"BRL";maximumLength:3}Field{id:currencies;Layout.fillWidth:true;placeholderText:"USD, EUR, GBP"}}
        Field {id:coins;Layout.fillWidth:true;placeholderText:"bitcoin, ethereum"}
        Field {id:stocks;Layout.fillWidth:true;placeholderText:"AAPL, MSFT, IBM"}
        Field {id:stockKey;Layout.fillWidth:true;echoMode:TextInput.Password;placeholderText:root.model&&root.model.integrationSettings.hasStockKey?root.t("keySaved"):"Alpha Vantage API key"}
        Field {id:coinKey;Layout.fillWidth:true;echoMode:TextInput.Password;placeholderText:root.model&&root.model.integrationSettings.hasCoinKey?root.t("keySaved"):"CoinGecko Demo API key"}
      }
    }
    NotchButton {text:root.t("saveConnections");Layout.fillWidth:true;selected:true;enabled:root.seeded;onClicked:root.save()}
  }
}
