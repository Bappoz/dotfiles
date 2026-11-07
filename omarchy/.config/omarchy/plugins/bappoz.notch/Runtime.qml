pragma Singleton
import QtQuick

// The plugin's own service, shared only by its own component module. This also
// works in a replacement bar, whose host intentionally supplies no service API.
QtObject { property var model: null }
