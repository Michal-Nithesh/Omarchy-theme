import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "michal.system-island"

  readonly property string pluginDir: Quickshell.env("HOME") + "/.config/omarchy/plugins/michal.system-island"
  readonly property string backendScript: pluginDir + "/backend.py"

  // -------------------------------------------------------------
  // Fast Bar Telemetry State
  // -------------------------------------------------------------
  property string btIcon: "󰂯"
  property bool btEnabled: false
  property bool btConnected: false

  property string wifiIcon: "󰤨"
  property bool wifiEnabled: true
  property bool wifiConnected: true
  property string wifiSsid: ""

  property string audioIcon: "󰕾"
  property int sinkVol: 100
  property bool sinkMuted: false
  property int sourceVol: 50
  property bool sourceMuted: false

  property string displayIcon: "󰍹"
  property int brightnessPct: 20

  property string batIcon: "󰁹"
  property string batText: "--%"
  property int batPct: 0
  property string batStatus: "Unknown"
  property string batTimeRem: ""
  property real batHealth: 100.0
  property real batVolt: 0.0
  property real batTemp: 0.0
  property real batPower: 0.0
  property real batEnergyNow: 0.0
  property real batEnergyFull: 0.0
  property real batEnergyDesign: 0.0

  // -------------------------------------------------------------
  // Detailed Tab Data
  // -------------------------------------------------------------
  property string activeTab: "system" // "bluetooth" | "wifi" | "audio" | "display" | "system"
  property var btDetails: ({ "enabled": false, "adapter": "", "connected": [], "paired": [], "available": [] })
  property var wifiDetails: ({ "enabled": true, "connected": false, "current": {}, "networks": [], "ethernet": "Disconnected" })
  property var audioDetails: ({ "sinkVolume": 100, "sinkMuted": false, "sourceVolume": 50, "sourceMuted": false, "sinks": [], "sources": [] })
  property var displayDetails: ({ "brightness": 20, "monitors": [] })
  property var sysDetails: ({ "cpuPct": 0, "cpuTemp": 0, "ramUsed": 0, "ramTotal": 0, "ramPct": 0, "swapUsed": 0, "swapTotal": 0, "swapPct": 0, "diskUsed": 0, "diskTotal": 0, "diskPct": 0, "gpuTemp": 0 })

  property string wifiPasswordInput: ""
  property string selectedConnectSsid: ""
  property bool showPasswordPrompt: false

  // -------------------------------------------------------------
  // Fast Background Poller (every 3 seconds)
  // -------------------------------------------------------------
  Timer {
    id: fastPoller
    interval: 3000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.fetchFastStatus()
  }

  Process {
    id: fastProc
    command: ["python3", root.backendScript, "fast"]
    stdout: SplitParser {
      onRead: function(line) {
        if (!line || line.trim() === "") return
        try {
          var d = JSON.parse(line.trim())
          if (d.bluetooth) {
            root.btEnabled = d.bluetooth.enabled === true
            root.btConnected = d.bluetooth.connected === true
            root.btIcon = d.bluetooth.icon || (root.btEnabled ? "󰂯" : "󰂲")
          }
          if (d.network) {
            root.wifiEnabled = d.network.enabled === true
            root.wifiConnected = d.network.connected === true
            root.wifiSsid = d.network.ssid || ""
            root.wifiIcon = d.network.icon || "󰤨"
          }
          if (d.audio) {
            root.sinkVol = d.audio.sinkVolume || 0
            root.sinkMuted = d.audio.sinkMuted === true
            root.sourceVol = d.audio.sourceVolume || 0
            root.sourceMuted = d.audio.sourceMuted === true
            root.audioIcon = d.audio.icon || "󰕾"
          }
          if (d.display) {
            root.brightnessPct = d.display.brightness || 0
            root.displayIcon = d.display.icon || "󰍹"
          }
          if (d.battery) {
            root.batPct = d.battery.percentage || 0
            root.batStatus = d.battery.status || "Unknown"
            root.batIcon = d.battery.icon || "󰁹"
            root.batText = d.battery.text || (root.batPct + "%")
            root.batTimeRem = d.battery.timeRemaining || ""
            root.batHealth = d.battery.health || 100.0
            root.batVolt = d.battery.voltage || 0.0
            root.batTemp = d.battery.temp || 0.0
            root.batPower = d.battery.powerW || 0.0
            root.batEnergyNow = d.battery.energyNow || 0.0
            root.batEnergyFull = d.battery.energyFull || 0.0
            root.batEnergyDesign = d.battery.energyDesign || 0.0
          }
        } catch (e) {}
      }
    }
  }

  function fetchFastStatus() {
    if (!fastProc.running) fastProc.running = true
  }

  // -------------------------------------------------------------
  // Tab Poller (runs when popover is open)
  // -------------------------------------------------------------
  Timer {
    id: tabPoller
    interval: 2000
    repeat: true
    running: root.popoverOpen
    onTriggered: root.fetchActiveTabData()
  }

  Process {
    id: tabProc
    stdout: SplitParser {
      onRead: function(line) {
        if (!line || line.trim() === "") return
        try {
          var d = JSON.parse(line.trim())
          if (root.activeTab === "bluetooth") root.btDetails = d
          else if (root.activeTab === "wifi") root.wifiDetails = d
          else if (root.activeTab === "audio") root.audioDetails = d
          else if (root.activeTab === "display") root.displayDetails = d
          else if (root.activeTab === "system") {
            root.sysDetails = d
            if (d.battery) {
              root.batPct = d.battery.percentage || 0
              root.batStatus = d.battery.status || "Unknown"
              root.batTimeRem = d.battery.timeRemaining || ""
              root.batHealth = d.battery.health || 100.0
              root.batVolt = d.battery.voltage || 0.0
              root.batTemp = d.battery.temp || 0.0
              root.batPower = d.battery.powerW || 0.0
            }
          }
        } catch (e) {}
      }
    }
  }

  function fetchActiveTabData() {
    if (tabProc.running) return
    tabProc.command = ["python3", root.backendScript, "tab", root.activeTab]
    tabProc.running = true
  }

  // -------------------------------------------------------------
  // Helper Actions Executor
  // -------------------------------------------------------------
  function runAction(action, args) {
    var cmd = ["python3", root.backendScript, "action", action]
    if (args && args.length > 0) {
      for (var i = 0; i < args.length; i++) cmd.push(String(args[i]))
    }
    actionProc.command = cmd
    actionProc.running = true
    actionTimer.restart()
  }

  Process {
    id: actionProc
  }

  Timer {
    id: actionTimer
    interval: 350
    onTriggered: {
      root.fetchFastStatus()
      if (root.popoverOpen) root.fetchActiveTabData()
    }
  }

  // -------------------------------------------------------------
  // Popover State & Navigation
  // -------------------------------------------------------------
  property bool popoverOpen: false

  function close() {
    root.popoverOpen = false
    root.showPasswordPrompt = false
  }

  function openTab(tabName) {
    root.activeTab = tabName
    root.showPasswordPrompt = false
    root.fetchFastStatus()
    root.fetchActiveTabData()
    root.popoverOpen = true
  }

  function toggleTab(tabName) {
    if (root.popoverOpen && root.activeTab === tabName) {
      root.close()
    } else {
      root.openTab(tabName)
    }
  }

  IpcHandler {
    target: "michal.system-island"

    function toggleBluetooth() { root.toggleBluetooth() }
    function toggleWifi() { root.toggleWifi() }
    function toggleAudio() { root.toggleAudio() }
    function toggleDisplay() { root.toggleDisplay() }
    function toggleBattery() { root.toggleBattery() }
    function togglePower() { root.togglePowerMenu() }
    function closePower() { root.closePowerMenu() }
    function close() { root.close() }
    function refresh() { root.fetchFastStatus(); root.fetchActiveTabData() }
  }

  // Handlers called by broadcast()
  function toggleBluetooth() { root.toggleTab("bluetooth") }
  function toggleWifi() { root.toggleTab("wifi") }
  function toggleAudio() { root.toggleTab("audio") }
  function toggleDisplay() { root.toggleTab("display") }
  function toggleBattery() { root.toggleTab("system") }

  // -------------------------------------------------------------
  // Power & Session Menu State & Actions
  // -------------------------------------------------------------
  property bool powerMenuOpen: false
  property int selectedPowerIndex: 0

  function togglePowerMenu() {
    root.powerMenuOpen = !root.powerMenuOpen
    if (root.powerMenuOpen) {
      root.popoverOpen = false
      root.selectedPowerIndex = 0
    }
  }

  function closePowerMenu() {
    root.powerMenuOpen = false
  }

  function navigatePower(delta) {
    var next = root.selectedPowerIndex + delta
    if (next < 0) next = 3
    if (next > 3) next = 0
    root.selectedPowerIndex = next
  }

  function executePowerIndex(index) {
    root.closePowerMenu()
    if (index === 0) {
      Util.execDetached("omarchy-system-lock")
    } else if (index === 1) {
      Util.execDetached("omarchy-launch-screensaver force")
    } else if (index === 2) {
      Util.execDetached("omarchy-system-reboot")
    } else if (index === 3) {
      Util.execDetached("omarchy-system-shutdown")
    }
  }

  implicitWidth: island.implicitWidth
  implicitHeight: root.barSize

  // -------------------------------------------------------------
  // Bar Widget: Sakurazuki System Island Pill
  // -------------------------------------------------------------
  Rectangle {
    id: island
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    height: Math.min(26, root.barSize - 2)
    implicitWidth: islandRow.implicitWidth + 12
    radius: height / 2
    color: "#E614111A"
    border.color: "#443043"
    border.width: 1

    Row {
      id: islandRow
      anchors.centerIn: parent
      spacing: 6

      // 1. Bluetooth Indicator
      Rectangle {
        id: btBtn
        height: island.height - 4
        width: 22
        radius: height / 2
        color: (btArea.containsMouse || (root.popoverOpen && root.activeTab === "bluetooth"))
          ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.28) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
          anchors.centerIn: parent
          text: root.btIcon
          color: root.btConnected ? "#D9A6C4" : (root.btEnabled ? "#C2AEDF" : "#B8A3BB")
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }

        MouseArea {
          id: btArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: if (root.bar) root.bar.showTooltip(btBtn, "Bluetooth (" + (root.btEnabled ? "On" : "Off") + ")")
          onExited: if (root.bar) root.bar.hideTooltip(btBtn)
          onClicked: {
            if (root.bar) root.bar.hideTooltip(btBtn)
            root.toggleTab("bluetooth")
          }
        }
      }

      // Divider
      Rectangle {
        width: 1
        height: 12
        anchors.verticalCenter: parent.verticalCenter
        color: "#443043"
      }

      // 2. Wi-Fi / Network Indicator
      Rectangle {
        id: wifiBtn
        height: island.height - 4
        width: 22
        radius: height / 2
        color: (wifiArea.containsMouse || (root.popoverOpen && root.activeTab === "wifi"))
          ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.28) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
          anchors.centerIn: parent
          text: root.wifiIcon
          color: root.wifiConnected ? "#D9A6C4" : (root.wifiEnabled ? "#C2AEDF" : "#B8A3BB")
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }

        MouseArea {
          id: wifiArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: if (root.bar) root.bar.showTooltip(wifiBtn, "Network: " + (root.wifiSsid ? root.wifiSsid : "Disconnected"))
          onExited: if (root.bar) root.bar.hideTooltip(wifiBtn)
          onClicked: {
            if (root.bar) root.bar.hideTooltip(wifiBtn)
            root.toggleTab("wifi")
          }
        }
      }

      // Divider
      Rectangle {
        width: 1
        height: 12
        anchors.verticalCenter: parent.verticalCenter
        color: "#443043"
      }

      // 3. Audio Indicator
      Rectangle {
        id: audioBtn
        height: island.height - 4
        width: 22
        radius: height / 2
        color: (audioArea.containsMouse || (root.popoverOpen && root.activeTab === "audio"))
          ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.28) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
          anchors.centerIn: parent
          text: root.audioIcon
          color: root.sinkMuted ? "#B8A3BB" : "#C2AEDF"
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }

        MouseArea {
          id: audioArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton
          onEntered: if (root.bar) root.bar.showTooltip(audioBtn, "Volume: " + root.sinkVol + "%" + (root.sinkMuted ? " [MUTED]" : ""))
          onExited: if (root.bar) root.bar.hideTooltip(audioBtn)
          onClicked: function(mouse) {
            if (root.bar) root.bar.hideTooltip(audioBtn)
            if (mouse.button === Qt.MiddleButton) {
              root.runAction("toggle-sink-mute")
            } else {
              root.toggleTab("audio")
            }
          }
          onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) root.runAction("adjust-volume", ["5%+"])
            else if (wheel.angleDelta.y < 0) root.runAction("adjust-volume", ["5%-"])
          }
        }
      }

      // Divider
      Rectangle {
        width: 1
        height: 12
        anchors.verticalCenter: parent.verticalCenter
        color: "#443043"
      }

      // 4. Display / Brightness Indicator
      Rectangle {
        id: displayBtn
        height: island.height - 4
        width: 22
        radius: height / 2
        color: (displayArea.containsMouse || (root.popoverOpen && root.activeTab === "display"))
          ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.28) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
          anchors.centerIn: parent
          text: root.displayIcon
          color: "#C2AEDF"
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }

        MouseArea {
          id: displayArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: if (root.bar) root.bar.showTooltip(displayBtn, "Brightness: " + root.brightnessPct + "% (Scroll to adjust)")
          onExited: if (root.bar) root.bar.hideTooltip(displayBtn)
          onClicked: {
            if (root.bar) root.bar.hideTooltip(displayBtn)
            root.toggleTab("display")
          }
          onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) root.runAction("adjust-brightness", ["5%+"])
            else if (wheel.angleDelta.y < 0) root.runAction("adjust-brightness", ["5%-"])
          }
        }
      }

      // Divider
      Rectangle {
        width: 1
        height: 12
        anchors.verticalCenter: parent.verticalCenter
        color: "#443043"
      }

      // 5. Battery & System Indicator (Icon + Percentage)
      Rectangle {
        id: batBtn
        height: island.height - 4
        implicitWidth: batRow.implicitWidth + 8
        radius: height / 2
        color: (batArea.containsMouse || (root.popoverOpen && root.activeTab === "system"))
          ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.28) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Row {
          id: batRow
          anchors.centerIn: parent
          spacing: 4

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.batIcon
            color: root.batPct <= 15 ? "#E06C75" : "#D9A6C4"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.batText
            color: "#F0DCEB"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body - 1
            font.bold: true
          }
        }

        MouseArea {
          id: batArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: if (root.bar) root.bar.showTooltip(batBtn, "Battery: " + root.batText + " (" + root.batStatus + (root.batTimeRem ? ", " + root.batTimeRem : "") + ")")
          onExited: if (root.bar) root.bar.hideTooltip(batBtn)
          onClicked: {
            if (root.bar) root.bar.hideTooltip(batBtn)
            root.toggleTab("system")
          }
        }
      }

      // Divider
      Rectangle {
        width: 1
        height: 12
        anchors.verticalCenter: parent.verticalCenter
        color: "#443043"
      }

      // 6. Power & Session Button (Near battery in the right top corner)
      Rectangle {
        id: powerBtn
        height: island.height - 4
        width: 22
        radius: height / 2
        color: (powerArea.containsMouse || root.powerMenuOpen)
          ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.28) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
          anchors.centerIn: parent
          text: ""
          color: root.powerMenuOpen ? "#D9A6C4" : (powerArea.containsMouse ? "#F0DCEB" : "#C2AEDF")
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
        }

        MouseArea {
          id: powerArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: if (root.bar) root.bar.showTooltip(powerBtn, "Power & Session")
          onExited: if (root.bar) root.bar.hideTooltip(powerBtn)
          onClicked: {
            if (root.bar) root.bar.hideTooltip(powerBtn)
            root.togglePowerMenu()
          }
        }
      }
    }
  }

  // -------------------------------------------------------------
  // Layer-Shell Popover Card
  // -------------------------------------------------------------
  KeyboardPanel {
    id: popupCard
    anchorItem: root
    owner: root
    bar: root.bar
    open: root.popoverOpen
    centerOnBar: false
    focusTarget: popoverFocusScope
    padding: 16
    contentWidth: 440
    contentHeight: 490

    onOpenChanged: {
      if (open) {
        root.fetchFastStatus()
        root.fetchActiveTabData()
      }
    }

    FocusScope {
      id: popoverFocusScope
      anchors.fill: parent
      focus: true

      Keys.onEscapePressed: root.close()

      ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Top Navigation Tab Bar
        RowLayout {
          Layout.fillWidth: true
          spacing: 6

          // Tab Button Component
          component NavTabBtn: Rectangle {
            id: navBtn
            required property string tabId
            required property string iconText
            required property string title
            Layout.fillWidth: true
            height: 30
            radius: 6
            color: root.activeTab === tabId ? "#A87692" : (navArea.containsMouse ? "#2A1B2A" : "#211925")
            border.color: root.activeTab === tabId ? "#D9A6C4" : (navArea.containsMouse ? "#88758F" : "#443043")
            border.width: 1

            Behavior on color { ColorAnimation { duration: 120 } }

            Row {
              id: navRow
              anchors.centerIn: parent
              spacing: 6
              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: navBtn.iconText
                color: root.activeTab === navBtn.tabId ? "#14111A" : "#C2AEDF"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: 13
              }
              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: navBtn.title
                color: root.activeTab === navBtn.tabId ? "#14111A" : "#F0DCEB"
                font.bold: root.activeTab === navBtn.tabId
                font.pixelSize: 11
              }
            }

            MouseArea {
              id: navArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.openTab(navBtn.tabId)
            }
          }

          NavTabBtn { tabId: "bluetooth"; iconText: "󰂯"; title: "BT" }
          NavTabBtn { tabId: "wifi"; iconText: "󰤨"; title: "Wi-Fi" }
          NavTabBtn { tabId: "audio"; iconText: "󰕾"; title: "Audio" }
          NavTabBtn { tabId: "display"; iconText: "󰍹"; title: "Display" }
          NavTabBtn { tabId: "system"; iconText: "󰁹"; title: "System" }

          // Close Button
          Rectangle {
            width: 28
            height: 28
            radius: 14
            color: closeArea.containsMouse ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.35) : "transparent"
            border.color: closeArea.containsMouse ? "#D9A6C4" : "transparent"
            border.width: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
              anchors.centerIn: parent
              text: "✕"
              color: closeArea.containsMouse ? "#F0DCEB" : "#B8A3BB"
              font.pixelSize: 12
              font.bold: true
            }

            MouseArea {
              id: closeArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.close()
            }
          }
        }

        // Horizontal Line
        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: "#443043"
        }

        // =========================================================
        // VIEW 1: Bluetooth Panel
        // =========================================================
        ColumnLayout {
          visible: root.activeTab === "bluetooth"
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 10

          // Power and Adapter status banner
          Rectangle {
            Layout.fillWidth: true
            height: 54
            radius: 8
            color: "#211925"
            border.color: "#443043"
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 12
              anchors.rightMargin: 12
              spacing: 10

              Text {
                text: "󰂯"
                color: root.btDetails.enabled ? "#D9A6C4" : "#88758F"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: 18
                Layout.alignment: Qt.AlignVCenter
              }

              Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                  text: root.btDetails.adapter || "Bluetooth Controller"
                  color: "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 12
                }
                Text {
                  text: root.btDetails.enabled ? "Adapter is Active" : "Adapter is Turned Off"
                  color: root.btDetails.enabled ? "#D9A6C4" : "#B8A3BB"
                  font.pixelSize: 10
                }
              }

              Rectangle {
                width: 78
                height: 26
                radius: 6
                color: root.btDetails.enabled ? "#A87692" : "#14111A"
                border.color: root.btDetails.enabled ? "#D9A6C4" : "#443043"
                border.width: 1
                Layout.alignment: Qt.AlignVCenter

                Text {
                  anchors.centerIn: parent
                  text: root.btDetails.enabled ? "Disable" : "Enable"
                  color: root.btDetails.enabled ? "#14111A" : "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 11
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.runAction("toggle-bluetooth")
                }
              }
            }
          }

          // Connected Devices Section
          Text {
            text: "CONNECTED DEVICES"
            color: "#A87692"
            font.bold: true
            font.pixelSize: 10
            font.letterSpacing: 1
          }

          // Empty state for connected devices
          Rectangle {
            visible: (root.btDetails.connected || []).length === 0
            Layout.fillWidth: true
            height: 36
            radius: 6
            color: "#211925"
            border.color: "#443043"
            border.width: 1

            Text {
              anchors.centerIn: parent
              text: "󰂲  No devices connected"
              color: "#88758F"
              font.pixelSize: 11
            }
          }

          ListView {
            Layout.fillWidth: true
            height: Math.min(contentHeight, 80)
            clip: true
            spacing: 4
            model: root.btDetails.connected || []
            visible: (root.btDetails.connected || []).length > 0
            delegate: Rectangle {
              width: parent.width
              height: 36
              radius: 6
              color: "#211925"
              border.color: "#443043"
              border.width: 1

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                  text: "󰂱"
                  color: "#D9A6C4"
                  font.pixelSize: 14
                  Layout.alignment: Qt.AlignVCenter
                }

                Text {
                  text: modelData.name
                  color: "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 11
                  Layout.fillWidth: true
                  elide: Text.ElideRight
                  Layout.alignment: Qt.AlignVCenter
                }

                Rectangle {
                  width: 74
                  height: 22
                  radius: 4
                  color: "#14111A"
                  border.color: "#443043"
                  border.width: 1
                  Layout.alignment: Qt.AlignVCenter

                  Text {
                    anchors.centerIn: parent
                    text: "Disconnect"
                    color: "#D9A6C4"
                    font.pixelSize: 10
                    font.bold: true
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runAction("disconnect-bluetooth", [modelData.mac])
                  }
                }
              }
            }
          }

          // Paired / Saved Devices
          RowLayout {
            Layout.fillWidth: true
            Text {
              text: "PAIRED DEVICES"
              color: "#A87692"
              font.bold: true
              font.pixelSize: 10
              font.letterSpacing: 1
            }
            Item { Layout.fillWidth: true }
          }

          ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.btDetails.paired || []
            spacing: 4
            delegate: Rectangle {
              width: parent.width
              height: 36
              radius: 6
              color: "#211925"
              border.color: "#443043"
              border.width: 1

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                  text: "󰂯"
                  color: "#C2AEDF"
                  font.pixelSize: 14
                  Layout.alignment: Qt.AlignVCenter
                }

                Text {
                  text: modelData.name
                  color: "#F0DCEB"
                  font.pixelSize: 11
                  Layout.fillWidth: true
                  elide: Text.ElideRight
                  Layout.alignment: Qt.AlignVCenter
                }

                Rectangle {
                  width: 68
                  height: 22
                  radius: 4
                  color: "#14111A"
                  border.color: "#443043"
                  border.width: 1
                  Layout.alignment: Qt.AlignVCenter

                  Text {
                    anchors.centerIn: parent
                    text: "Connect"
                    color: "#D9A6C4"
                    font.pixelSize: 10
                    font.bold: true
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runAction("connect-bluetooth", [modelData.mac])
                  }
                }
              }
            }
          }
        }

        // =========================================================
        // VIEW 2: Wi-Fi / Network Panel
        // =========================================================
        ColumnLayout {
          visible: root.activeTab === "wifi"
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 10

          // Wi-Fi State & Active Connection Hero
          Rectangle {
            Layout.fillWidth: true
            height: 78
            radius: 8
            color: "#211925"
            border.color: "#443043"
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 10

              Text {
                text: root.wifiDetails.connected ? "󰤨" : "󰤮"
                color: root.wifiDetails.connected ? "#D9A6C4" : "#88758F"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: 22
                Layout.alignment: Qt.AlignVCenter
              }

              Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 3

                Row {
                  spacing: 6
                  Text {
                    text: root.wifiDetails.connected ? (root.wifiDetails.current.ssid || "Connected") : "Disconnected"
                    color: "#F0DCEB"
                    font.bold: true
                    font.pixelSize: 13
                  }
                  Text {
                    visible: root.wifiDetails.connected
                    text: "(" + (root.wifiDetails.current.signal || 0) + "%)"
                    color: "#D9A6C4"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                  }
                }

                Text {
                  visible: root.wifiDetails.connected
                  text: "IP: " + (root.wifiDetails.current.ip || "—") + "  ·  GW: " + (root.wifiDetails.current.gateway || "—")
                  color: "#B8A3BB"
                  font.pixelSize: 10
                }

                Text {
                  visible: root.wifiDetails.connected
                  text: "Security: " + (root.wifiDetails.current.security || "Open") + "  ·  " + (root.wifiDetails.current.device || "wlp2s0")
                  color: "#88758F"
                  font.pixelSize: 9
                }
              }

              Column {
                Layout.alignment: Qt.AlignVCenter
                spacing: 6

                Rectangle {
                  width: 80
                  height: 24
                  radius: 6
                  color: root.wifiDetails.enabled ? "#A87692" : "#14111A"
                  border.color: root.wifiDetails.enabled ? "#D9A6C4" : "#443043"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: root.wifiDetails.enabled ? "Wi-Fi On" : "Wi-Fi Off"
                    color: root.wifiDetails.enabled ? "#14111A" : "#F0DCEB"
                    font.bold: true
                    font.pixelSize: 10
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runAction("toggle-wifi")
                  }
                }

                Rectangle {
                  visible: root.wifiDetails.connected
                  width: 80
                  height: 24
                  radius: 6
                  color: "#14111A"
                  border.color: "#443043"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: "Disconnect"
                    color: "#D9A6C4"
                    font.pixelSize: 10
                    font.bold: true
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runAction("disconnect-wifi")
                  }
                }
              }
            }
          }

          // Password Inline Prompt
          Rectangle {
            visible: root.showPasswordPrompt
            Layout.fillWidth: true
            height: 36
            radius: 6
            color: "#14111A"
            border.color: "#D9A6C4"
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 10
              anchors.rightMargin: 10
              spacing: 8

              Text {
                text: "Pass for " + root.selectedConnectSsid + ":"
                color: "#F0DCEB"
                font.pixelSize: 10
                font.bold: true
              }

              Rectangle {
                Layout.fillWidth: true
                height: 24
                radius: 4
                color: "#211925"
                border.color: "#443043"

                TextInput {
                  id: passInput
                  anchors.fill: parent
                  anchors.leftMargin: 6
                  anchors.rightMargin: 6
                  color: "#F0DCEB"
                  echoMode: TextInput.Password
                  verticalAlignment: TextInput.AlignVCenter
                  font.pixelSize: 11
                  onAccepted: {
                    root.runAction("connect-wifi", [root.selectedConnectSsid, passInput.text])
                    root.showPasswordPrompt = false
                  }
                }
              }

              Rectangle {
                width: 52
                height: 24
                radius: 4
                color: "#A87692"
                Text { anchors.centerIn: parent; text: "Join"; color: "#14111A"; font.bold: true; font.pixelSize: 10 }
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.runAction("connect-wifi", [root.selectedConnectSsid, passInput.text])
                    root.showPasswordPrompt = false
                  }
                }
              }
            }
          }

          // Available Networks Header with Rescan Button
          RowLayout {
            Layout.fillWidth: true
            Text {
              text: "NEARBY NETWORKS"
              color: "#A87692"
              font.bold: true
              font.pixelSize: 10
              font.letterSpacing: 1
            }
            Item { Layout.fillWidth: true }
            Rectangle {
              height: 22
              width: rescanRow.implicitWidth + 12
              radius: 4
              color: "#211925"
              border.color: "#443043"

              Row {
                id: rescanRow
                anchors.centerIn: parent
                spacing: 4
                Text { text: "󰑐"; color: "#D9A6C4"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Rescan"; color: "#F0DCEB"; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runAction("rescan-wifi")
              }
            }
          }

          // Networks List
          ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.wifiDetails.networks || []
            spacing: 4
            delegate: Rectangle {
              width: parent.width
              height: 36
              radius: 6
              color: "#211925"
              border.color: "#443043"
              border.width: 1

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                  text: modelData.security ? "󰌾" : "󰌿"
                  color: modelData.security ? "#D9A6C4" : "#88758F"
                  font.pixelSize: 13
                  Layout.alignment: Qt.AlignVCenter
                }

                Text {
                  text: modelData.ssid
                  color: "#F0DCEB"
                  font.pixelSize: 11
                  Layout.fillWidth: true
                  elide: Text.ElideRight
                  Layout.alignment: Qt.AlignVCenter
                }

                Text {
                  text: modelData.signal + "%"
                  color: "#B8A3BB"
                  font.pixelSize: 10
                  width: 34
                  horizontalAlignment: Text.AlignRight
                  Layout.alignment: Qt.AlignVCenter
                }

                Rectangle {
                  width: 64
                  height: 22
                  radius: 4
                  color: "#14111A"
                  border.color: "#443043"
                  border.width: 1
                  Layout.alignment: Qt.AlignVCenter

                  Text {
                    anchors.centerIn: parent
                    text: "Connect"
                    color: "#D9A6C4"
                    font.pixelSize: 10
                    font.bold: true
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (modelData.security && modelData.security.indexOf("WPA") !== -1) {
                        root.selectedConnectSsid = modelData.ssid
                        root.showPasswordPrompt = true
                        passInput.text = ""
                        passInput.forceActiveFocus()
                      } else {
                        root.runAction("connect-wifi", [modelData.ssid])
                      }
                    }
                  }
                }
              }
            }
          }
        }

        // =========================================================
        // VIEW 3: Audio / Volume Panel
        // =========================================================
        ColumnLayout {
          visible: root.activeTab === "audio"
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 12

          // Speaker Output Volume Card
          Rectangle {
            Layout.fillWidth: true
            height: 84
            radius: 8
            color: "#211925"
            border.color: "#443043"
            border.width: 1

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 8

              RowLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                  spacing: 6
                  Text {
                    text: root.sinkMuted ? "󰝟" : "󰕾"
                    color: root.sinkMuted ? "#E58B9A" : "#A87692"
                    font.pixelSize: 13
                  }
                  Text {
                    text: "SPEAKER OUTPUT"
                    color: "#A87692"
                    font.bold: true
                    font.pixelSize: 10
                    font.letterSpacing: 1
                  }
                }

                Item { Layout.fillWidth: true }

                Text {
                  text: root.sinkMuted ? "MUTED" : (root.sinkVol + "%")
                  color: root.sinkMuted ? "#E58B9A" : "#D9A6C4"
                  font.bold: true
                  font.pixelSize: 11
                }

                Rectangle {
                  width: 64
                  height: 24
                  radius: 6
                  color: root.sinkMuted ? "#A87692" : "#14111A"
                  border.color: "#443043"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: root.sinkMuted ? "Unmute" : "Mute"
                    color: root.sinkMuted ? "#14111A" : "#F0DCEB"
                    font.bold: true
                    font.pixelSize: 10
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.runAction("toggle-sink-mute")
                  }
                }
              }

              // Interactive Slider Row
              RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                  text: "󰕿"
                  color: "#88758F"
                  font.pixelSize: 13
                }

                Rectangle {
                  id: sinkSliderArea
                  Layout.fillWidth: true
                  height: 18
                  color: "transparent"

                  Rectangle {
                    id: sinkTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 6
                    radius: 3
                    color: "#14111A"
                    border.color: "#443043"
                    border.width: 1

                    Rectangle {
                      height: parent.height
                      width: parent.width * (Math.min(100, Math.max(0, root.sinkVol)) / 100)
                      radius: 3
                      color: root.sinkMuted ? "#443043" : "#A87692"
                    }

                    Rectangle {
                      width: 12
                      height: 12
                      radius: 6
                      anchors.verticalCenter: parent.verticalCenter
                      x: Math.max(0, Math.min(parent.width - width, (parent.width * (Math.min(100, Math.max(0, root.sinkVol)) / 100)) - width / 2))
                      color: root.sinkMuted ? "#88758F" : "#D9A6C4"
                      border.color: "#14111A"
                      border.width: 1
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: function(mouse) {
                      var pct = Math.round(Math.min(100, Math.max(0, (mouse.x / width) * 100)))
                      root.sinkVol = pct
                      root.runAction("set-volume", [pct])
                    }
                    onClicked: function(mouse) {
                      var pct = Math.round(Math.min(100, Math.max(0, (mouse.x / width) * 100)))
                      root.sinkVol = pct
                      root.runAction("set-volume", [pct])
                    }
                  }
                }

                Text {
                  text: "󰕾"
                  color: "#88758F"
                  font.pixelSize: 13
                }
              }
            }
          }

          // Microphone Volume Card
          Rectangle {
            Layout.fillWidth: true
            height: 84
            radius: 8
            color: "#211925"
            border.color: "#443043"
            border.width: 1

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 8

              RowLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                  spacing: 6
                  Text {
                    text: root.sourceMuted ? "󰍭" : "󰍬"
                    color: root.sourceMuted ? "#E58B9A" : "#A87692"
                    font.pixelSize: 13
                  }
                  Text {
                    text: "MICROPHONE INPUT"
                    color: "#A87692"
                    font.bold: true
                    font.pixelSize: 10
                    font.letterSpacing: 1
                  }
                }

                Item { Layout.fillWidth: true }

                Text {
                  text: root.sourceMuted ? "MUTED" : (root.sourceVol + "%")
                  color: root.sourceMuted ? "#E58B9A" : "#C2AEDF"
                  font.bold: true
                  font.pixelSize: 11
                }

                Rectangle {
                  width: 64
                  height: 24
                  radius: 6
                  color: root.sourceMuted ? "#A87692" : "#14111A"
                  border.color: "#443043"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: root.sourceMuted ? "Unmute" : "Mute"
                    color: root.sourceMuted ? "#14111A" : "#F0DCEB"
                    font.bold: true
                    font.pixelSize: 10
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.runAction("toggle-source-mute")
                  }
                }
              }

              // Interactive Slider Row
              RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                  text: "󰍭"
                  color: "#88758F"
                  font.pixelSize: 13
                }

                Rectangle {
                  id: srcSliderArea
                  Layout.fillWidth: true
                  height: 18
                  color: "transparent"

                  Rectangle {
                    id: srcTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 6
                    radius: 3
                    color: "#14111A"
                    border.color: "#443043"
                    border.width: 1

                    Rectangle {
                      height: parent.height
                      width: parent.width * (Math.min(100, Math.max(0, root.sourceVol)) / 100)
                      radius: 3
                      color: root.sourceMuted ? "#443043" : "#C2AEDF"
                    }

                    Rectangle {
                      width: 12
                      height: 12
                      radius: 6
                      anchors.verticalCenter: parent.verticalCenter
                      x: Math.max(0, Math.min(parent.width - width, (parent.width * (Math.min(100, Math.max(0, root.sourceVol)) / 100)) - width / 2))
                      color: root.sourceMuted ? "#88758F" : "#C2AEDF"
                      border.color: "#14111A"
                      border.width: 1
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: function(mouse) {
                      var pct = Math.round(Math.min(100, Math.max(0, (mouse.x / width) * 100)))
                      root.sourceVol = pct
                      root.runAction("set-source-volume", [pct])
                    }
                    onClicked: function(mouse) {
                      var pct = Math.round(Math.min(100, Math.max(0, (mouse.x / width) * 100)))
                      root.sourceVol = pct
                      root.runAction("set-source-volume", [pct])
                    }
                  }
                }

                Text {
                  text: "󰍬"
                  color: "#88758F"
                  font.pixelSize: 13
                }
              }
            }
          }

          // Devices Section
          Text {
            text: "ACTIVE AUDIO DEVICES"
            color: "#A87692"
            font.bold: true
            font.pixelSize: 10
            font.letterSpacing: 1
          }

          ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: root.audioDetails.sinks || []
            delegate: Rectangle {
              width: parent.width
              height: 38
              radius: 6
              color: modelData.active ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.22) : "#211925"
              border.color: modelData.active ? "#A87692" : "#443043"
              border.width: 1

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                  text: modelData.active ? "󰓃" : "󰕾"
                  color: modelData.active ? "#D9A6C4" : "#88758F"
                  font.pixelSize: 13
                }

                Text {
                  text: modelData.label
                  color: "#F0DCEB"
                  font.bold: modelData.active
                  font.pixelSize: 11
                  Layout.fillWidth: true
                  elide: Text.ElideRight
                }

                Rectangle {
                  visible: modelData.active
                  width: 100
                  height: 22
                  radius: 5
                  color: Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.28)
                  border.color: "#A87692"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: "󰄬 Active Output"
                    color: "#F0DCEB"
                    font.bold: true
                    font.pixelSize: 10
                  }
                }

                Rectangle {
                  visible: !modelData.active
                  width: 64
                  height: 22
                  radius: 5
                  color: "#14111A"
                  border.color: "#443043"
                  border.width: 1

                  Text {
                    anchors.centerIn: parent
                    text: "Select"
                    color: "#D9A6C4"
                    font.bold: true
                    font.pixelSize: 10
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runAction("set-sink", [modelData.name])
                  }
                }
              }
            }
          }
        }

        // =========================================================
        // VIEW 4: Display & Brightness Panel
        // =========================================================
        ColumnLayout {
          visible: root.activeTab === "display"
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 12

          // Brightness Slider Card
          Rectangle {
            Layout.fillWidth: true
            height: 84
            radius: 8
            color: "#211925"
            border.color: "#443043"
            border.width: 1

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 8

              RowLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                  spacing: 6
                  Text {
                    text: "󰃠"
                    color: "#A87692"
                    font.pixelSize: 13
                  }
                  Text {
                    text: "DISPLAY BRIGHTNESS"
                    color: "#A87692"
                    font.bold: true
                    font.pixelSize: 10
                    font.letterSpacing: 1
                  }
                }

                Item { Layout.fillWidth: true }

                Text {
                  text: root.brightnessPct + "%"
                  color: "#D9A6C4"
                  font.bold: true
                  font.pixelSize: 11
                }
              }

              // Brightness Slider Row
              RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                  text: "󰃞"
                  color: "#88758F"
                  font.pixelSize: 13
                }

                Rectangle {
                  id: brightSliderArea
                  Layout.fillWidth: true
                  height: 18
                  color: "transparent"

                  Rectangle {
                    id: brightTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 6
                    radius: 3
                    color: "#14111A"
                    border.color: "#443043"
                    border.width: 1

                    Rectangle {
                      height: parent.height
                      width: parent.width * (Math.min(100, Math.max(0, root.brightnessPct)) / 100)
                      radius: 3
                      color: "#D9A6C4"
                    }

                    Rectangle {
                      width: 12
                      height: 12
                      radius: 6
                      anchors.verticalCenter: parent.verticalCenter
                      x: Math.max(0, Math.min(parent.width - width, (parent.width * (Math.min(100, Math.max(0, root.brightnessPct)) / 100)) - width / 2))
                      color: "#D9A6C4"
                      border.color: "#14111A"
                      border.width: 1
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: function(mouse) {
                      var pct = Math.round(Math.min(100, Math.max(0, (mouse.x / width) * 100)))
                      root.brightnessPct = pct
                      root.runAction("set-brightness", [pct])
                    }
                    onClicked: function(mouse) {
                      var pct = Math.round(Math.min(100, Math.max(0, (mouse.x / width) * 100)))
                      root.brightnessPct = pct
                      root.runAction("set-brightness", [pct])
                    }
                  }
                }

                Text {
                  text: "󰃠"
                  color: "#88758F"
                  font.pixelSize: 13
                }
              }
            }
          }

          // Monitor Info Card
          ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.displayDetails.monitors || []
            spacing: 8
            delegate: Rectangle {
              id: monCardDelegate
              required property var modelData
              width: parent.width
              implicitHeight: monCol.implicitHeight + 24
              radius: 8
              color: "#211925"
              border.color: "#443043"
              border.width: 1

              ColumnLayout {
                id: monCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                  Layout.fillWidth: true
                  spacing: 6

                  Text {
                    text: "󰍹"
                    color: "#D9A6C4"
                    font.pixelSize: 14
                  }

                  Text {
                    text: monCardDelegate.modelData.name + (monCardDelegate.modelData.description ? (" (" + monCardDelegate.modelData.description + ")") : "")
                    color: "#F0DCEB"
                    font.bold: true
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                  }

                  Rectangle {
                    height: 20
                    implicitWidth: resTxt.implicitWidth + 12
                    radius: 4
                    color: "#14111A"
                    border.color: "#443043"
                    border.width: 1

                    Text {
                      id: resTxt
                      anchors.centerIn: parent
                      text: monCardDelegate.modelData.width + "x" + monCardDelegate.modelData.height + " @" + monCardDelegate.modelData.refreshRate + "Hz"
                      color: "#A87692"
                      font.bold: true
                      font.pixelSize: 10
                    }
                  }
                }

                RowLayout {
                  Layout.fillWidth: true
                  spacing: 8

                  Text {
                    text: "Scale: " + monCardDelegate.modelData.scale + "x  ·  " + (monCardDelegate.modelData.focused ? "Primary Focused Display" : "Secondary Display")
                    color: "#B8A3BB"
                    font.pixelSize: 10
                  }
                }

                Rectangle {
                  Layout.fillWidth: true
                  height: 1
                  color: "#443043"
                }

                Text {
                  text: "SUPPORTED DISPLAY MODES"
                  color: "#A87692"
                  font.bold: true
                  font.pixelSize: 9
                  font.letterSpacing: 1
                }

                Flow {
                  Layout.fillWidth: true
                  spacing: 6

                  Repeater {
                    model: monCardDelegate.modelData.modes || []
                    Rectangle {
                      id: modeBadge
                      required property var modelData
                      height: 24
                      implicitWidth: modeText.implicitWidth + 14
                      radius: 5
                      readonly property bool isCurrent: modeBadge.modelData.indexOf(monCardDelegate.modelData.width + "x" + monCardDelegate.modelData.height) !== -1 && modeBadge.modelData.indexOf(Math.round(monCardDelegate.modelData.refreshRate) + "") !== -1
                      color: isCurrent ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.25) : "#14111A"
                      border.color: isCurrent ? "#A87692" : "#443043"
                      border.width: 1

                      Text {
                        id: modeText
                        anchors.centerIn: parent
                        text: modeBadge.modelData
                        color: modeBadge.isCurrent ? "#F0DCEB" : "#B8A3BB"
                        font.bold: modeBadge.isCurrent
                        font.pixelSize: 10
                      }

                      MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.runAction("set-mode", [monCardDelegate.modelData.name, modeBadge.modelData])
                      }
                    }
                  }
                }

                Item { height: 4 }

                Rectangle {
                  Layout.fillWidth: true
                  height: 30
                  radius: 6
                  color: "#14111A"
                  border.color: "#443043"
                  border.width: 1

                  RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                      text: "󰍹"
                      color: "#D9A6C4"
                      font.pixelSize: 12
                    }
                    Text {
                      text: "Open Display Settings (omarchy display)"
                      color: "#D9A6C4"
                      font.bold: true
                      font.pixelSize: 11
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                      if (root.bar) root.bar.run("omarchy display")
                    }
                  }
                }
              }
            }
          }
        }

        // =========================================================
        // VIEW 5: Battery & System Usage Dashboard
        // =========================================================
        ColumnLayout {
          visible: root.activeTab === "system"
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 10

          // Battery Details Hero
          Rectangle {
            Layout.fillWidth: true
            height: 84
            radius: 8
            color: "#211925"
            border.color: "#443043"
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 12

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                  spacing: 8

                  Text {
                    text: root.batIcon
                    color: "#D9A6C4"
                    font.pixelSize: 18
                  }

                  Text {
                    text: root.batText
                    color: "#F0DCEB"
                    font.bold: true
                    font.pixelSize: 18
                  }

                  Rectangle {
                    height: 20
                    implicitWidth: statusLabel.implicitWidth + 12
                    radius: 4
                    color: root.batStatus.toLowerCase() === "charging" ? Qt.rgba(168 / 255, 197 / 255, 160 / 255, 0.2) : (root.batStatus.toLowerCase() === "discharging" ? Qt.rgba(229 / 255, 139 / 255, 154 / 255, 0.2) : "#14111A")
                    border.color: root.batStatus.toLowerCase() === "charging" ? "#A8C5A0" : (root.batStatus.toLowerCase() === "discharging" ? "#E58B9A" : "#443043")
                    border.width: 1

                    Text {
                      id: statusLabel
                      anchors.centerIn: parent
                      text: root.batStatus.toUpperCase()
                      color: root.batStatus.toLowerCase() === "charging" ? "#A8C5A0" : (root.batStatus.toLowerCase() === "discharging" ? "#E58B9A" : "#B8A3BB")
                      font.bold: true
                      font.pixelSize: 9
                    }
                  }
                }

                Text {
                  text: root.batTimeRem ? ("Remaining: " + root.batTimeRem) : "Plugged into AC power"
                  color: "#D9A6C4"
                  font.pixelSize: 11
                }

                Text {
                  text: "Health: " + root.batHealth + "%  ·  " + root.batVolt + "V  ·  " + root.batTemp + "°C  ·  " + root.batPower + "W"
                  color: "#88758F"
                  font.pixelSize: 10
                }
              }

              // Power consumption gauge / card
              Rectangle {
                width: 68
                height: 60
                radius: 6
                color: "#14111A"
                border.color: "#443043"
                border.width: 1

                ColumnLayout {
                  anchors.centerIn: parent
                  spacing: 2

                  Text {
                    text: "⚡"
                    color: "#D9A6C4"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                  }

                  Text {
                    text: root.batPower + " W"
                    color: "#F0DCEB"
                    font.bold: true
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignHCenter
                  }

                  Text {
                    text: root.batStatus.toLowerCase() === "charging" ? "Rate" : "Drain"
                    color: "#88758F"
                    font.pixelSize: 9
                    Layout.alignment: Qt.AlignHCenter
                  }
                }
              }
            }
          }

          // System Metrics Header
          Text {
            text: "SYSTEM USAGE & HARDWARE METRICS"
            color: "#A87692"
            font.bold: true
            font.pixelSize: 10
            font.letterSpacing: 1
          }

          // Metric Row Component
          component MetricCard: Rectangle {
            id: mCard
            required property string icon
            required property string label
            required property string valueText
            required property real fraction
            required property string extra
            required property color barColor
            Layout.fillWidth: true
            height: 48
            radius: 6
            color: "#211925"
            border.color: "#443043"
            border.width: 1

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 8
              spacing: 5

              RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                  text: mCard.icon
                  color: mCard.barColor
                  font.pixelSize: 12
                }

                Text {
                  text: mCard.label
                  color: "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 11
                }

                Item { Layout.fillWidth: true }

                Text {
                  text: mCard.valueText
                  color: mCard.barColor
                  font.bold: true
                  font.pixelSize: 11
                }

                Text {
                  visible: mCard.extra !== ""
                  text: mCard.extra
                  color: "#88758F"
                  font.pixelSize: 10
                }
              }

              // Mini Bar
              Rectangle {
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: "#14111A"
                border.color: "#443043"
                border.width: 1

                Rectangle {
                  height: parent.height
                  width: parent.width * Math.min(1.0, Math.max(0.0, mCard.fraction))
                  radius: 3
                  color: mCard.barColor
                }
              }
            }
          }

          MetricCard {
            icon: "󰍛"
            label: "CPU Utilization"
            valueText: root.sysDetails.cpuPct + "%"
            extra: root.sysDetails.cpuTemp > 0 ? ("(" + root.sysDetails.cpuTemp + "°C)") : ""
            fraction: root.sysDetails.cpuPct / 100.0
            barColor: "#A87692"
          }

          MetricCard {
            icon: "󰘚"
            label: "RAM Memory"
            valueText: root.sysDetails.ramUsed + " / " + root.sysDetails.ramTotal + " GB"
            extra: "(" + root.sysDetails.ramPct + "%)"
            fraction: root.sysDetails.ramPct / 100.0
            barColor: "#D9A6C4"
          }

          MetricCard {
            icon: "󰓡"
            label: "Swap Memory"
            valueText: root.sysDetails.swapUsed + " / " + root.sysDetails.swapTotal + " GB"
            extra: "(" + root.sysDetails.swapPct + "%)"
            fraction: root.sysDetails.swapPct / 100.0
            barColor: "#C2AEDF"
          }

          MetricCard {
            icon: "󰋊"
            label: "Disk Storage (Root /)"
            valueText: root.sysDetails.diskUsed + " / " + root.sysDetails.diskTotal + " GB"
            extra: "(" + root.sysDetails.diskPct + "%)"
            fraction: root.sysDetails.diskPct / 100.0
            barColor: "#B8A3BB"
          }
        }
      }
    }
  }

  // -------------------------------------------------------------
  // Centered Floating Power & Session Modal (Sakurazuki)
  // -------------------------------------------------------------
  PanelWindow {
    id: powerCenterPanel
    visible: root.powerMenuOpen
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-power-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    onVisibleChanged: {
      if (visible) {
        root.selectedPowerIndex = 0
        Qt.callLater(function() { powerKeyCatcher.forceActiveFocus() })
      }
    }

    // Fullscreen Scrim
    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.70)
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.closePowerMenu()
    }

    // Centered Card
    Rectangle {
      id: powerCard
      width: Style.space(380)
      height: Style.space(360)
      radius: 14
      anchors.centerIn: parent
      color: "#14111A"
      border.color: "#443043"
      border.width: 1

      MouseArea {
        anchors.fill: parent
        onClicked: {}
      }

      Item {
        id: powerKeyCatcher
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: function(event) { root.closePowerMenu(); event.accepted = true }
        Keys.onUpPressed: function(event) { root.navigatePower(-1); event.accepted = true }
        Keys.onDownPressed: function(event) { root.navigatePower(1); event.accepted = true }
        Keys.onReturnPressed: function(event) { root.executePowerIndex(root.selectedPowerIndex); event.accepted = true }
        Keys.onEnterPressed: function(event) { root.executePowerIndex(root.selectedPowerIndex); event.accepted = true }
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_1) { root.executePowerIndex(0); event.accepted = true }
          else if (event.key === Qt.Key_2) { root.executePowerIndex(1); event.accepted = true }
          else if (event.key === Qt.Key_3) { root.executePowerIndex(2); event.accepted = true }
          else if (event.key === Qt.Key_4) { root.executePowerIndex(3); event.accepted = true }
        }

        Column {
          anchors.fill: parent
          anchors.margins: 18
          spacing: 12

          // Header
          Item {
            width: parent.width
            height: 38

            Row {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              spacing: 10

              Rectangle {
                width: 32
                height: 32
                radius: 16
                color: "#211925"
                border.color: "#A87692"
                border.width: 1.2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  anchors.centerIn: parent
                  text: "🌸"
                  font.pixelSize: 15
                }
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                  text: "Power & Session"
                  color: "#F0DCEB"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 15
                  font.bold: true
                }

                Text {
                  text: "Michal · Sakurazuki"
                  color: "#88758F"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 11
                }
              }
            }

            // Close Button
            Rectangle {
              width: 26
              height: 26
              radius: 13
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              color: closePowerMouse.containsMouse ? "#2A1B2A" : "transparent"
              border.color: closePowerMouse.containsMouse ? "#A87692" : "transparent"
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: "󰅖"
                color: closePowerMouse.containsMouse ? "#F0DCEB" : "#B8A3BB"
                font.family: root.bar ? root.bar.fontFamily : Style.font.family
                font.pixelSize: 13
              }

              MouseArea {
                id: closePowerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closePowerMenu()
              }
            }
          }

          // Separator
          Rectangle {
            width: parent.width
            height: 1
            color: "#443043"
          }

          // Action Cards List
          Column {
            width: parent.width
            spacing: 8

            // 1. Lock
            Rectangle {
              id: lockCard
              width: parent.width
              height: 48
              radius: 8
              readonly property bool isSelected: root.selectedPowerIndex === 0
              readonly property bool isHovered: lockMouse.containsMouse
              color: (isSelected || isHovered) ? "#2A1B2A" : "#211925"
              border.color: (isSelected || isHovered) ? "#A87692" : "#443043"
              border.width: 1

              Rectangle {
                visible: lockCard.isSelected || lockCard.isHovered
                width: 3
                height: parent.height - 14
                radius: 1.5
                color: "#D9A6C4"
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
              }

              Row {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: lockBadge.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                  text: ""
                  color: "#C2AEDF"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 18
                  width: 22
                  horizontalAlignment: Text.AlignHCenter
                  anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 2

                  Text {
                    text: "Lock"
                    color: "#F0DCEB"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: 13
                    font.bold: true
                  }

                  Text {
                    text: "Lock screen and protect session"
                    color: "#88758F"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: 10
                  }
                }
              }

              Rectangle {
                id: lockBadge
                width: 22
                height: 20
                radius: 4
                color: "#14111A"
                border.color: "#443043"
                border.width: 1
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  anchors.centerIn: parent
                  text: "1"
                  color: "#B8A3BB"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 10
                  font.bold: true
                }
              }

              MouseArea {
                id: lockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selectedPowerIndex = 0
                onClicked: root.executePowerIndex(0)
              }
            }

            // 2. Screen saver
            Rectangle {
              id: ssCard
              width: parent.width
              height: 48
              radius: 8
              readonly property bool isSelected: root.selectedPowerIndex === 1
              readonly property bool isHovered: ssMouse.containsMouse
              color: (isSelected || isHovered) ? "#2A1B2A" : "#211925"
              border.color: (isSelected || isHovered) ? "#A87692" : "#443043"
              border.width: 1

              Rectangle {
                visible: ssCard.isSelected || ssCard.isHovered
                width: 3
                height: parent.height - 14
                radius: 1.5
                color: "#D9A6C4"
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
              }

              Row {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: ssBadge.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                  text: "󱄄"
                  color: "#D9A6C4"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 18
                  width: 22
                  horizontalAlignment: Text.AlignHCenter
                  anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 2

                  Text {
                    text: "Screen saver"
                    color: "#F0DCEB"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: 13
                    font.bold: true
                  }

                  Text {
                    text: "Start ambient screensaver"
                    color: "#88758F"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: 10
                  }
                }
              }

              Rectangle {
                id: ssBadge
                width: 22
                height: 20
                radius: 4
                color: "#14111A"
                border.color: "#443043"
                border.width: 1
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  anchors.centerIn: parent
                  text: "2"
                  color: "#B8A3BB"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 10
                  font.bold: true
                }
              }

              MouseArea {
                id: ssMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selectedPowerIndex = 1
                onClicked: root.executePowerIndex(1)
              }
            }

            // 3. Restart
            Rectangle {
              id: rebootCard
              width: parent.width
              height: 48
              radius: 8
              readonly property bool isSelected: root.selectedPowerIndex === 2
              readonly property bool isHovered: rebootMouse.containsMouse
              color: (isSelected || isHovered) ? "#2A1B2A" : "#211925"
              border.color: (isSelected || isHovered) ? "#A87692" : "#443043"
              border.width: 1

              Rectangle {
                visible: rebootCard.isSelected || rebootCard.isHovered
                width: 3
                height: parent.height - 14
                radius: 1.5
                color: "#E5C38B"
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
              }

              Row {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: rebootBadge.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                  text: "󰜉"
                  color: "#E5C38B"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 18
                  width: 22
                  horizontalAlignment: Text.AlignHCenter
                  anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 2

                  Text {
                    text: "Restart"
                    color: "#F0DCEB"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: 13
                    font.bold: true
                  }

                  Text {
                    text: "Reboot and restart system"
                    color: "#88758F"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: 10
                  }
                }
              }

              Rectangle {
                id: rebootBadge
                width: 22
                height: 20
                radius: 4
                color: "#14111A"
                border.color: "#443043"
                border.width: 1
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  anchors.centerIn: parent
                  text: "3"
                  color: "#B8A3BB"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 10
                  font.bold: true
                }
              }

              MouseArea {
                id: rebootMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selectedPowerIndex = 2
                onClicked: root.executePowerIndex(2)
              }
            }

            // 4. Shutdown
            Rectangle {
              id: shutCard
              width: parent.width
              height: 48
              radius: 8
              readonly property bool isSelected: root.selectedPowerIndex === 3
              readonly property bool isHovered: shutMouse.containsMouse
              color: (isSelected || isHovered) ? "#2A1B2A" : "#211925"
              border.color: (isSelected || isHovered) ? "#A87692" : "#443043"
              border.width: 1

              Rectangle {
                visible: shutCard.isSelected || shutCard.isHovered
                width: 3
                height: parent.height - 14
                radius: 1.5
                color: "#E58B9A"
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
              }

              Row {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: shutBadge.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                  text: "󰐥"
                  color: "#E58B9A"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 18
                  width: 22
                  horizontalAlignment: Text.AlignHCenter
                  anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 2

                  Text {
                    text: "Shutdown"
                    color: "#F0DCEB"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: 13
                    font.bold: true
                  }

                  Text {
                    text: "Power off computer"
                    color: "#88758F"
                    font.family: root.bar ? root.bar.fontFamily : Style.font.family
                    font.pixelSize: 10
                  }
                }
              }

              Rectangle {
                id: shutBadge
                width: 22
                height: 20
                radius: 4
                color: "#14111A"
                border.color: "#443043"
                border.width: 1
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  anchors.centerIn: parent
                  text: "4"
                  color: "#B8A3BB"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 10
                  font.bold: true
                }
              }

              MouseArea {
                id: shutMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selectedPowerIndex = 3
                onClicked: root.executePowerIndex(3)
              }
            }
          }

          // Footer Hint
          Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Text {
              text: "↑↓ Navigate"
              color: "#88758F"
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: 10
            }

            Text { text: "•"; color: "#443043"; font.pixelSize: 10 }

            Text {
              text: "↵ / 1-4 Select"
              color: "#88758F"
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: 10
            }

            Text { text: "•"; color: "#443043"; font.pixelSize: 10 }

            Text {
              text: "Esc Cancel"
              color: "#88758F"
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: 10
            }
          }
        }
      }
    }
  }
}
