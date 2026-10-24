import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5, 6]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property var kanjiNumbers: ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: pillContainer.implicitWidth + trailingGap
  implicitHeight: root.barSize

  Rectangle {
    id: pillContainer
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    height: Math.min(26, root.barSize - 2)
    implicitWidth: buttonRow.implicitWidth + 8
    radius: height / 2
    color: "#E614111A"
    border.color: Qt.rgba(216 / 255, 208 / 255, 220 / 255, 0.16)
    border.width: 1

    Row {
      id: buttonRow
      anchors.centerIn: parent
      spacing: 2

      Rectangle {
        id: menuBtn
        width: 24
        height: pillContainer.height - 4
        radius: height / 2
        color: mouseAreaMenu.containsMouse ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.32) : "transparent"

        Behavior on color {
          ColorAnimation { duration: 120 }
        }

        Text {
          anchors.centerIn: parent
          text: "🌸"
          font.pixelSize: Style.font.body
        }

        MouseArea {
          id: mouseAreaMenu
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton | Qt.RightButton

          onEntered: if (root.bar) root.bar.showTooltip(menuBtn, "Menu")
          onExited: if (root.bar) root.bar.hideTooltip(menuBtn)
          onClicked: function(mouse) {
            if (!root.bar) return
            root.bar.hideTooltip(menuBtn)
            if (mouse.button === Qt.RightButton) {
              root.bar.run("xdg-terminal-exec")
            } else {
              root.bar.run("omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
            }
          }
        }
      }

      Rectangle {
        width: 1
        height: 12
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(216 / 255, 208 / 255, 220 / 255, 0.2)
      }

      Repeater {
        model: root.workspaceIds()

        Rectangle {
          id: wsBtn
          required property int modelData

          readonly property var workspace: root.workspaceById(modelData)
          readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
          readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
          readonly property bool hovered: mouseArea.containsMouse

          width: 24
          height: pillContainer.height - 4
          radius: height / 2

          color: focused ? "#A87692" : (hovered ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.32) : (occupied ? Qt.rgba(168 / 255, 118 / 255, 146 / 255, 0.20) : "transparent"))

          Behavior on color {
            ColorAnimation { duration: 120 }
          }

          Text {
            anchors.centerIn: parent
            textFormat: Text.PlainText
            text: root.kanjiNumbers[modelData] || String(modelData)
            color: focused ? "#14111A" : (occupied ? "#E7DFE9" : (hovered ? "#D8D0DC" : "#7D7185"))
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            font.bold: focused
            renderType: Text.NativeRendering
          }

          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton

            onEntered: {
              if (root.bar) root.bar.showTooltip(wsBtn, "Workspace " + wsBtn.modelData)
            }
            onExited: {
              if (root.bar) root.bar.hideTooltip(wsBtn)
            }
            onClicked: {
              if (root.bar) root.bar.hideTooltip(wsBtn)
              root.focusWorkspace(wsBtn.modelData)
            }
            onWheel: function(wheel) {
              if (!root.bar) return
              var target = wheel.angleDelta.y > 0 ? "e-1" : "e+1"
              root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + target + "\" })"))
            }
          }
        }
      }
    }
  }
}
