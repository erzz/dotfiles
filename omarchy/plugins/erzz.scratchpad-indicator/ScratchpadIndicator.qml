import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "erzz.scratchpad-indicator"

  property bool scratchpadOpen: false
  property var specialWorkspaceByMonitor: ({})
  property var specialWorkspaceEventMonitors: ({})

  function setMonitorStates(states) {
    specialWorkspaceByMonitor = states
    scratchpadOpen = Object.keys(states).some(monitorName => states[monitorName])
  }

  function handleActiveSpecial(data) {
    const separator = data.indexOf(",")
    if (separator < 0) return

    const monitorName = data.slice(separator + 1)
    if (!monitorName) return

    const states = {}
    Object.keys(specialWorkspaceByMonitor).forEach(name => {
      states[name] = specialWorkspaceByMonitor[name]
    })
    states[monitorName] = data.slice(0, separator) === "special:scratchpad"

    const eventMonitors = {}
    Object.keys(specialWorkspaceEventMonitors).forEach(name => {
      eventMonitors[name] = true
    })
    eventMonitors[monitorName] = true
    specialWorkspaceEventMonitors = eventMonitors
    setMonitorStates(states)
  }

  Component.onCompleted: monitorQuery.running = true

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event && event.name === "activespecial")
        root.handleActiveSpecial(String(event.data || ""))
    }
  }

  Process {
    id: monitorQuery
    command: ["hyprctl", "-j", "monitors"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        let monitors
        try {
          monitors = JSON.parse(text || "[]")
        } catch (e) {
          return
        }
        if (!Array.isArray(monitors)) return

        const states = {}
        monitors.forEach(monitor => {
          if (!monitor || !monitor.name || root.specialWorkspaceEventMonitors[monitor.name]) return
          const specialWorkspace = monitor.specialWorkspace
          states[monitor.name] = !!specialWorkspace && specialWorkspace.name === "special:scratchpad"
        })

        // Events received while the startup query was in flight are newer than
        // its snapshot; preserve them so an old response cannot undo an update.
        Object.keys(root.specialWorkspaceEventMonitors).forEach(monitorName => {
          if (Object.prototype.hasOwnProperty.call(root.specialWorkspaceByMonitor, monitorName))
            states[monitorName] = root.specialWorkspaceByMonitor[monitorName]
        })
        root.setMonitorStates(states)
      }
    }
  }

  visible: scratchpadOpen
  implicitWidth: visible ? (vertical ? barSize : label.implicitWidth + Style.space(8)) : 0
  implicitHeight: visible ? (vertical ? label.implicitWidth + Style.space(8) : barSize) : 0

  Accessible.role: Accessible.StaticText
  Accessible.name: visible ? "Scratchpad workspace active" : ""

  Text {
    id: label

    anchors.centerIn: parent
    text: "SCRATCH"
    color: Color.urgent
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.bodySmall
    font.weight: Font.Bold
    font.letterSpacing: 0.5
    rotation: root.vertical ? -90 : 0
  }
}
