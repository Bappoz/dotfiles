import QtQuick
import Quickshell.Io

Item {
  id: root
  property var argv: []
  property var callback: null
  property string inputText:""
  property string output: ""
  property string errors: ""
  visible: false
  Process {
    id: process
    command: root.argv
    stdinEnabled: root.inputText !== ""
    onStarted: if(root.inputText !== "")write(root.inputText+"\n")
    stdout: StdioCollector { onStreamFinished: root.output = text.slice(0, 2000000) }
    stderr: StdioCollector { onStreamFinished: root.errors = text.slice(0, 1000) }
    onExited: function(code) {
      var result
      try { result = JSON.parse(root.output) }
      catch(e) { result = {ok: code === 0, error: root.errors || "A operação não retornou uma resposta válida"} }
      if (root.callback) root.callback(result)
      root.destroy()
    }
  }
  Component.onCompleted: process.running = true
}
