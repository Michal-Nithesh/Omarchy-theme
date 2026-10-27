import QtQuick
import QtQuick.Effects
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Item {
  id: root

  readonly property string home: Quickshell.env("HOME") || "/home/michal"
  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  readonly property string placeholderText: "パスワードを入力…"
  readonly property int fieldWidth: 280
  readonly property int fieldHeight: 44
  readonly property int fieldFontSize: 14
  readonly property int passwordDotFontSize: 18
  readonly property int passwordDotLetterSpacing: 3

  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 10) : 0
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 8) / dotMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property bool errorState: failureMessage.length > 0

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  onFailedAttemptsChanged: {
    if (failedAttempts > 0) {
      shakeAnim.start()
    }
  }

  TextMetrics {
    id: dotMetrics
    font.family: Style.font.family
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "●".repeat(passwordInput.text.length)
  }

  Rectangle {
    anchors.fill: parent
    color: "#14111A"

    // Crisp Sakurazuki Wallpaper Background (No heavy blur)
    Image {
      id: wallpaper
      anchors.fill: parent
      source: root.loadBackground ? (root.backgroundPath ? root.fileUrl(root.backgroundPath) : "file://" + root.home + "/.config/omarchy/themes/sakurazuki/backgrounds/Sakurazuki Moonlit Valley Retreat.png") : ""
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
    }

    // Gentle contrast wash for maximum text & element legibility
    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0, 0, 0, 0.20)
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    // Top-Center Minimal Clock & Date (Preserved format per user instruction)
    Column {
      id: topClockArea
      anchors.horizontalCenter: parent.horizontalCenter
      y: Math.max(36, Math.round(parent.height * 0.12))
      spacing: 6

      Text {
        id: timeDisplay
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(new Date(), "HH:mm")
        color: "#F0DCEB"
        font.family: Style.font.family
        font.pixelSize: 84
        font.weight: Font.Bold
        style: Text.Raised
        styleColor: Qt.rgba(0.08, 0.07, 0.10, 0.6)
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        Text {
          text: "🌸"
          font.pixelSize: 14
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          id: dateDisplay
          text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
          color: "#D9A6C4"
          font.family: Style.font.family
          font.pixelSize: 17
          font.weight: Font.DemiBold
          style: Text.Raised
          styleColor: Qt.rgba(0.08, 0.07, 0.10, 0.5)
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
          timeDisplay.text = Qt.formatDateTime(new Date(), "HH:mm")
          dateDisplay.text = Qt.formatDateTime(new Date(), "dddd, MMMM d")
        }
      }
    }

    // Center Floating Sakurazuki Island
    Item {
      id: centerArea
      width: 340
      height: 310
      anchors.horizontalCenter: parent.horizontalCenter
      y: Math.round(parent.height * 0.42)

      SequentialAnimation {
        id: shakeAnim
        running: false
        NumberAnimation { target: centerArea; property: "anchors.horizontalCenterOffset"; to: -14; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerArea; property: "anchors.horizontalCenterOffset"; to: 14; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerArea; property: "anchors.horizontalCenterOffset"; to: -10; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerArea; property: "anchors.horizontalCenterOffset"; to: 10; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerArea; property: "anchors.horizontalCenterOffset"; to: 0; duration: 40; easing.type: Easing.InOutQuad }
      }

      Rectangle {
        id: floatingCard
        anchors.fill: parent
        radius: 22
        color: Qt.rgba(0.13, 0.10, 0.15, 0.88) // #211925 surface
        border.color: "#443043"
        border.width: 1.5

        // Subtle glow outline
        Rectangle {
          anchors.fill: parent
          anchors.margins: -1
          radius: parent.radius + 1
          color: "transparent"
          border.color: Qt.rgba(0.85, 0.65, 0.77, 0.15)
          border.width: 1
          z: -1
        }
      }

      Column {
        anchors.centerIn: parent
        spacing: 12
        width: parent.width - 40

        // Circular Luffy Profile Picture (pre-cropped circular 8-bit PNG)
        Item {
          id: avatarContainer
          width: 96
          height: 96
          anchors.horizontalCenter: parent.horizontalCenter

          Rectangle {
            id: avatarBorder
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: "#D9A6C4"
            border.width: 2.5
            z: 2
          }

          Image {
            id: avatarImg
            anchors.fill: parent
            anchors.margins: 2
            source: "file://" + root.home + "/.config/omarchy/assets/avatar_sakurazuki.png"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: false
            cache: true
            onStatusChanged: {
              if (status === Image.Error) {
                console.warn("[LockView] Failed to load avatar:", source)
              }
            }
          }
        }

        // Username in Theme Language (Japanese: ミハル)
        Column {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 2

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "ミハル"
            color: "#F0DCEB"
            font.family: Style.font.family
            font.pixelSize: 18
            font.weight: Font.DemiBold
            style: Text.Raised
            styleColor: Qt.rgba(0.08, 0.07, 0.10, 0.4)
          }

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "桜月 · ロック中"
            color: "#D9A6C4"
            font.family: Style.font.family
            font.pixelSize: 12
            opacity: 0.85
          }
        }

        // Password Input Field (Pill Shape)
        Rectangle {
          id: inputField
          width: root.fieldWidth
          height: root.fieldHeight
          anchors.horizontalCenter: parent.horizontalCenter
          color: Qt.rgba(0.16, 0.11, 0.16, 0.90) // #2A1B2A elevated
          radius: height / 2
          border.color: root.errorState ? "#E58B9A" : (passwordInput.activeFocus ? "#A87692" : "#443043")
          border.width: passwordInput.activeFocus || root.errorState ? 2 : 1
          clip: true

          TextInput {
            id: passwordInput
            anchors.fill: parent
            anchors.leftMargin: 18 + root.fingerprintReserve
            anchors.rightMargin: 18 + root.fingerprintReserve
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            activeFocusOnPress: true
            clip: true
            enabled: root.inputEnabled && !root.authenticatingPassword
            readOnly: root.authenticatingPassword
            echoMode: TextInput.Password
            passwordCharacter: "\u25CF"
            passwordMaskDelay: 0
            color: "#F0DCEB"
            selectionColor: "#A87692"
            selectedTextColor: "#14111A"
            font.family: Style.font.family
            font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)) : root.fieldFontSize
            font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
            cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
            cursorDelegate: Rectangle {
              width: 2
              color: "#F0DCEB"
              visible: passwordInput.cursorVisible
            }

            onTextChanged: {
              if (!root.syncingPasswordText) root.passwordTextEdited(text)
              if (text.length > 0) {
                root.wakeRequested()
              }
              if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
            }

            onAccepted: {
              var submitted = root.passwordText
              root.passwordTextEdited("")
              if (submitted.length > 0) root.submitPassword(submitted)
            }

            Keys.onPressed: function(event) {
              root.wakeRequested()
              if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
                root.passwordTextEdited("")
                event.accepted = true
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            anchors.fill: passwordInput
            text: root.authenticatingPassword ? "確認中…" : (root.failureMessage.length > 0 ? "パスワードが違います" : "パスワードを入力…")
            visible: passwordInput.text.length === 0
            color: root.authenticatingPassword ? "#F0DCEB" : (root.failureMessage.length > 0 ? "#E58B9A" : "#88758F")
            font.family: Style.font.family
            font.pixelSize: root.fieldFontSize
            font.italic: !root.authenticatingPassword && root.failureMessage.length > 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
          }

          Text {
            id: fingerprintIcon
            objectName: "fingerprintIndicator"
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            visible: root.fingerprintConfigured
            text: "󰈷"
            color: "#88758F"
            font.family: Style.font.family
            font.pixelSize: Math.round(root.fieldFontSize * 1.1)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }
        }

        // Japanese Navigation Shortcuts Hint
        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 12

          Row {
            spacing: 4
            Text { text: "↵"; color: "#D9A6C4"; font.family: Style.font.family; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { text: "解除"; color: "#88758F"; font.family: Style.font.family; font.pixelSize: 11 }
          }

          Row {
            spacing: 4
            Text { text: "Esc"; color: "#D9A6C4"; font.family: Style.font.family; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { text: "取消"; color: "#88758F"; font.family: Style.font.family; font.pixelSize: 11 }
          }
        }
      }
    }
  }
}
