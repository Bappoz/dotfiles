import "." as Local
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import Quickshell.Services.Mpris

Item {
  id: root
  property var shell: null
  property var manifest: null
  property var snapshot: ({})
  property var clips: []
  property var ports: []
  property var lyrics: []
  property bool lyricsSynced: true
  property string lyricsState: "idle"
  property string lyricsError: ""
  property int lyricsRequest: 0
  property string loadedLyricsKey: ""
  readonly property string lyricsTrackKey: player ? JSON.stringify([player.trackArtist,player.trackTitle,player.trackAlbum,Math.round(player.length||0)]) : ""
  onLyricsTrackKeyChanged: {
    lyricsRequest++
    lyrics=[]; lyricsState="idle"; lyricsError=""; loadedLyricsKey=""
  }
  property var audioDevices: []
  property var weather: ({})
  property var markets: []
  property var marketWarnings: []
  property var prayers: []
  property var homeDevices: []
  property var spotifyDevices: []
  property var integrationSettings: ({})
  property string feedback: ""
  property int busy: 0
  property int expandedCount: 0
  property bool refreshing: false
  property string requestedTab: "home"
  property string selectedPlayer: ""
  readonly property var players: Mpris.players.values
  readonly property var player: {
    var all = players
    for (var i=0; i<all.length; i++) if (all[i].uniqueId === selectedPlayer) return all[i]
    for (var j=0; j<all.length; j++) if (all[j].isPlaying) return all[j]
    return all.length ? all[0] : null
  }
  readonly property string backendPath: decodeURIComponent(Qt.resolvedUrl("backend.py").toString().replace(/^file:\/\//, ""))
  readonly property var metrics: snapshot.metrics || ({})
  readonly property var agents: snapshot.agents || []
  readonly property var shelf: snapshot.shelf || []
  readonly property var clocks: snapshot.clocks || []
  readonly property var batteries: snapshot.batteries || []
  readonly property var systemBattery: snapshot.systemBattery || null
  readonly property var timer: snapshot.timer || ({})
  readonly property var preferences: snapshot.settings || ({})
  property double now: Date.now()/1000
  readonly property int remaining: Math.max(0, Math.ceil(Number(timer.end || 0)-now))
  readonly property string countdown: Math.floor(remaining/60) + ":" + String(remaining%60).padStart(2,"0")

  Component.onCompleted: Local.Runtime.model = root
  Component.onDestruction: if(Local.Runtime.model === root)Local.Runtime.model = null

  Component { id: job; Job {} }

  function refresh() {
    if (refreshing) return
    refreshing = true
    job.createObject(root, {argv: ["python3", backendPath, "status"], callback: function(data) {
      refreshing = false
      if (data.ok) snapshot = data
      else feedback = String(data.error || "Não foi possível ler o sistema")
    }})
  }
  function action(name, args, callback, inputText) {
    if (busy >= 4) { feedback = "Aguarde as operações em andamento"; return }
    busy++
    job.createObject(root, {argv: ["python3",backendPath,name].concat(args || []), inputText: inputText || "", callback:function(data) {
      busy--
      feedback = String(data.ok ? (data.message || "") : data.error || "Operação indisponível")
      if (data.clipboard) clips = data.clipboard
      if (data.ports) ports = data.ports
      if (data.lyrics) {
        lyrics = data.lyrics; lyricsSynced = data.synced !== false
        lyricsState = "ready"; lyricsError = ""; loadedLyricsKey = lyricsTrackKey
      }
      if (data.integrationSettings)integrationSettings=data.integrationSettings
      if (data.weather) weather=data.weather
      if (data.markets) markets=data.markets
      if (data.marketWarnings) marketWarnings=data.marketWarnings
      if (data.prayers) prayers=data.prayers
      if (data.homeDevices) homeDevices=data.homeDevices
      if (data.spotifyDevices) spotifyDevices=data.spotifyDevices
      if (data.audioDevices) audioDevices = data.audioDevices
      if (callback) callback(data)
      refresh()
      feedbackTimer.restart()
    }})
  }
  function loadLyrics(force) {
    if (!player || !player.trackTitle || !player.trackArtist) return
    var key=lyricsTrackKey
    if (!force && ((lyricsState==="loading" && loadedLyricsKey===key) || (lyricsState==="ready" && loadedLyricsKey===key))) return
    if (busy>=4) { lyricsState="error";lyricsError="Aguarde as operações em andamento";return }
    var request=++lyricsRequest
    loadedLyricsKey=key; lyrics=[]; lyricsState="loading"; lyricsError=""; busy++
    job.createObject(root, {argv:["python3",backendPath,"lyrics-online",player.trackArtist,player.trackTitle,player.trackAlbum||"",String(player.length||0)],callback:function(data){
      busy--
      // A response for the previous song must never replace the current lyrics.
      if(request!==lyricsRequest || key!==lyricsTrackKey)return
      if(data.ok && data.lyrics && data.lyrics.length) {
        lyrics=data.lyrics; lyricsSynced=data.synced!==false; lyricsState="ready"
      } else {
        lyricsState="error"; lyricsError=String(data.error||"Letra não encontrada para esta faixa")
      }
    }})
  }
  function exec(argv) { Quickshell.execDetached(argv) }
  function panel(id) { exec(["omarchy-shell","shell","toggle",id]) }
  function toggleMedia() { if (player && player.canTogglePlaying) player.togglePlaying() }
  function next() { if (player && player.canGoNext) player.next() }
  function previous() { if (player && player.canGoPrevious) player.previous() }
  function expanded(value) { expandedCount = Math.max(0, expandedCount + (value ? 1 : -1)); if(value) refresh() }

  Timer { interval: root.expandedCount > 0 ? 8000 : 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
  Timer { interval: 1000; running: root.remaining > 0 || root.expandedCount > 0; repeat: true; onTriggered: root.now = Date.now()/1000 }
  Timer { id: feedbackTimer; interval: 7000; onTriggered: root.feedback = "" }

  ShellIpc {
    target: "bappoz.notch.service"
    function refresh(): void { root.refresh() }
    function status(): string { return JSON.stringify({loaded:true,busy:root.busy,players:root.players.length,files:root.shelf.length,agents:root.agents.length,systemBattery:root.systemBattery,lyricsState:root.lyricsState,lyricLines:root.lyrics.length}) }
  }
}
