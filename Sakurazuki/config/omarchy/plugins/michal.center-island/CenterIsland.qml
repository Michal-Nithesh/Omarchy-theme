import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "CalendarModel.js" as CalendarModel

BarWidget {
  id: root
  moduleName: "michal.center-island"

  readonly property string pluginDir: Quickshell.env("HOME") + "/.config/omarchy/plugins/michal.center-island"

  // Date and Time
  property date currentDate: new Date()
  readonly property string timeString: Qt.formatTime(currentDate, "HH:mm")
  readonly property string dateString: Qt.formatDate(currentDate, "dddd · d MMMM")

  SystemClock {
    id: clockTimer
    precision: SystemClock.Minutes
    onDateChanged: root.currentDate = date
  }

  // Weather State
  property string weatherTemp: "--°"
  property string weatherIcon: "⛅"
  property bool weatherLoading: false
  property bool weatherAvailable: false
  property string weatherTooltip: "Loading weather..."

  function fetchWeather() {
    if (weatherProc.running) return
    weatherLoading = true
    weatherProc.running = true
  }

  Process {
    id: weatherProc
    command: ["bash", "-c",
      "temp=$(curl -fsS --max-time 4 'https://wttr.in/?format=%t' 2>/dev/null | tr -d '+\\n'); " +
      "icon=$(omarchy-weather-icon 2>/dev/null); " +
      "loc=$(omarchy-weather-location 2>/dev/null); " +
      "if [ -n \"$temp\" ]; then " +
      "  echo \"{\\\"temp\\\":\\\"$temp\\\",\\\"icon\\\":\\\"$icon\\\",\\\"loc\\\":\\\"$loc\\\",\\\"ok\\\":true}\"; " +
      "else " +
      "  echo \"{\\\"ok\\\":false}\"; " +
      "fi"
    ]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.weatherLoading = false
        try {
          var res = JSON.parse(text.trim())
          if (res && res.ok) {
            root.weatherTemp = res.temp || "--°"
            root.weatherIcon = res.icon || "⛅"
            root.weatherAvailable = true
            root.weatherTooltip = (res.loc ? res.loc + " · " : "") + root.weatherTemp
            return
          }
        } catch (e) {}
        root.weatherAvailable = false
        root.weatherTooltip = "Weather unavailable (configure via omarchy-weather-location)"
      }
    }
  }

  Timer {
    interval: 900000 // Refresh weather every 15 minutes
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.fetchWeather()
  }

  // Utility Status
  property bool hasVoxtype: false
  property string voxtypeState: "idle"
  property bool isRecording: false
  property int reminderCount: 0
  property string reminderNext: ""
  property bool nightLightActive: false
  property int nightLightTemp: 6500
  property bool dndActive: false
  property bool stayAwakeActive: false

  function refreshStatus() {
    if (statusProc.running) return
    statusProc.running = true
  }

  Process {
    id: statusProc
    command: [root.pluginDir + "/status.sh"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var d = JSON.parse(text.trim())
          if (d) {
            root.hasVoxtype = d.hasVoxtype === true
            root.voxtypeState = String(d.voxtypeState || "idle")
            root.isRecording = d.recording === true
            root.reminderCount = Number(d.reminderCount || 0)
            root.reminderNext = String(d.reminderNext || "")
            root.nightLightActive = d.nightLight === true
            root.nightLightTemp = Number(d.nightLightTemp || 6500)
            root.dndActive = d.dnd === true
            root.stayAwakeActive = d.stayAwake === true
          }
        } catch (e) {}
      }
    }
  }

  Timer {
    id: livePollTimer
    interval: 2000
    repeat: true
    running: popupCard.open
    onTriggered: root.refreshStatus()
  }

  // Active popover tab: "controls" or "calendar"
  property string activeTab: "controls"

  // Calendar browsing state
  property int calYear: root.currentDate.getFullYear()
  property int calMonth: root.currentDate.getMonth()
  property var calDays: CalendarModel.generateMonthDays(calYear, calMonth)

  function updateCalendar() {
    calDays = CalendarModel.generateMonthDays(calYear, calMonth)
  }

  function stepMonth(delta) {
    var nextM = calMonth + delta
    if (nextM < 0) {
      calMonth = 11
      calYear -= 1
    } else if (nextM > 11) {
      calMonth = 0
      calYear += 1
    } else {
      calMonth = nextM
    }
    updateCalendar()
  }

  function resetToToday() {
    calYear = root.currentDate.getFullYear()
    calMonth = root.currentDate.getMonth()
    updateCalendar()
  }

  property bool popoverOpen: false

  function close() {
    root.popoverOpen = false
  }

  function openControls() {
    root.activeTab = "controls"
    root.refreshStatus()
    root.popoverOpen = true
  }

  function openCalendar() {
    root.activeTab = "calendar"
    root.resetToToday()
    root.popoverOpen = true
  }

  function toggleControls() {
    if (root.popoverOpen && root.activeTab === "controls") {
      root.close()
    } else {
      root.openControls()
    }
  }

  function toggleCalendar() {
    if (root.popoverOpen && root.activeTab === "calendar") {
      root.close()
    } else {
      root.openCalendar()
    }
  }

  IpcHandler {
    target: "michal.center-island"

    function toggleControls() { root.broadcast("toggleControls") }
    function toggleCalendar() { root.broadcast("toggleCalendar") }
    function openControls() { root.broadcast("openControls") }
    function openCalendar() { root.broadcast("openCalendar") }
    function close() { root.broadcast("close") }
    function refresh() { root.fetchWeather(); root.refreshStatus() }
  }

  function executeUtility(action) {
    if (!root.bar) return
    switch (action) {
      case "dictation":
        if (root.hasVoxtype) {
          root.bar.run("omarchy-voxtype-config")
        } else {
          root.bar.run("omarchy-launch-floating-terminal-with-presentation 'omarchy-voxtype-install'")
        }
        break
      case "screenrecord":
        if (root.isRecording) {
          root.bar.run("omarchy-capture-screenrecording --stop-recording")
        } else {
          root.bar.run("omarchy-capture-screenrecording --fullscreen")
        }
        break
      case "reminder":
        root.bar.run("omarchy-reminder -i")
        break
      case "nightlight":
        root.bar.run("omarchy-toggle-nightlight")
        break
      case "dnd":
        root.bar.run("omarchy-shell notifications toggleDnd")
        break
      case "stayawake":
        root.bar.run("omarchy-toggle-idle toggle")
        break
    }
    statusTimer.restart()
  }

  Timer {
    id: statusTimer
    interval: 400
    onTriggered: root.refreshStatus()
  }

  implicitWidth: island.implicitWidth
  implicitHeight: root.barSize

  // -------------------------------------------------------------
  // Center Island Bar Widget
  // -------------------------------------------------------------
  Rectangle {
    id: island
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
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

      // Clock & Date Button
      Rectangle {
        id: clockBtn
        height: island.height - 4
        implicitWidth: clockRow.implicitWidth + 8
        radius: height / 2
        color: clockArea.containsMouse ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.22) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Row {
          id: clockRow
          anchors.centerIn: parent
          spacing: 6

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.timeString
            color: "#F0DCEB"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            font.bold: true
            renderType: Text.NativeRendering
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "·"
            color: "#443043"
            font.pixelSize: Style.font.body
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.dateString
            color: "#B8A3BB"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body - 1
            renderType: Text.NativeRendering
          }
        }

        MouseArea {
          id: clockArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton

          onEntered: if (root.bar) root.bar.showTooltip(clockBtn, "Toggle Calendar")
          onExited: if (root.bar) root.bar.hideTooltip(clockBtn)
          onClicked: {
            if (root.bar) root.bar.hideTooltip(clockBtn)
            root.toggleCalendar()
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

      // Weather Button
      Rectangle {
        id: weatherBtn
        height: island.height - 4
        implicitWidth: weatherRow.implicitWidth + 8
        radius: height / 2
        color: weatherArea.containsMouse ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.22) : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Row {
          id: weatherRow
          anchors.centerIn: parent
          spacing: 4

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.weatherLoading ? "󰔟" : root.weatherIcon
            color: "#C2AEDF"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            renderType: Text.NativeRendering
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.weatherAvailable ? root.weatherTemp : "--"
            color: "#D9A6C4"
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body - 1
            renderType: Text.NativeRendering
          }
        }

        MouseArea {
          id: weatherArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton

          onEntered: if (root.bar) root.bar.showTooltip(weatherBtn, root.weatherTooltip + " (Click to refresh)")
          onExited: if (root.bar) root.bar.hideTooltip(weatherBtn)
          onClicked: {
            if (root.bar) root.bar.hideTooltip(weatherBtn)
            root.fetchWeather()
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

      // Launcher Button
      Rectangle {
        id: launcherBtn
        width: 24
        height: island.height - 4
        radius: height / 2
        color: (launcherArea.containsMouse || (root.popoverOpen && root.activeTab === "controls"))
          ? "#A87692" : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
          anchors.centerIn: parent
          text: "󰣇"
          color: (launcherArea.containsMouse || (root.popoverOpen && root.activeTab === "controls"))
            ? "#14111A" : "#D9A6C4"
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body + 1
          renderType: Text.NativeRendering
        }

        MouseArea {
          id: launcherArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton

          onEntered: if (root.bar) root.bar.showTooltip(launcherBtn, "Omarchy Control")
          onExited: if (root.bar) root.bar.hideTooltip(launcherBtn)
          onClicked: {
            if (root.bar) root.bar.hideTooltip(launcherBtn)
            root.toggleControls()
          }
        }
      }
    }
  }

  // -------------------------------------------------------------
  // Floating Popover Card
  // -------------------------------------------------------------
  KeyboardPanel {
    id: popupCard
    anchorItem: root
    owner: root
    bar: root.bar
    open: root.popoverOpen
    centerOnBar: true
    focusTarget: popoverFocusScope
    padding: 14
    contentWidth: 380
    contentHeight: root.activeTab === "controls" ? 250 : 330

    onOpenChanged: {
      if (open) {
        root.refreshStatus()
        root.currentDate = new Date()
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

        // Header with Tabs and Close
        RowLayout {
          Layout.fillWidth: true

          Row {
            spacing: 6

            // Controls Tab Button
            Rectangle {
              height: 26
              implicitWidth: tab1Row.implicitWidth + 14
              radius: 6
              color: root.activeTab === "controls" ? "#A87692" : (tab1Area.containsMouse ? "#211925" : "transparent")
              border.color: root.activeTab === "controls" ? "#D9A6C4" : "#443043"
              border.width: 1

              Row {
                id: tab1Row
                anchors.centerIn: parent
                spacing: 5
                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: "󰣇"
                  color: root.activeTab === "controls" ? "#14111A" : "#D9A6C4"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 12
                  renderType: Text.NativeRendering
                }
                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: "Controls"
                  color: root.activeTab === "controls" ? "#14111A" : "#F0DCEB"
                  font.bold: root.activeTab === "controls"
                  font.pixelSize: 11
                }
              }

              MouseArea {
                id: tab1Area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.activeTab = "controls"
                  root.refreshStatus()
                }
              }
            }

            // Calendar Tab Button
            Rectangle {
              height: 26
              implicitWidth: tab2Row.implicitWidth + 14
              radius: 6
              color: root.activeTab === "calendar" ? "#A87692" : (tab2Area.containsMouse ? "#211925" : "transparent")
              border.color: root.activeTab === "calendar" ? "#D9A6C4" : "#443043"
              border.width: 1

              Row {
                id: tab2Row
                anchors.centerIn: parent
                spacing: 5
                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: "󰸗"
                  color: root.activeTab === "calendar" ? "#14111A" : "#C2AEDF"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 12
                }
                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: "Calendar"
                  color: root.activeTab === "calendar" ? "#14111A" : "#F0DCEB"
                  font.bold: root.activeTab === "calendar"
                  font.pixelSize: 11
                }
              }

              MouseArea {
                id: tab2Area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.activeTab = "calendar"
                  root.resetToToday()
                }
              }
            }
          }

          Item { Layout.fillWidth: true }

          // Close Button
          Rectangle {
            width: 24
            height: 24
            radius: 12
            color: closeArea.containsMouse ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.3) : "transparent"

            Text {
              anchors.centerIn: parent
              text: "✕"
              color: "#B8A3BB"
              font.pixelSize: 11
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

        // =========================================================
        // VIEW 1: Sakura Control Utilities (2x3 Grid)
        // =========================================================
        GridLayout {
          visible: root.activeTab === "controls"
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 2
          columnSpacing: 8
          rowSpacing: 8

          // 1. Dictation
          Rectangle {
            Layout.fillWidth: true
            height: 54
            radius: 8
            color: root.voxtypeState === "recording" ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.25) : "#211925"
            border.color: root.voxtypeState === "recording" ? "#A87692" : (dictArea.containsMouse ? "#D9A6C4" : "#443043")
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.margins: 8
              spacing: 8

              Rectangle {
                width: 32
                height: 32
                radius: 6
                color: root.voxtypeState === "recording" ? "#A87692" : "#2E2434"
                Text {
                  anchors.centerIn: parent
                  text: "󰍬"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 15
                  color: root.voxtypeState === "recording" ? "#14111A" : (root.hasVoxtype ? "#C2AEDF" : "#7D7185")
                }
              }

              Column {
                Layout.fillWidth: true
                Text {
                  text: "Dictation"
                  color: "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 11
                }
                Text {
                  text: !root.hasVoxtype ? "Install Voxtype" : (root.voxtypeState === "recording" ? "Recording" : "Idle")
                  color: root.voxtypeState === "recording" ? "#D9A6C4" : "#B8A3BB"
                  font.pixelSize: 10
                }
              }
            }

            MouseArea {
              id: dictArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.executeUtility("dictation")
            }
          }

          // 2. Screen Recording
          Rectangle {
            Layout.fillWidth: true
            height: 54
            radius: 8
            color: root.isRecording ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.25) : "#211925"
            border.color: root.isRecording ? "#A87692" : (recArea.containsMouse ? "#D9A6C4" : "#443043")
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.margins: 8
              spacing: 8

              Rectangle {
                width: 32
                height: 32
                radius: 6
                color: root.isRecording ? "#A87692" : "#2E2434"
                Text {
                  anchors.centerIn: parent
                  text: "󰻂"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 15
                  color: root.isRecording ? "#14111A" : "#C2AEDF"
                }
              }

              Column {
                Layout.fillWidth: true
                Text {
                  text: "Screen Record"
                  color: "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 11
                }
                Text {
                  text: root.isRecording ? "Recording (Stop)" : "Idle (Start)"
                  color: root.isRecording ? "#D9A6C4" : "#B8A3BB"
                  font.pixelSize: 10
                }
              }
            }

            MouseArea {
              id: recArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.executeUtility("screenrecord")
            }
          }

          // 3. Set Reminder
          Rectangle {
            Layout.fillWidth: true
            height: 54
            radius: 8
            color: root.reminderCount > 0 ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.25) : "#211925"
            border.color: root.reminderCount > 0 ? "#A87692" : (remArea.containsMouse ? "#D9A6C4" : "#443043")
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.margins: 8
              spacing: 8

              Rectangle {
                width: 32
                height: 32
                radius: 6
                color: root.reminderCount > 0 ? "#A87692" : "#2E2434"
                Text {
                  anchors.centerIn: parent
                  text: "󰢌"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 15
                  color: root.reminderCount > 0 ? "#14111A" : "#C2AEDF"
                }
              }

              Column {
                Layout.fillWidth: true
                Text {
                  text: "Set Reminder"
                  color: "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 11
                }
                Text {
                  text: root.reminderCount > 0 ? (root.reminderCount + " Active") : "New Timer"
                  color: root.reminderCount > 0 ? "#D9A6C4" : "#B8A3BB"
                  font.pixelSize: 10
                  elide: Text.ElideRight
                }
              }
            }

            MouseArea {
              id: remArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.executeUtility("reminder")
            }
          }

          // 4. Night Light
          Rectangle {
            Layout.fillWidth: true
            height: 54
            radius: 8
            color: root.nightLightActive ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.25) : "#211925"
            border.color: root.nightLightActive ? "#A87692" : (nlArea.containsMouse ? "#D9A6C4" : "#443043")
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.margins: 8
              spacing: 8

              Rectangle {
                width: 32
                height: 32
                radius: 6
                color: root.nightLightActive ? "#A87692" : "#2E2434"
                Text {
                  anchors.centerIn: parent
                  text: "󰔎"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 15
                  color: root.nightLightActive ? "#14111A" : "#C2AEDF"
                }
              }

              Column {
                Layout.fillWidth: true
                Text {
                  text: "Night Light"
                  color: "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 11
                }
                Text {
                  text: root.nightLightActive ? "Warm (4000K)" : "Day (6500K)"
                  color: root.nightLightActive ? "#D9A6C4" : "#B8A3BB"
                  font.pixelSize: 10
                }
              }
            }

            MouseArea {
              id: nlArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.executeUtility("nightlight")
            }
          }

          // 5. Silent Notifications (DND)
          Rectangle {
            Layout.fillWidth: true
            height: 54
            radius: 8
            color: root.dndActive ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.25) : "#211925"
            border.color: root.dndActive ? "#A87692" : (dndArea.containsMouse ? "#D9A6C4" : "#443043")
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.margins: 8
              spacing: 8

              Rectangle {
                width: 32
                height: 32
                radius: 6
                color: root.dndActive ? "#A87692" : "#2E2434"
                Text {
                  anchors.centerIn: parent
                  text: "󰂛"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 15
                  color: root.dndActive ? "#14111A" : "#C2AEDF"
                }
              }

              Column {
                Layout.fillWidth: true
                Text {
                  text: "Silent Mode"
                  color: "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 11
                }
                Text {
                  text: root.dndActive ? "DND Active" : "Alerts On"
                  color: root.dndActive ? "#D9A6C4" : "#B8A3BB"
                  font.pixelSize: 10
                }
              }
            }

            MouseArea {
              id: dndArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.executeUtility("dnd")
            }
          }

          // 6. Stay Awake
          Rectangle {
            Layout.fillWidth: true
            height: 54
            radius: 8
            color: root.stayAwakeActive ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.25) : "#211925"
            border.color: root.stayAwakeActive ? "#A87692" : (idleArea.containsMouse ? "#D9A6C4" : "#443043")
            border.width: 1

            RowLayout {
              anchors.fill: parent
              anchors.margins: 8
              spacing: 8

              Rectangle {
                width: 32
                height: 32
                radius: 6
                color: root.stayAwakeActive ? "#A87692" : "#2E2434"
                Text {
                  anchors.centerIn: parent
                  text: "󰅶"
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: 15
                  color: root.stayAwakeActive ? "#14111A" : "#C2AEDF"
                }
              }

              Column {
                Layout.fillWidth: true
                Text {
                  text: "Stay Awake"
                  color: "#F0DCEB"
                  font.bold: true
                  font.pixelSize: 11
                }
                Text {
                  text: root.stayAwakeActive ? "Sleep Inhibited" : "Auto Sleep"
                  color: root.stayAwakeActive ? "#D9A6C4" : "#B8A3BB"
                  font.pixelSize: 10
                }
              }
            }

            MouseArea {
              id: idleArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.executeUtility("stayawake")
            }
          }
        }

        // =========================================================
        // VIEW 2: Calendar
        // =========================================================
        ColumnLayout {
          visible: root.activeTab === "calendar"
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 8

          // Month Navigation Bar
          RowLayout {
            Layout.fillWidth: true

            Rectangle {
              width: 24
              height: 24
              radius: 4
              color: prevArea.containsMouse ? "#211925" : "transparent"
              border.color: "#443043"
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: "‹"
                color: "#F0DCEB"
                font.bold: true
                font.pixelSize: 14
              }

              MouseArea {
                id: prevArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.stepMonth(-1)
              }
            }

            Item { Layout.fillWidth: true }

            Text {
              text: CalendarModel.monthName(root.calMonth).toUpperCase() + " " + root.calYear
              color: "#F0DCEB"
              font.bold: true
              font.pixelSize: 12
              font.capitalization: Font.SmallCaps
            }

            Item { Layout.fillWidth: true }

            Rectangle {
              width: 24
              height: 24
              radius: 4
              color: nextArea.containsMouse ? "#211925" : "transparent"
              border.color: "#443043"
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: "›"
                color: "#F0DCEB"
                font.bold: true
                font.pixelSize: 14
              }

              MouseArea {
                id: nextArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.stepMonth(1)
              }
            }
          }

          // Weekday header row (Mo Tu We Th Fr Sa Su)
          Row {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
              model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
              Item {
                width: 332 / 7
                height: 20
                Text {
                  anchors.centerIn: parent
                  text: modelData
                  color: "#B8A3BB"
                  font.pixelSize: 10
                  font.bold: true
                }
              }
            }
          }

          // Days Grid (7 columns x 5-6 rows)
          Flow {
            Layout.fillWidth: true
            width: 332
            spacing: 0

            Repeater {
              model: root.calDays

              Rectangle {
                width: 332 / 7
                height: 26
                radius: 13
                color: modelData.isToday ? "#A87692" : (dayArea.containsMouse ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.2) : "transparent")

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                  anchors.centerIn: parent
                  text: String(modelData.day)
                  color: modelData.isToday ? "#14111A" : (modelData.currentMonth ? "#F0DCEB" : "#554256")
                  font.bold: modelData.isToday
                  font.pixelSize: 11
                }

                MouseArea {
                  id: dayArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                }
              }
            }
          }

          // Footer
          Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#443043"
          }

          RowLayout {
            Layout.fillWidth: true
            Text {
              text: "Today: " + Qt.formatDate(root.currentDate, "dddd, d MMMM yyyy")
              color: "#B8A3BB"
              font.pixelSize: 10
            }
            Item { Layout.fillWidth: true }
            Text {
              text: "Day " + CalendarModel.dayOfYear(root.currentDate) + " (" + CalendarModel.yearPercent(root.currentDate) + "%)"
              color: "#A87692"
              font.bold: true
              font.pixelSize: 10
            }
          }
        }
      }
    }
  }
}
