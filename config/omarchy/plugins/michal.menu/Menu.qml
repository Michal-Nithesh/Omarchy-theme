import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "MenuModel.js" as MenuModel

Item {
  id: root

  // Injected by omarchy-shell when this plugin is summoned.
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  // Plugin lifecycle hooks
  property string pendingInitialMenu: "root"

  function open(payloadJson) {
    console.log("[Menu] open called: payloadJson=" + payloadJson)
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }

    if (payload.fontFamily) root.fontFamily = payload.fontFamily

    if (payload.mode === "select" || payload.mode === "input") {
      root.openDmenu(payload)
    } else {
      root.openRoute(payload.initialMenu || payload.menu || "root")
    }
  }

  function close() {
    root.cancel()
  }

  function refresh() {
    defaultMenuFile.reload()
    userMenuFile.reload()
    return "ok"
  }

  function ping() { return "ok" }

  function debugState() {
    return JSON.stringify({
      opened: root.opened,
      activeMenu: root.activeMenu,
      filterText: root.filterText,
      rowsLoaded: root.rowsLoaded,
      itemCount: Object.keys(root.items).length,
      itemOrderCount: root.itemOrder.length,
      displayModelCount: displayModel.count,
      sysKernel: root.sysKernel,
      sysHyprland: root.sysHyprland,
      sysCpu: root.sysCpu,
      sysMem: root.sysMem
    })
  }

  property string fontFamily: Style.font.menuFamily
  property string defaultMenuPath: omarchyPath + "/default/omarchy/omarchy-menu.jsonc"
  property string userMenuPath: Quickshell.env("HOME") + "/.config/omarchy/extensions/omarchy-menu.jsonc"
  property var defaultMenuItems: []
  property var userMenuItems: []
  property bool opened: false
  property string mode: "menu"
  readonly property bool dmenuActive: mode === "select" || mode === "input"
  property string dmenuPrompt: ""
  property var dmenuOptions: []
  property string selectionFile: ""
  property string doneFile: ""
  property int dmenuWidth: 320
  property int dmenuMaxHeight: 0
  property bool requestActive: false
  property bool rowsLoaded: false
  property string activeMenu: "apps"
  property string filterText: ""
  property int selectedIndex: 0
  property bool cursorActive: false
  property int requestSerial: 0
  property int applySerial: 0
  property var items: ({})
  property var itemOrder: []
  property var navStack: []
  property var providersLoaded: ({})
  property var providerQueue: []
  property int providerRevision: 0

  // Shared application engine
  readonly property var appLibrary: root.shell ? root.shell.appLibrary : null
  property bool deleteConfirmOpen: false
  property var deleteTarget: null
  onOpenedChanged: if (!opened) { deleteConfirmOpen = false; deleteTarget = null }

  property bool cursorBlink: true
  Timer {
    id: cursorTimer
    interval: 530
    running: root.opened
    repeat: true
    onTriggered: root.cursorBlink = !root.cursorBlink
  }

  // Sakurazuki Color Palette
  readonly property color background: "#14111A"
  readonly property color secondaryBg: "#211925"
  readonly property color elevatedSurface: "#2A1B2A"
  readonly property color sakuraRose: "#A87692"
  readonly property color blossomPink: "#D9A6C4"
  readonly property color moonlightLavender: "#C2AEDF"
  readonly property color primaryText: "#F0DCEB"
  readonly property color secondaryText: "#B8A3BB"
  readonly property color mutedText: "#88758F"
  readonly property color borderCol: "#443043"
  readonly property color successCol: "#A8C5A0"
  readonly property color warningCol: "#E5C38B"
  readonly property color errorCol: "#E58B9A"
  readonly property color infoCol: "#A9B8E8"

  property var borderSpec: Border.surfaceSpec("menu", "border", borderCol, 1)
  property color scrim: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.70)
  property color selectedBackground: elevatedSurface
  property color selectedText: primaryText
  property color selectedBorder: sakuraRose
  property var selectedBorderSpec: Border.surfaceSpec("menu", "selected-border", selectedBorder, 1)
  readonly property real rowReservedBorderLeft: Border.left(selectedBorderSpec)
  readonly property real rowReservedBorderRight: Border.right(selectedBorderSpec)
  readonly property int cornerRadius: 14

  // Top-Level Main Categories
  readonly property var mainCategories: [
    { id: "apps", icon: "󰣇", label: "Apps", desc: "Installed Applications" },
    { id: "learn", icon: "󰧑", label: "Learn", desc: "Guides & Documentation" },
    { id: "style", icon: "", label: "Appearance", desc: "Theme, Wallpaper & Bar" },
    { id: "trigger", icon: "󱓞", label: "Trigger", desc: "Toggles, Capture & Tools" },
    { id: "setup", icon: "", label: "Setup", desc: "Preferences & Defaults" },
    { id: "install", icon: "󰉉", label: "Install", desc: "Software & Packages" },
    { id: "remove", icon: "󰭌", label: "Remove", desc: "Uninstall Software" },
    { id: "update", icon: "", label: "Update", desc: "System & Maintenance" },
    { id: "system", icon: "", label: "System", desc: "Power & Session" },
    { id: "about", icon: "󰋽", label: "About", desc: "Michal · Sakurazuki" }
  ]

  function currentCategoryId() {
    if (!root.activeMenu || root.activeMenu === "root") return "apps"
    return root.activeMenu.split(".")[0]
  }

  function categoryForMenu(menuId) {
    if (!menuId || menuId === "root") return "Apps"
    var cat = menuId.split(".")[0]
    for (var i = 0; i < root.mainCategories.length; i++) {
      if (root.mainCategories[i].id === cat) return root.mainCategories[i].label
    }
    return cat
  }

  function setActiveCategory(catId) {
    root.filterText = ""
    root.navStack = []
    root.activeMenu = catId
    root.selectedIndex = 0
    root.cursorActive = true
    if (catId === "apps") {
      root.loadProviderForMenu("apps")
    }
    root.rebuildDisplay()
  }

  function cycleCategory(delta) {
    var cur = root.currentCategoryId()
    var idx = 0
    for (var i = 0; i < root.mainCategories.length; i++) {
      if (root.mainCategories[i].id === cur) { idx = i; break }
    }
    var nextIdx = (idx + delta + root.mainCategories.length) % root.mainCategories.length
    root.setActiveCategory(root.mainCategories[nextIdx].id)
  }

  // Dimensions
  property int cardWidth: root.dmenuActive ? Math.min(Math.max(500, Style.space(root.dmenuWidth)), panel.width - Style.gapsOut * 2) : Math.min(Style.space(840), panel.width - Style.gapsOut * 2)
  property int cardHeight: root.dmenuActive
    ? Math.min(130 + visibleRowsHeight, panel.height - Style.gapsOut * 2)
    : Math.min(Style.space(560), panel.height - Style.gapsOut * 2)
  property int layoutSerial: 0
  property int visibleRowsHeight: root.dmenuActive ? dmenuRowListHeight(layoutSerial, displayModel.count, filterText) : rowListHeight(layoutSerial, displayModel.count, filterText, false)

  function evaluateMath(expr) {
    var raw = String(expr || "").trim()
    if (!raw) return null
    if (!/[0-9]/.test(raw) && !/(pi|e)/i.test(raw)) return null
    if (!/[+\-*/%^]/.test(raw) && !/(sqrt|sin|cos|tan|log|ln|abs)/i.test(raw)) return null
    if (/[^0-9+\-*/%^().,\s\w]/.test(raw)) return null

    try {
      var sanitized = raw
        .replace(/\^/g, "**")
        .replace(/\bsqrt\s*\(/gi, "Math.sqrt(")
        .replace(/\bsin\s*\(/gi, "Math.sin(")
        .replace(/\bcos\s*\(/gi, "Math.cos(")
        .replace(/\btan\s*\(/gi, "Math.tan(")
        .replace(/\blog\s*\(/gi, "Math.log10(")
        .replace(/\bln\s*\(/gi, "Math.log(")
        .replace(/\babs\s*\(/gi, "Math.abs(")
        .replace(/\bpi\b/gi, "Math.PI")
        .replace(/\be\b/gi, "Math.E")

      if (/[^0-9+\-*/%().,\sMath.sqrtincoaglbePIE]/.test(sanitized)) return null

      var fn = new Function('"use strict"; return (' + sanitized + ')')
      var val = fn()
      if (typeof val === "number" && !isNaN(val) && isFinite(val)) {
        if (Math.floor(val) === val) return String(val)
        return String(Number(val.toFixed(6)))
      }
    } catch (e) { }
    return null
  }

  function finishRequest(selection) {
    if (!root.requestActive || !root.doneFile) {
      root.opened = false
      return
    }

    var activeSelectionFile = root.selectionFile
    var activeDoneFile = root.doneFile
    root.requestActive = false
    root.selectionFile = ""
    root.doneFile = ""

    if (selection === null || selection === undefined) {
      resultProc.command = ["bash", "-c", ": > " + Util.shellQuote(activeDoneFile)]
    } else {
      resultProc.command = ["bash", "-c", "printf '%s\\n' " + Util.shellQuote(selection) + " > " + Util.shellQuote(activeSelectionFile) + "; : > " + Util.shellQuote(activeDoneFile)]
    }
    resultProc.running = true
  }

  function runAction(action) {
    var command = String(action || "")
    if (!command) return
    Util.execDetached(command)
  }

  function rowHeightForDetail(detail) {
    return detail ? 52 : 46
  }

  function rowListHeight(_serial, _count, _filter, _divider) {
    return root.cardHeight - 64 - 36 - 40
  }

  function dmenuRowListHeight(_serial, _count, _filter) {
    if (root.mode === "input") return 0
    var count = displayModel.count
    if (count === 0) return 60
    var rowsH = Math.min(count * 52, Style.space(380))
    return Math.max(52, rowsH)
  }

  function item(id) {
    return root.items[id] || null
  }

  function stripJsonc(raw) { return MenuModel.stripJsonc(raw) }
  function normalizeAliases(value) { return MenuModel.normalizeAliases(value) }
  function normalizeItem(id, raw) { return MenuModel.normalizeItem(id, raw) }
  function parseMenuJsonc(raw) { return MenuModel.parseMenuJsonc(raw) }

  // Dynamic system specs
  property string sysKernel: "7.2.8-9-omarchy"
  property string sysHyprland: "0.56.2"
  property string sysQuickshell: "0.3.2"
  property string sysCpu: "AMD Ryzen 3 7320U"
  property string sysMem: "8 GB RAM"
  property string sysUptime: ""

  readonly property var providers: ({
    "fonts": {
      script: "current=$(omarchy-font-current 2>/dev/null); omarchy-font-list 2>/dev/null | while read -r f; do [[ -z $f ]] && continue; printf '%s\\t%s\\t%s\\n' \"$f\" \"$f\" \"$current\"; done",
      icon: "",
      volatile: true,
      actionFor: function(value) { return "omarchy-font-set " + Util.shellQuote(value) }
    },
    "power-profiles": {
      script: "current=$(powerprofilesctl get 2>/dev/null); omarchy-powerprofiles-list 2>/dev/null | while read -r p; do [[ -z $p ]] && continue; printf '%s\\t%s\\t%s\\n' \"$p\" \"$p\" \"$current\"; done",
      icon: "\udb81\udc0b",
      actionFor: function(value) { return "omarchy-powerprofiles-set autodetect " + Util.shellQuote(value) }
    }
  })

  function rebuildItemsFromSources() {
    var mergedMenu = MenuModel.mergeMenuSources(root.defaultMenuItems, root.userMenuItems)
    root.providerRevision += 1
    root.providersLoaded = ({})
    root.providerQueue = []
    root.items = mergedMenu.items
    root.itemOrder = mergedMenu.itemOrder
    root.rowsLoaded = true
    console.log("omarchy-menu: loaded sources -> items=" + Object.keys(root.items).length + " ordered=" + root.itemOrder.length)
    root.mergeAppRows()
    root.evaluateGuards()
    if (root.opened) {
      root.rebuildDisplay()
      if (!root.dmenuActive) {
        if (root.filterText.trim()) root.loadProvidersForSearch()
        else root.loadProviderForMenu(root.activeMenu)
      }
    }
  }

  function slugify(value) { return MenuModel.slugify(value) }

  function resolveAppIcon(icon) {
    var value = String(icon || "")
    if (value.length === 0) return Quickshell.iconPath("application-x-executable", true)
    if (value.indexOf("file://") === 0 || value.indexOf("image://") === 0) return value
    if (value.charAt(0) === "/") return Util.fileUrl(value)
    var themed = Quickshell.iconPath(value, true)
    if (themed.length > 0) return themed
    return Quickshell.iconPath("application-x-executable", true)
  }

  function launchApp(desktopId, name) {
    var id = String(desktopId || "")
    if (!id) return
    Util.execDetached("uwsm-app -- gtk-launch " + Util.shellQuote(id + ".desktop"))
  }

  function mergeAppRows() {
    var appRows = []
    if (root.appLibrary) {
      try {
        var rows = root.appLibrary.sortedEntries("")
        for (var j = 0; j < rows.length; j++) {
          var entry = rows[j].entry
          var appId = String(entry.id || "")
          if (!appId) continue
          var subtext = root.appLibrary.entrySubtext(entry)
          var aliases = subtext ? [subtext] : []
          try {
            if (entry.keywords && typeof entry.keywords.join === "function") aliases = aliases.concat(entry.keywords)
          } catch (e) { }
          appRows.push({
            id: "apps." + appId,
            parent: "apps",
            kind: "app",
            icon: "",
            iconFont: "",
            appIcon: String(entry.icon || ""),
            appId: appId,
            label: root.appLibrary.entryName(entry),
            title: "",
            target: "",
            description: subtext || "Application",
            action: "",
            provider: "",
            aliases: aliases,
            when: "",
            checked: "",
            order: 0
          })
        }
      } catch (e) {
        console.warn("omarchy-menu: appLibrary.sortedEntries failed: " + e)
      }
    }

    if (appRows.length === 0 && typeof DesktopEntries !== "undefined" && DesktopEntries.applications) {
      var deList = DesktopEntries.applications.values || []
      for (var k = 0; k < deList.length; k++) {
        var de = deList[k]
        if (!de || !de.id) continue
        var deId = String(de.id)
        if (deId.slice(-8) === ".desktop") deId = deId.slice(0, -8)
        var deName = String(de.name || deId)
        var deGeneric = String(de.genericName || de.comment || "")
        var deAliases = deGeneric ? [deGeneric] : []
        try {
          if (de.keywords && typeof de.keywords.join === "function") deAliases = deAliases.concat(de.keywords)
        } catch (e) { }
        appRows.push({
          id: "apps." + deId,
          parent: "apps",
          kind: "app",
          icon: "",
          iconFont: "",
          appIcon: String(de.icon || ""),
          appId: deId,
          label: deName,
          title: "",
          target: "",
          description: deGeneric || "Application",
          action: "",
          provider: "",
          aliases: deAliases,
          when: "",
          checked: "",
          order: 0
        })
      }
    }

    console.log("omarchy-menu: merged apps count=" + appRows.length)
    var merged = MenuModel.mergeAppRows(root.items, root.itemOrder, appRows)
    root.items = merged.items
    root.itemOrder = merged.itemOrder
    if (root.opened) root.rebuildDisplay()
  }

  function startProviderForMenu(id) {
    var entry = root.item(id)
    if (!entry || !entry.provider || root.providersLoaded[id]) return
    if (entry.provider === "apps") {
      root.providersLoaded[id] = true
      root.mergeAppRows()
      return
    }
    var spec = root.providers[entry.provider]
    if (!spec) return

    root.providersLoaded[id] = true
    providerProc.menuId = id
    providerProc.providerKey = entry.provider
    providerProc.revision = root.providerRevision
    providerProc.collected = ""
    providerProc.command = ["bash", "-lc", spec.script]
    providerProc.running = true
  }

  function mergeProviderRows(rows, menuId, providerKey) {
    var spec = root.providers[providerKey]
    if (!spec) return
    var lines = String(rows || "").split("\n")
    var providerRows = []
    var takenIds = ({})
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (!line) continue
      var parts = line.split("\t")
      var label = parts[0] || ""
      var value = parts[1] || parts[0] || ""
      var current = parts[2] || ""
      if (!label) continue
      var rowId = menuId + "." + root.slugify(value)
      while (takenIds[rowId]) rowId += "-"
      takenIds[rowId] = true

      providerRows.push({
        id: rowId,
        parent: menuId,
        kind: "action",
        icon: (value === current) ? "✓" : (spec.icon || ""),
        iconFont: root.fontFamily,
        appIcon: "",
        appId: "",
        label: label,
        title: "",
        target: "",
        description: "",
        action: spec.actionFor(value),
        provider: "",
        aliases: [],
        when: "",
        checked: "",
        order: 0
      })
    }
    var merged = MenuModel.swapProviderRows(root.items, root.itemOrder, menuId, providerRows)
    root.items = merged.items
    root.itemOrder = merged.itemOrder
    if (root.opened) root.rebuildDisplay()
  }

  function startNextProvider() {
    if (providerProc.running) return
    while (root.providerQueue.length > 0) {
      var id = root.providerQueue.shift()
      var entry = root.item(id)
      if (!entry || !entry.provider || root.providersLoaded[id]) continue
      root.startProviderForMenu(id)
      return
    }
  }

  function loadProviderForMenu(id) {
    if (id === "apps") {
      root.mergeAppRows()
      return
    }
    var entry = root.item(id)
    if (!entry || !entry.provider) return
    if (root.providersLoaded[id]) return
    root.startProviderForMenu(id)
  }

  function loadProvidersForSearch() {
    root.mergeAppRows()
    for (var i = 0; i < root.itemOrder.length; i++) {
      var entry = root.item(root.itemOrder[i])
      if (entry && entry.provider) root.loadProviderForMenu(entry.id)
    }
  }

  function depthFor(id) { return MenuModel.depthFor(root.items, id) }
  function pathFor(id) { return MenuModel.pathFor(root.items, id) }
  function parentPathFor(id) { return MenuModel.parentPathFor(root.items, id) }
  function isDescendantOf(id, ancestorId) { return MenuModel.isDescendantOf(root.items, id, ancestorId) }
  function childCount(id) { return MenuModel.childCount(root.items, root.itemOrder, id) }
  function isVisible(entry) { return MenuModel.isVisible(root.items, root.itemOrder, root.whenResults, entry) }
  function labelFor(entry) { return MenuModel.labelFor(entry, root.checkedResults) }
  function searchableToken(value) { return MenuModel.searchableToken(value) }
  function leafIdFor(id) { return MenuModel.leafIdFor(id) }
  function nameSearchText(entry) { return MenuModel.nameSearchText(entry) }
  function termInSearchWords(term, text) { return MenuModel.termInSearchWords(term, text) }
  function descriptionTextMatches(query, text) { return MenuModel.descriptionTextMatches(query, text) }
  function matchesQuery(entry, query) { return MenuModel.matchesQuery(entry, query, root.isVisible(entry)) }
  function searchScore(entry, query) { return MenuModel.searchScore(root.items, entry, query) }

  function displayRow(entry, detail, score, section) {
    return {
      itemId: entry.id,
      kind: entry.kind,
      icon: entry.icon || "",
      iconFont: entry.iconFont || "",
      appIcon: entry.appIcon || "",
      appId: entry.appId || "",
      label: root.labelFor(entry),
      title: entry.title || entry.label,
      target: entry.target || "",
      detail: detail || "",
      path: root.pathFor(entry.id),
      action: entry.action || "",
      childCount: root.childCount(entry.id),
      score: score || 0,
      section: section || ""
    }
  }

  function rebuildDmenuDisplay() {
    displayModel.clear()
    var query = root.filterText.trim().toLowerCase()
    for (var i = 0; i < root.dmenuOptions.length; i++) {
      var parts = String(root.dmenuOptions[i] || "").split("\t")
      var icon = parts.length > 1 ? parts.shift() : "󰐱"
      var label = parts.shift() || ""
      var detail = parts.join("\t")
      if (query && label.toLowerCase().indexOf(query) < 0 && detail.toLowerCase().indexOf(query) < 0) continue
      displayModel.append({
        itemId: "dmenu." + i,
        kind: "dmenu",
        icon: icon || "󰐱",
        iconFont: root.fontFamily,
        appIcon: "",
        appId: "",
        label: label,
        title: label,
        target: "",
        detail: detail,
        path: "",
        action: "",
        childCount: 0,
        score: i,
        section: ""
      })
    }
    if (selectedIndex >= displayModel.count) selectedIndex = Math.max(0, displayModel.count - 1)
  }

  function rebuildDisplay() {
    if (root.dmenuActive) {
      root.rebuildDmenuDisplay()
      return
    }

    displayModel.clear()
    if (!root.rowsLoaded) return

    var query = root.filterText.trim()
    var rows = []

    if (query) {
      // 1. Math calculation
      var mathRes = root.evaluateMath(query)
      if (mathRes !== null) {
        rows.push({
          itemId: "calc.result",
          kind: "calc",
          icon: "󰃬",
          iconFont: root.fontFamily,
          appIcon: "",
          appId: "",
          label: "= " + mathRes,
          title: "= " + mathRes,
          target: "",
          detail: "計算結果 (Press Enter to copy to clipboard)",
          action: "printf '%s' " + Util.shellQuote(String(mathRes)) + " | wl-copy && omarchy-notification-send -g 󰃬 'Copied' " + Util.shellQuote(String(mathRes)),
          childCount: 0,
          score: -9999,
          section: "Calculator"
        })
      }

      // 2. Command execution
      if (query.charAt(0) === ">" || query.charAt(0) === ":") {
        var cmdStr = query.substring(1).trim()
        if (cmdStr.length > 0) {
          rows.push({
            itemId: "cmd.terminal",
            kind: "cmd",
            icon: "󰒋",
            iconFont: root.fontFamily,
            appIcon: "",
            appId: "",
            label: "Terminal: " + cmdStr,
            title: "Run in Terminal",
            target: "",
            detail: "Execute in terminal window with bash",
            action: "uwsm-app -- xdg-terminal-exec --dir=\"$(omarchy-cmd-terminal-cwd)\" bash -ic " + Util.shellQuote(cmdStr + "; echo; read -p 'Press Enter to exit...'"),
            childCount: 0,
            score: -9998,
            section: "Commands"
          })
          rows.push({
            itemId: "cmd.bg",
            kind: "cmd",
            icon: "󱓞",
            iconFont: root.fontFamily,
            appIcon: "",
            appId: "",
            label: "Background: " + cmdStr,
            title: "Run in Background",
            target: "",
            detail: "Execute detached via uwsm-app",
            action: "uwsm-app -- " + cmdStr,
            childCount: 0,
            score: -9997,
            section: "Commands"
          })
        }
      }

      // 3. Search apps and menu items
      var scored = []
      var queryLower = query.toLowerCase()

      for (var i = 0; i < root.itemOrder.length; i++) {
        var entry = root.item(root.itemOrder[i])
        if (!entry || entry.id === "root") continue
        if (!root.matchesQuery(entry, query)) continue

        var score = root.searchScore(entry, query)
        var catName = root.categoryForMenu(entry.id)
        var detail = entry.kind === "app" ? (entry.description || "Application") : root.parentPathFor(entry.id)

        scored.push({
          row: root.displayRow(entry, detail, score, catName),
          score: score,
          name: (entry.label || "").toLowerCase()
        })
      }

      scored.sort(function(a, b) {
        if (a.score !== b.score) return a.score - b.score
        return a.name.localeCompare(b.name)
      })

      for (var s = 0; s < scored.length; s++) {
        rows.push(scored[s].row)
      }
    } else {
      // Empty query: display items for activeMenu
      if (root.activeMenu === "apps") {
        var allApps = []
        for (var a = 0; a < root.itemOrder.length; a++) {
          var appEntry = root.item(root.itemOrder[a])
          if (!appEntry || appEntry.kind !== "app") continue
          allApps.push(root.displayRow(appEntry, appEntry.description || "Application", appEntry.order, "Apps"))
        }

        allApps.sort(function(x, y) {
          var xl = String(x.label || "").toLowerCase()
          var yl = String(y.label || "").toLowerCase()
          return xl.localeCompare(yl)
        })

        for (var ap = 0; ap < allApps.length; ap++) {
          rows.push(allApps[ap])
        }
      } else if (root.activeMenu === "about") {
        // Rendered via AboutView in content area
      } else {
        // Submenu or specific category
        for (var j = 0; j < root.itemOrder.length; j++) {
          var child = root.item(root.itemOrder[j])
          if (!child || child.parent !== root.activeMenu) continue
          if (!root.isVisible(child)) continue
          rows.push(root.displayRow(child, child.description, child.order, root.categoryForMenu(child.id)))
        }
      }
    }

    for (var k = 0; k < rows.length; k++) {
      displayModel.append(rows[k])
    }
    console.log("[Menu] rebuildDisplay: activeMenu=" + root.activeMenu + " filter=" + query + " count=" + displayModel.count)

    layoutSerial += 1
    if (displayModel.count === 0) selectedIndex = 0
    else if (selectedIndex >= displayModel.count) selectedIndex = displayModel.count - 1
    else if (selectedIndex < 0) selectedIndex = 0

    Qt.callLater(function() {
      if (displayModel.count > 0) root.revealCursor()
    })
  }

  function revealCursor() {
    if (displayModel.count === 0) return
    if (root.dmenuActive) {
      if (typeof dmenuList !== "undefined" && dmenuList) dmenuList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    } else {
      if (typeof resultList !== "undefined" && resultList) resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    }
  }

  function select(delta) {
    if (displayModel.count === 0) return
    root.cursorActive = true
    var next = root.selectedIndex + delta
    if (next < 0) next = 0
    if (next >= displayModel.count) next = displayModel.count - 1
    root.selectedIndex = next
    root.revealCursor()
  }

  function setFilter(nextFilter) {
    if (root.filterText === nextFilter) return
    root.filterText = nextFilter
    root.selectedIndex = 0
    root.cursorActive = root.dmenuActive ? true : false
    if (nextFilter && !root.dmenuActive) root.loadProvidersForSearch()
    root.rebuildDisplay()
  }

  function setActiveMenu(id, pushHistory) {
    if (pushHistory) root.navStack.push(root.activeMenu)
    root.activeMenu = id
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = false
    root.loadProviderForMenu(id)
    root.rebuildDisplay()
  }

  function goBack() {
    if (root.navStack.length > 0) {
      var prev = root.navStack.pop()
      root.activeMenu = prev
      root.filterText = ""
      root.selectedIndex = 0
      root.cursorActive = false
      root.rebuildDisplay()
      return true
    }
    return false
  }

  function activateIndex(index) {
    if (root.dmenuActive) {
      if (root.mode === "input") {
        root.applyDmenuSelection(root.filterText)
        return
      }
      if (displayModel.count > index && index >= 0) {
        var picked = displayModel.get(index)
        root.applyDmenuSelection(picked.detail ? picked.label + "\t" + picked.detail : picked.label)
      }
      return
    }

    var entry = displayModel.get(index)
    if (!entry) return

    if (entry.kind === "calc" || entry.kind === "cmd") {
      if (entry.action) root.runAction(entry.action)
      if (entry.kind === "cmd") root.close()
      return
    }

    if (entry.kind === "app") {
      if (root.appLibrary) root.appLibrary.launch(entry.appId || entry.itemId, entry.label)
      else root.launchApp(entry.appId || entry.itemId, entry.label)
      root.close()
      return
    }

    if (entry.kind === "menu" || entry.target || entry.childCount > 0) {
      var nextMenu = entry.target || entry.itemId
      root.setActiveMenu(nextMenu, true)
      return
    }

    if (entry.action) {
      root.runAction(entry.action)
      root.close()
      return
    }
  }

  function requestDeleteSelected() {
    if (root.selectedIndex < 0 || root.selectedIndex >= displayModel.count) return
    var entry = displayModel.get(root.selectedIndex)
    if (!entry || entry.kind !== "app" || !entry.appId) return
    root.deleteTarget = entry
    root.deleteConfirmOpen = true
  }

  function cancelDelete() {
    root.deleteConfirmOpen = false
    root.deleteTarget = null
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function confirmDelete() {
    if (!root.deleteTarget || !root.deleteTarget.appId) return
    var appId = root.deleteTarget.appId
    root.cancelDelete()
    if (root.appLibrary) root.appLibrary.remove(appId)
    else Util.execDetached("omarchy remove " + Util.shellQuote(appId))
  }

  function applyDmenuSelection(value) {
    root.opened = false
    root.filterText = ""
    root.finishRequest(value)
  }

  function cancel() {
    if (root.dmenuActive) root.finishRequest(null)
    root.opened = false
    root.filterText = ""
  }

  function openExistingMenu(initialMenu) {
    if (!root.rowsLoaded && defaultMenuFile.text()) {
      root.defaultMenuItems = root.parseMenuJsonc(defaultMenuFile.text())
      if (userMenuFile.text()) {
        root.userMenuItems = root.parseMenuJsonc(userMenuFile.text())
      }
      root.rebuildItemsFromSources()
      root.rowsLoaded = true
    }
    root.mode = "menu"
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = false
    root.navStack = []
    root.activeMenu = initialMenu || "apps"
    root.opened = true
    root.loadProviderForMenu(root.activeMenu)
    root.rebuildDisplay()
    root.evaluateGuards()
    if (!sysInfoProc.running) {
      sysInfoProc.collected = ""
      sysInfoProc.running = true
    }
    if (root.appLibrary) root.appLibrary.refreshIcons()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function openDmenu(payload) {
    root.mode = payload.mode || "select"
    root.dmenuPrompt = payload.prompt || ""
    root.dmenuOptions = payload.options || []
    root.selectionFile = payload.selectionFile || ""
    root.doneFile = payload.doneFile || ""
    root.dmenuWidth = payload.width || 480
    root.requestActive = true
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = true
    root.opened = true
    root.rebuildDmenuDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function resolveRoute(input) {
    return MenuModel.resolveRoute(root.items, root.itemOrder, input)
  }

  function openRoute(initialMenu) {
    var route = root.resolveRoute(initialMenu)
    if (!route || route === "root") route = "apps"
    root.openExistingMenu(route)
  }

  function selectFromPointer(index) {
    root.cursorActive = true
    root.selectedIndex = index
  }

  function onAppsChanged() {
    root.mergeAppRows()
    if (root.opened && (root.activeMenu === "apps" || root.filterText)) {
      root.rebuildDisplay()
    }
  }

  // Guard Evaluation
  property var whenResults: ({})
  property var checkedResults: ({})
  property bool guardsPending: false

  function evaluateGuards() {
    if (!root.rowsLoaded) return
    if (guardProc.running) {
      root.guardsPending = true
      return
    }
    root.guardsPending = false
    var script = MenuModel.guardScript(root.items)
    if (!script) return
    guardProc.command = ["bash", "-c", script]
    guardProc.collected = ""
    guardProc.running = true
  }

  ListModel { id: displayModel }

  FileView {
    id: defaultMenuFile
    path: root.defaultMenuPath
    watchChanges: true
    printErrors: false
    onLoaded: {
      console.log("[Menu] defaultMenuFile loaded (" + path + ")")
      root.defaultMenuItems = root.parseMenuJsonc(text())
      root.rebuildItemsFromSources()
      root.rowsLoaded = true
    }
    onLoadFailed: {
      console.log("[Menu] defaultMenuFile failed to load: " + path)
    }
    onFileChanged: reload()
  }

  FileView {
    id: userMenuFile
    path: root.userMenuPath
    watchChanges: true
    printErrors: false
    onLoaded: {
      console.log("[Menu] userMenuFile loaded (" + path + ")")
      root.userMenuItems = root.parseMenuJsonc(text())
      root.rebuildItemsFromSources()
      root.rowsLoaded = true
    }
    onLoadFailed: {
      console.log("[Menu] userMenuFile not found or failed to load: " + path)
      root.userMenuItems = []
      root.rebuildItemsFromSources()
      root.rowsLoaded = true
    }
    onFileChanged: reload()
  }

  Process {
    id: providerProc
    property string menuId: ""
    property string providerKey: ""
    property string collected: ""
    property int revision: 0
    stdout: SplitParser {
      onRead: function(data) { providerProc.collected += data + "\n" }
    }
    onExited: {
      if (providerProc.revision === root.providerRevision) {
        root.mergeProviderRows(providerProc.collected, providerProc.menuId, providerProc.providerKey)
        if (root.filterText.trim()) root.loadProvidersForSearch()
      }
      root.startNextProvider()
    }
  }

  Process {
    id: sysInfoProc
    property string collected: ""
    command: ["bash", "-c", "echo \"$(uname -r)|$(hyprctl version 2>/dev/null | head -n1 | awk '{print $1, $2}')|Quickshell 0.1|$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs | sed 's/ with Radeon Graphics//')|$(free -h | awk '/^Mem:/ {print $2}')\""]
    stdout: SplitParser {
      onRead: function(data) { sysInfoProc.collected += data }
    }
    onExited: function(exitCode) {
      if (exitCode === 0 && sysInfoProc.collected) {
        var parts = sysInfoProc.collected.trim().split("|")
        if (parts.length >= 5) {
          root.sysKernel = parts[0]
          root.sysHyprland = parts[1]
          root.sysQuickshell = parts[2]
          root.sysCpu = parts[3]
          root.sysMem = parts[4]
        }
      }
    }
  }

  Process {
    id: guardProc
    property string collected: ""
    stdout: SplitParser {
      onRead: function(data) { guardProc.collected += data + "\n" }
    }
    onExited: function(exitCode, exitStatus) {
      if (exitCode !== 0 || exitStatus !== 0) return
      var nextWhen = ({})
      var nextChecked = ({})
      var lines = guardProc.collected.split("\n")
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trim()
        if (!line) continue
        var colon = line.lastIndexOf(":")
        if (colon < 0) continue
        var val = line.substring(colon + 1) === "1"
        var rest = line.substring(0, colon)
        var tagAt = rest.lastIndexOf(":")
        if (tagAt < 0) continue
        var itemId = rest.substring(0, tagAt)
        var tag = rest.substring(tagAt + 1)
        if (tag === "w") nextWhen[itemId] = val
        else if (tag === "c") nextChecked[itemId] = val
      }
      root.whenResults = nextWhen
      root.checkedResults = nextChecked
      if (root.opened) root.rebuildDisplay()
    }
  }

  Process { id: resultProc }

  Connections {
    target: root.appLibrary
    function onEntriesChanged() { root.onAppsChanged() }
  }

  // Layer-Shell Panel Window
  PanelWindow {
    id: panel
    visible: root.opened && root.rowsLoaded
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.cancel()
    }

    // Main Floating Sakurazuki Card
    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (root.deleteConfirmOpen) {
            if (deleteConfirm.handleKey(event)) event.accepted = true
            return
          }

          if (event.key === Qt.Key_Delete) {
            root.requestDeleteSelected()
            event.accepted = true
          } else if (event.key === Qt.Key_Escape) {
            if (root.filterText) {
              root.setFilter("")
            } else if (root.navStack.length > 0) {
              root.goBack()
            } else {
              root.cancel()
            }
            event.accepted = true
          } else if (event.key === Qt.Key_Tab) {
            if (!root.dmenuActive) {
              root.cycleCategory(1)
              event.accepted = true
            }
          } else if (event.key === Qt.Key_Backtab) {
            if (!root.dmenuActive) {
              root.cycleCategory(-1)
              event.accepted = true
            }
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if ((event.key === Qt.Key_Backspace || event.key === Qt.Key_Left) && !root.filterText) {
            if (root.navStack.length > 0) {
              root.goBack()
              event.accepted = true
            }
          } else if (event.key === Qt.Key_Up) {
            root.select(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            root.select(-6)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            root.select(6)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.dmenuActive) {
              if (root.mode === "input") root.applyDmenuSelection(root.filterText)
              else if (displayModel.count > 0) root.activateIndex(root.cursorActive ? root.selectedIndex : 0)
            } else if (displayModel.count > 0) {
              root.activateIndex(root.cursorActive ? root.selectedIndex : 0)
            }
            event.accepted = true
          } else if (event.key === Qt.Key_Right) {
            if (!root.dmenuActive && displayModel.count > 0) {
              root.activateIndex(root.cursorActive ? root.selectedIndex : 0)
              event.accepted = true
            }
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127 && (event.modifiers === Qt.NoModifier || event.modifiers === Qt.ShiftModifier)) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }

        ConfirmDialog {
          id: deleteConfirm
          anchors.fill: parent
          opened: root.deleteConfirmOpen
          z: 30
          message: "Do you want to uninstall " + ((root.deleteTarget && root.deleteTarget.label) || "") + "?"
          confirmText: "Uninstall"
          background: root.background
          foreground: root.primaryText
          scrim: root.scrim
          selectedBackground: root.elevatedSurface
          selectedText: root.blossomPink
          fontFamily: root.fontFamily
          cornerRadius: root.cornerRadius
          onCanceled: root.cancelDelete()
          onConfirmed: root.confirmDelete()
        }

        // =========================================================
        // 1. Dmenu / Select Dialog View (active when dmenuActive)
        // =========================================================
        Column {
          id: dmenuContainer
          visible: root.dmenuActive
          anchors.fill: parent
          anchors.margins: 14
          spacing: 10

          // Dialog Header Bar
          Item {
            width: parent.width
            height: 40

            // Left: Icon + Prompt Label
            Row {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              spacing: 10

              Rectangle {
                width: 32
                height: 32
                radius: 8
                color: root.secondaryBg
                border.color: root.sakuraRose
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  anchors.centerIn: parent
                  text: root.mode === "input" ? "󰌌" : "󰐱"
                  color: root.blossomPink
                  font.family: root.fontFamily
                  font.pixelSize: 16
                }
              }

              Text {
                text: root.dmenuPrompt ? root.dmenuPrompt : (root.mode === "input" ? "Input" : "Select Option")
                color: root.primaryText
                font.family: root.fontFamily
                font.pixelSize: 15
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            // Right: Integrated Search Filter Field
            Rectangle {
              id: dmenuSearchField
              width: 210
              height: 34
              radius: 8
              color: root.secondaryBg
              border.color: root.filterText ? root.sakuraRose : root.borderCol
              border.width: 1
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                onClicked: keyCatcher.forceActiveFocus()
              }

              Text {
                id: dmenuSearchIcon
                text: "󰍉"
                color: root.filterText ? root.blossomPink : root.mutedText
                font.family: root.fontFamily
                font.pixelSize: 14
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
              }

              Row {
                anchors.left: dmenuSearchIcon.right
                anchors.leftMargin: 8
                anchors.right: dmenuClearBtn.visible ? dmenuClearBtn.left : parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                clip: true

                Text {
                  textFormat: Text.PlainText
                  text: root.filterText ? root.filterText : "Type to filter…"
                  color: root.filterText ? root.primaryText : root.mutedText
                  font.family: root.fontFamily
                  font.pixelSize: 12
                  anchors.verticalCenter: parent.verticalCenter
                  elide: Text.ElideRight
                }

                Text {
                  text: "|"
                  visible: root.cursorBlink
                  color: root.blossomPink
                  font.family: root.fontFamily
                  font.pixelSize: 13
                  anchors.verticalCenter: parent.verticalCenter
                }
              }

              Rectangle {
                id: dmenuClearBtn
                visible: root.filterText.length > 0
                width: 18
                height: 18
                radius: 9
                color: dmenuClearMouse.containsMouse ? root.elevatedSurface : "transparent"
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  anchors.centerIn: parent
                  text: "󰅖"
                  color: dmenuClearMouse.containsMouse ? root.primaryText : root.mutedText
                  font.family: root.fontFamily
                  font.pixelSize: 10
                }

                MouseArea {
                  id: dmenuClearMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.setFilter("")
                }
              }
            }
          }

          // Separator Line
          Rectangle {
            width: parent.width
            height: 1
            color: root.borderCol
          }

          // Main Options List
          Item {
            width: parent.width
            height: root.visibleRowsHeight
            clip: true

            ListView {
              id: dmenuList
              anchors.fill: parent
              model: displayModel
              spacing: 4
              boundsBehavior: Flickable.StopAtBounds
              clip: true

              delegate: Rectangle {
                id: dmenuRow
                required property int index
                required property string icon
                required property string label
                required property string detail

                readonly property bool hasCursor: root.cursorActive && dmenuRow.index === root.selectedIndex

                width: ListView.view.width
                height: dmenuRow.detail.length > 0 ? 50 : 42
                radius: 8
                color: hasCursor ? root.selectedBackground : "transparent"
                border.color: hasCursor ? root.selectedBorder : "transparent"
                border.width: hasCursor ? 1 : 0

                // Blossom Pink Left Accent Bar
                Rectangle {
                  visible: dmenuRow.hasCursor
                  width: 3
                  height: parent.height - 12
                  radius: 1.5
                  color: root.blossomPink
                  anchors.left: parent.left
                  anchors.leftMargin: 4
                  anchors.verticalCenter: parent.verticalCenter
                }

                // Left Icon
                Text {
                  id: dmenuIconText
                  textFormat: Text.PlainText
                  text: dmenuRow.icon || "󰐱"
                  color: dmenuRow.hasCursor ? root.blossomPink : root.primaryText
                  font.family: root.fontFamily
                  font.pixelSize: 18
                  width: 28
                  horizontalAlignment: Text.AlignHCenter
                  verticalAlignment: Text.AlignVCenter
                  anchors.left: parent.left
                  anchors.leftMargin: 12
                  anchors.verticalCenter: parent.verticalCenter
                }

                // Label and Detail
                Column {
                  anchors.left: dmenuIconText.right
                  anchors.leftMargin: 12
                  anchors.right: dmenuSelectBadge.left
                  anchors.rightMargin: 10
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 2

                  Text {
                    textFormat: Text.PlainText
                    width: parent.width
                    text: dmenuRow.label
                    color: dmenuRow.hasCursor ? root.primaryText : root.secondaryText
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.weight: dmenuRow.hasCursor ? Font.DemiBold : Font.Normal
                    elide: Text.ElideRight
                  }

                  Text {
                    textFormat: Text.PlainText
                    width: parent.width
                    text: dmenuRow.detail
                    visible: dmenuRow.detail.length > 0
                    color: dmenuRow.hasCursor ? root.blossomPink : root.mutedText
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                  }
                }

                // Action Badge on Selection
                Rectangle {
                  id: dmenuSelectBadge
                  visible: dmenuRow.hasCursor
                  height: 22
                  width: dmenuBadgeText.implicitWidth + 12
                  radius: 5
                  color: root.secondaryBg
                  border.color: root.sakuraRose
                  border.width: 1
                  anchors.right: parent.right
                  anchors.rightMargin: 12
                  anchors.verticalCenter: parent.verticalCenter

                  Text {
                    id: dmenuBadgeText
                    anchors.centerIn: parent
                    text: "↵ Select"
                    color: root.blossomPink
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onEntered: root.selectFromPointer(dmenuRow.index)
                  onClicked: root.activateIndex(dmenuRow.index)
                }
              }
            }

            // Empty State
            Item {
              anchors.fill: parent
              visible: displayModel.count === 0

              Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: "󰍉"
                  color: root.mutedText
                  font.family: root.fontFamily
                  font.pixelSize: 24
                }

                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: root.filterText ? "No matching options" : "No items available"
                  color: root.mutedText
                  font.family: root.fontFamily
                  font.pixelSize: 12
                }
              }
            }
          }

          // Footer Separator Line
          Rectangle {
            width: parent.width
            height: 1
            color: root.borderCol
          }

          // Footer Hints
          Item {
            width: parent.width
            height: 20

            Row {
              anchors.centerIn: parent
              spacing: 14

              Row {
                spacing: 4
                Text { text: "↑↓"; color: root.sakuraRose; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                Text { text: "Navigate"; color: root.mutedText; font.family: root.fontFamily; font.pixelSize: 11 }
              }

              Text { text: "•"; color: root.borderCol; font.pixelSize: 10 }

              Row {
                spacing: 4
                Text { text: "↵"; color: root.blossomPink; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                Text { text: "Select"; color: root.mutedText; font.family: root.fontFamily; font.pixelSize: 11 }
              }

              Text { text: "•"; color: root.borderCol; font.pixelSize: 10 }

              Row {
                spacing: 4
                Text { text: "Esc"; color: root.sakuraRose; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                Text { text: "Cancel"; color: root.mutedText; font.family: root.fontFamily; font.pixelSize: 11 }
              }
            }
          }
        }

        // =========================================================
        // 2. Hub / Main Menu View (active when !dmenuActive)
        // =========================================================
        Column {
          id: hubContainer
          visible: !root.dmenuActive
          anchors.fill: parent
          spacing: 0

          // Top Header Bar
          Rectangle {
            width: parent.width
            height: 64
            color: "transparent"

            Row {
              anchors.left: parent.left
              anchors.leftMargin: 16
              anchors.verticalCenter: parent.verticalCenter
              spacing: 12

              // Avatar / Brand Icon
              Rectangle {
                width: 38
                height: 38
                radius: 19
                color: root.secondaryBg
                border.color: root.blossomPink
                border.width: 1.5
                anchors.verticalCenter: parent.verticalCenter

                Image {
                  anchors.fill: parent
                  anchors.margins: 2
                  source: "file://" + Quickshell.env("HOME") + "/.config/omarchy/assets/avatar_sakurazuki.png"
                  fillMode: Image.PreserveAspectCrop
                  smooth: true
                }
              }

              // Personalized Branding
              Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Row {
                  spacing: 8
                  Text {
                    text: "Michal"
                    color: root.primaryText
                    font.family: root.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Bold
                  }

                  Rectangle {
                    height: 18
                    width: themePillText.implicitWidth + 10
                    radius: 9
                    color: root.elevatedSurface
                    border.color: root.sakuraRose
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                      id: themePillText
                      anchors.centerIn: parent
                      text: "🌸 Sakurazuki"
                      color: root.blossomPink
                      font.family: root.fontFamily
                      font.pixelSize: 10
                      font.weight: Font.Medium
                    }
                  }
                }

                Text {
                  text: "Omarchy Linux · Hyprland"
                  color: root.mutedText
                  font.family: root.fontFamily
                  font.pixelSize: 11
                }
              }
            }

            // Prominent Search Field
            Rectangle {
              id: searchField
              width: 360
              height: 40
              radius: 10
              color: root.secondaryBg
              border.color: root.filterText ? root.sakuraRose : root.borderCol
              border.width: 1
              anchors.right: parent.right
              anchors.rightMargin: 16
              anchors.verticalCenter: parent.verticalCenter

              MouseArea {
                anchors.fill: parent
                anchors.rightMargin: clearSearchBtn.visible ? 30 : 0
                cursorShape: Qt.IBeamCursor
                onClicked: keyCatcher.forceActiveFocus()
              }

              Text {
                id: searchGlyph
                text: "󰍉"
                color: root.filterText ? root.blossomPink : root.mutedText
                font.family: root.fontFamily
                font.pixelSize: 16
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
              }

              Row {
                anchors.left: searchGlyph.right
                anchors.leftMargin: 10
                anchors.right: clearSearchBtn.visible ? clearSearchBtn.left : parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                clip: true

                Text {
                  textFormat: Text.PlainText
                  text: root.filterText ? root.filterText : "Search applications, settings, or actions…"
                  color: root.filterText ? root.primaryText : root.mutedText
                  font.family: root.fontFamily
                  font.pixelSize: 13
                  anchors.verticalCenter: parent.verticalCenter
                  elide: Text.ElideRight
                }

                Text {
                  text: "|"
                  visible: root.cursorBlink
                  color: root.blossomPink
                  font.family: root.fontFamily
                  font.pixelSize: 14
                  anchors.verticalCenter: parent.verticalCenter
                }
              }

              Rectangle {
                id: clearSearchBtn
                visible: root.filterText.length > 0
                width: 22
                height: 22
                radius: 11
                color: clearMouse.containsMouse ? root.elevatedSurface : "transparent"
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter

                Text {
                  anchors.centerIn: parent
                  text: "󰅖"
                  color: clearMouse.containsMouse ? root.primaryText : root.secondaryText
                  font.family: root.fontFamily
                  font.pixelSize: 12
                }

                MouseArea {
                  id: clearMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.setFilter("")
                }
              }
            }
          }

          // Top Separator Hairline
          Rectangle {
            width: parent.width
            height: 1
            color: root.borderCol
          }

          // Main Center Area (Two Columns: Left Categories Sidebar, Right Content)
          Row {
            width: parent.width
            height: parent.height - 64 - 1 - 38
            spacing: 0

            // Left Category Navigation Sidebar
            Rectangle {
              width: 195
              height: parent.height
              color: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.45)

              Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: root.borderCol
              }

              ListView {
                id: categoryList
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.mainCategories

                delegate: Rectangle {
                  id: catBtn
                  required property var modelData
                  width: ListView.view.width
                  height: 38
                  radius: 8

                  readonly property bool active: root.currentCategoryId() === modelData.id
                  readonly property bool hovered: catMouse.containsMouse

                  color: active ? root.elevatedSurface : (hovered ? root.secondaryBg : "transparent")
                  border.color: active ? root.sakuraRose : "transparent"
                  border.width: active ? 1 : 0

                  // Left edge pink indicator bar
                  Rectangle {
                    visible: catBtn.active
                    width: 3
                    height: parent.height - 12
                    radius: 1.5
                    color: root.blossomPink
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                  }

                  Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: badgePill.left
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                      text: catBtn.modelData.icon
                      color: catBtn.active ? root.blossomPink : (catBtn.hovered ? root.primaryText : root.secondaryText)
                      font.family: root.fontFamily
                      font.pixelSize: 15
                      width: 20
                      horizontalAlignment: Text.AlignHCenter
                      anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                      text: catBtn.modelData.label
                      color: catBtn.active ? root.primaryText : (catBtn.hovered ? root.primaryText : root.secondaryText)
                      font.family: root.fontFamily
                      font.pixelSize: 13
                      font.weight: catBtn.active ? Font.DemiBold : Font.Normal
                      anchors.verticalCenter: parent.verticalCenter
                      elide: Text.ElideRight
                      width: parent.width - 28
                    }
                  }

                  // Category Badge Count Pill
                  Rectangle {
                    id: badgePill
                    visible: badgeText.text.length > 0
                    height: 18
                    width: Math.max(18, badgeText.implicitWidth + 8)
                    radius: 9
                    color: catBtn.active ? root.sakuraRose : (catBtn.hovered ? root.elevatedSurface : Qt.rgba(42 / 255, 27 / 255, 42 / 255, 0.5))
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                      id: badgeText
                      anchors.centerIn: parent
                      text: {
                        if (catBtn.modelData.id === "apps") {
                          var count = 0
                          for (var a = 0; a < root.itemOrder.length; a++) {
                            var itm = root.item(root.itemOrder[a])
                            if (itm && itm.kind === "app") count++
                          }
                          return count > 0 ? String(count) : ((root.appLibrary && root.appLibrary.sortedEntries) ? String(root.appLibrary.sortedEntries("").length) : "")
                        }
                        if (catBtn.modelData.id === "about") {
                          return "󰣇"
                        }
                        var childC = root.childCount(catBtn.modelData.id)
                        return childC > 0 ? String(childC) : ""
                      }
                      color: catBtn.active ? root.primaryText : (catBtn.modelData.id === "about" ? root.blossomPink : root.mutedText)
                      font.family: root.fontFamily
                      font.pixelSize: catBtn.modelData.id === "about" ? 11 : 10
                      font.weight: Font.DemiBold
                    }
                  }

                  MouseArea {
                    id: catMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.setActiveCategory(catBtn.modelData.id)
                  }
                }
              }
            }

            // Right Content Area
            Item {
              width: parent.width - 195
              height: parent.height

              Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Breadcrumb & Category Title Header
                Item {
                  width: parent.width
                  height: 28

                  Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    // Back button when inside subcategory
                    Rectangle {
                      visible: root.navStack.length > 0 && !root.filterText
                      height: 24
                      width: backText.implicitWidth + 12
                      radius: 6
                      color: backMouse.containsMouse ? root.elevatedSurface : root.secondaryBg
                      border.color: root.borderCol
                      border.width: 1
                      anchors.verticalCenter: parent.verticalCenter

                      Row {
                        id: backText
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "←"; color: root.blossomPink; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: "Back"; color: root.secondaryText; font.family: root.fontFamily; font.pixelSize: 11 }
                      }

                      MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.goBack()
                      }
                    }

                    Text {
                      id: pathLabel
                      textFormat: Text.PlainText
                      text: root.filterText
                        ? ("Results for “" + root.filterText + "” (" + displayModel.count + ")")
                        : (root.navStack.length > 0 ? (root.categoryForMenu(root.activeMenu) + " › " + (root.item(root.activeMenu) ? root.item(root.activeMenu).label : root.activeMenu)) : (root.categoryForMenu(root.activeMenu)))
                      color: root.primaryText
                      font.family: root.fontFamily
                      font.pixelSize: 13
                      font.weight: Font.DemiBold
                      anchors.verticalCenter: parent.verticalCenter
                    }
                  }

                  Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.filterText && root.activeMenu === "apps"
                    text: displayModel.count + " applications installed"
                    color: root.mutedText
                    font.family: root.fontFamily
                    font.pixelSize: 11
                  }
                }

                // Dedicated About View
                Item {
                  id: aboutView
                  width: parent.width
                  height: parent.height - 36
                  visible: !root.filterText && root.activeMenu === "about"

                  Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: Qt.rgba(33 / 255, 25 / 255, 37 / 255, 0.6) // #211925
                    border.color: root.borderCol
                    border.width: 1

                    Column {
                      anchors.fill: parent
                      anchors.margins: 18
                      spacing: 14

                      // About Hero Header
                      Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 14

                        Rectangle {
                          width: 58
                          height: 58
                          radius: 29
                          color: root.elevatedSurface
                          border.color: root.blossomPink
                          border.width: 2
                          anchors.verticalCenter: parent.verticalCenter

                          Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: "file://" + Quickshell.env("HOME") + "/.config/omarchy/assets/avatar_sakurazuki.png"
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                          }
                        }

                        Column {
                          anchors.verticalCenter: parent.verticalCenter
                          spacing: 4

                          Row {
                            spacing: 8
                            anchors.left: parent.left

                            Text {
                              text: "Michal"
                              color: root.primaryText
                              font.family: root.fontFamily
                              font.pixelSize: 18
                              font.weight: Font.Bold
                              anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                              height: 20
                              width: aboutThemePillText.implicitWidth + 12
                              radius: 10
                              color: root.elevatedSurface
                              border.color: root.sakuraRose
                              border.width: 1
                              anchors.verticalCenter: parent.verticalCenter

                              Text {
                                id: aboutThemePillText
                                anchors.centerIn: parent
                                text: "🌸 Sakurazuki"
                                color: root.blossomPink
                                font.family: root.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Medium
                              }
                            }
                          }

                          Text {
                            text: "Personalized Linux Desktop & Development Station"
                            color: root.secondaryText
                            font.family: root.fontFamily
                            font.pixelSize: 11
                          }
                        }
                      }

                      // Specs Grid (2 columns x 3 rows) - Clean Fixed Alignment
                      Grid {
                        width: parent.width
                        columns: 2
                        spacing: 8

                        // 1. Operating System
                        Rectangle {
                          width: Math.floor((parent.width - 8) / 2)
                          height: 54
                          radius: 8
                          color: root.elevatedSurface
                          border.color: root.borderCol
                          border.width: 1

                          Rectangle {
                            id: iconBox1
                            width: 36
                            height: 36
                            radius: 6
                            color: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.6)
                            border.color: root.borderCol
                            border.width: 1
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                              anchors.centerIn: parent
                              text: "󰣇"
                              color: root.infoCol
                              font.family: root.fontFamily
                              font.pixelSize: 18
                            }
                          }

                          Column {
                            anchors.left: iconBox1.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                              width: parent.width
                              text: "Operating System"
                              color: root.mutedText
                              font.family: root.fontFamily
                              font.pixelSize: 10
                              elide: Text.ElideRight
                            }
                            Text {
                              width: parent.width
                              text: "Omarchy Linux (Rolling)"
                              color: root.primaryText
                              font.family: root.fontFamily
                              font.pixelSize: 12
                              font.weight: Font.DemiBold
                              elide: Text.ElideRight
                            }
                          }
                        }

                        // 2. Window Manager
                        Rectangle {
                          width: Math.floor((parent.width - 8) / 2)
                          height: 54
                          radius: 8
                          color: root.elevatedSurface
                          border.color: root.borderCol
                          border.width: 1

                          Rectangle {
                            id: iconBox2
                            width: 36
                            height: 36
                            radius: 6
                            color: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.6)
                            border.color: root.borderCol
                            border.width: 1
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                              anchors.centerIn: parent
                              text: ""
                              color: root.blossomPink
                              font.family: root.fontFamily
                              font.pixelSize: 18
                            }
                          }

                          Column {
                            anchors.left: iconBox2.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                              width: parent.width
                              text: "Window Manager"
                              color: root.mutedText
                              font.family: root.fontFamily
                              font.pixelSize: 10
                              elide: Text.ElideRight
                            }
                            Text {
                              width: parent.width
                              text: "Hyprland " + (root.sysHyprland ? root.sysHyprland : "0.56.2") + " (Wayland)"
                              color: root.primaryText
                              font.family: root.fontFamily
                              font.pixelSize: 12
                              font.weight: Font.DemiBold
                              elide: Text.ElideRight
                            }
                          }
                        }

                        // 3. Processor & Memory
                        Rectangle {
                          width: Math.floor((parent.width - 8) / 2)
                          height: 54
                          radius: 8
                          color: root.elevatedSurface
                          border.color: root.borderCol
                          border.width: 1

                          Rectangle {
                            id: iconBox3
                            width: 36
                            height: 36
                            radius: 6
                            color: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.6)
                            border.color: root.borderCol
                            border.width: 1
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                              anchors.centerIn: parent
                              text: "󰌢"
                              color: root.warningCol
                              font.family: root.fontFamily
                              font.pixelSize: 18
                            }
                          }

                          Column {
                            anchors.left: iconBox3.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                              width: parent.width
                              text: "Processor & Memory"
                              color: root.mutedText
                              font.family: root.fontFamily
                              font.pixelSize: 10
                              elide: Text.ElideRight
                            }
                            Text {
                              width: parent.width
                              text: root.sysCpu + (root.sysMem ? (" · " + root.sysMem) : "")
                              color: root.primaryText
                              font.family: root.fontFamily
                              font.pixelSize: 12
                              font.weight: Font.DemiBold
                              elide: Text.ElideRight
                            }
                          }
                        }

                        // 4. Linux Kernel
                        Rectangle {
                          width: Math.floor((parent.width - 8) / 2)
                          height: 54
                          radius: 8
                          color: root.elevatedSurface
                          border.color: root.borderCol
                          border.width: 1

                          Rectangle {
                            id: iconBox4
                            width: 36
                            height: 36
                            radius: 6
                            color: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.6)
                            border.color: root.borderCol
                            border.width: 1
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                              anchors.centerIn: parent
                              text: ""
                              color: root.successCol
                              font.family: root.fontFamily
                              font.pixelSize: 18
                            }
                          }

                          Column {
                            anchors.left: iconBox4.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                              width: parent.width
                              text: "Linux Kernel"
                              color: root.mutedText
                              font.family: root.fontFamily
                              font.pixelSize: 10
                              elide: Text.ElideRight
                            }
                            Text {
                              width: parent.width
                              text: root.sysKernel
                              color: root.primaryText
                              font.family: root.fontFamily
                              font.pixelSize: 12
                              font.weight: Font.DemiBold
                              elide: Text.ElideRight
                            }
                          }
                        }

                        // 5. Desktop Owner
                        Rectangle {
                          width: Math.floor((parent.width - 8) / 2)
                          height: 54
                          radius: 8
                          color: root.elevatedSurface
                          border.color: root.borderCol
                          border.width: 1

                          Rectangle {
                            id: iconBox5
                            width: 36
                            height: 36
                            radius: 6
                            color: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.6)
                            border.color: root.borderCol
                            border.width: 1
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                              anchors.centerIn: parent
                              text: "󰋽"
                              color: root.moonlightLavender
                              font.family: root.fontFamily
                              font.pixelSize: 18
                            }
                          }

                          Column {
                            anchors.left: iconBox5.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                              width: parent.width
                              text: "Desktop Owner"
                              color: root.mutedText
                              font.family: root.fontFamily
                              font.pixelSize: 10
                              elide: Text.ElideRight
                            }
                            Text {
                              width: parent.width
                              text: "Michal"
                              color: root.primaryText
                              font.family: root.fontFamily
                              font.pixelSize: 12
                              font.weight: Font.DemiBold
                              elide: Text.ElideRight
                            }
                          }
                        }

                        // 6. Theme Identity
                        Rectangle {
                          width: Math.floor((parent.width - 8) / 2)
                          height: 54
                          radius: 8
                          color: root.elevatedSurface
                          border.color: root.borderCol
                          border.width: 1

                          Rectangle {
                            id: iconBox6
                            width: 36
                            height: 36
                            radius: 6
                            color: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.6)
                            border.color: root.borderCol
                            border.width: 1
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                              anchors.centerIn: parent
                              text: "🌸"
                              font.pixelSize: 16
                            }
                          }

                          Column {
                            anchors.left: iconBox6.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                              width: parent.width
                              text: "Theme Identity"
                              color: root.mutedText
                              font.family: root.fontFamily
                              font.pixelSize: 10
                              elide: Text.ElideRight
                            }
                            Text {
                              width: parent.width
                              text: "Sakurazuki Aesthetic"
                              color: root.primaryText
                              font.family: root.fontFamily
                              font.pixelSize: 12
                              font.weight: Font.DemiBold
                              elide: Text.ElideRight
                            }
                          }
                        }
                      }

                      // About Actions Row - Evenly Sized & Centered
                      Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12

                        Rectangle {
                          height: 34
                          width: 140
                          radius: 8
                          color: fastfetchBtnMouse.containsMouse ? root.sakuraRose : root.secondaryBg
                          border.color: root.sakuraRose
                          border.width: 1

                          Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "󰍹"; color: root.blossomPink; font.family: root.fontFamily; font.pixelSize: 13 }
                            Text { text: "Fastfetch"; color: root.primaryText; font.family: root.fontFamily; font.pixelSize: 12; font.weight: Font.Medium }
                          }

                          MouseArea {
                            id: fastfetchBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                              root.runAction("omarchy-launch-about")
                              root.close()
                            }
                          }
                        }

                        Rectangle {
                          height: 34
                          width: 140
                          radius: 8
                          color: manualBtnMouse.containsMouse ? root.elevatedSurface : root.secondaryBg
                          border.color: root.borderCol
                          border.width: 1

                          Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: ""; color: root.blossomPink; font.family: root.fontFamily; font.pixelSize: 13 }
                            Text { text: "Omarchy Manual"; color: root.secondaryText; font.family: root.fontFamily; font.pixelSize: 12 }
                          }

                          MouseArea {
                            id: manualBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                              root.runAction("omarchy-launch-webapp 'https://omarchy.org/manual/'")
                              root.close()
                            }
                          }
                        }

                        Rectangle {
                          height: 34
                          width: 140
                          radius: 8
                          color: configBtnMouse.containsMouse ? root.elevatedSurface : root.secondaryBg
                          border.color: root.borderCol
                          border.width: 1

                          Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: ""; color: root.moonlightLavender; font.family: root.fontFamily; font.pixelSize: 13 }
                            Text { text: "Edit Configs"; color: root.secondaryText; font.family: root.fontFamily; font.pixelSize: 12 }
                          }

                          MouseArea {
                            id: configBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                              root.runAction("omarchy-launch-config-editor '$HOME/.config/hypr/hyprland.lua'")
                              root.close()
                            }
                          }
                        }
                      }
                    }
                  }
                }

                // Standard Category & Search ListView
                Item {
                  width: parent.width
                  height: parent.height - 36
                  visible: root.filterText || root.activeMenu !== "about"

                  ListView {
                    id: resultList
                    anchors.fill: parent
                    model: displayModel
                    clip: true
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                      id: rowItem
                      required property int index
                      required property string itemId
                      required property string kind
                      required property string icon
                      required property string iconFont
                      required property string appIcon
                      required property string appId
                      required property string label
                      required property string target
                      required property string detail
                      required property string path
                      required property string action
                      required property int childCount
                      required property string section

                      readonly property bool hasCursor: root.cursorActive && rowItem.index === root.selectedIndex
                      readonly property bool isApp: rowItem.kind === "app"
                      readonly property bool hasIcon: rowItem.icon.length > 0 || rowItem.isApp

                      width: ListView.view.width
                      height: root.rowHeightForDetail(rowItem.detail)
                      radius: 8
                      color: hasCursor ? root.selectedBackground : "transparent"
                      border.color: hasCursor ? root.selectedBorder : "transparent"
                      border.width: hasCursor ? 1 : 0

                      // Selection Bar Indicator
                      Rectangle {
                        visible: rowItem.hasCursor
                        width: 3
                        height: parent.height - 14
                        radius: 1.5
                        color: root.blossomPink
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                      }

                      // Nerd Font Icon
                      Text {
                        id: itemIcon
                        textFormat: Text.PlainText
                        visible: rowItem.hasIcon && !rowItem.isApp
                        text: rowItem.icon || "•"
                        color: rowItem.hasCursor ? root.blossomPink : root.primaryText
                        font.family: rowItem.iconFont.length > 0 ? rowItem.iconFont : root.fontFamily
                        font.pixelSize: 18
                        width: 32
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                      }

                      // App Physical Pixel Icon
                      Image {
                        id: appIconImg
                        visible: rowItem.isApp
                        width: 28
                        height: 28
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: width * Screen.devicePixelRatio
                        sourceSize.height: height * Screen.devicePixelRatio
                        source: rowItem.isApp ? (root.appLibrary ? root.appLibrary.iconSource(rowItem.appIcon) : root.resolveAppIcon(rowItem.appIcon)) : ""
                        asynchronous: true
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                      }

                      // Text Column
                      Column {
                        anchors.left: rowItem.hasIcon ? (rowItem.isApp ? appIconImg.right : itemIcon.right) : parent.left
                        anchors.leftMargin: 12
                        anchors.right: trailRow.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                          textFormat: Text.PlainText
                          width: parent.width
                          text: rowItem.label
                          color: rowItem.hasCursor ? root.primaryText : root.secondaryText
                          font.family: root.fontFamily
                          font.pixelSize: 13
                          font.weight: rowItem.hasCursor ? Font.DemiBold : Font.Normal
                          elide: Text.ElideRight
                        }

                        Text {
                          textFormat: Text.PlainText
                          width: parent.width
                          text: rowItem.detail
                          visible: rowItem.detail.length > 0
                          color: rowItem.hasCursor ? root.blossomPink : root.mutedText
                          font.family: root.fontFamily
                          font.pixelSize: 11
                          elide: Text.ElideRight
                        }
                      }

                      // Right Badges & Indicators
                      Row {
                        id: trailRow
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        // Category Badge when Searching
                        Rectangle {
                          visible: root.filterText.length > 0 && rowItem.section.length > 0
                          height: 18
                          width: catBadgeText.implicitWidth + 8
                          radius: 4
                          color: root.secondaryBg
                          border.color: root.borderCol
                          border.width: 1
                          anchors.verticalCenter: parent.verticalCenter

                          Text {
                            id: catBadgeText
                            anchors.centerIn: parent
                            text: rowItem.section
                            color: root.mutedText
                            font.family: root.fontFamily
                            font.pixelSize: 10
                          }
                        }

                        // Action / Launch Badge
                        Rectangle {
                          visible: rowItem.hasCursor && rowItem.kind !== "info"
                          height: 20
                          width: actionBadgeText.implicitWidth + 10
                          radius: 5
                          color: root.secondaryBg
                          border.color: root.sakuraRose
                          border.width: 1
                          anchors.verticalCenter: parent.verticalCenter

                          Text {
                            id: actionBadgeText
                            anchors.centerIn: parent
                            text: rowItem.kind === "calc" ? "↵ Copy" : (rowItem.kind === "cmd" ? "↵ Run" : (rowItem.kind === "menu" || rowItem.kind === "link" ? "› Open" : "↵ Launch"))
                            color: root.blossomPink
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Medium
                          }
                        }

                        // Submenu Chevron
                        Text {
                          textFormat: Text.PlainText
                          visible: !rowItem.hasCursor && (rowItem.kind === "menu" || rowItem.kind === "link")
                          text: "›"
                          color: root.mutedText
                          font.family: root.fontFamily
                          font.pixelSize: 16
                          anchors.verticalCenter: parent.verticalCenter
                        }
                      }

                      MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selectFromPointer(rowItem.index)
                        onClicked: {
                          root.cursorActive = true
                          root.selectedIndex = rowItem.index
                          root.activateIndex(rowItem.index)
                        }
                      }
                    }
                  }

                  // Empty Search / Category State
                  Column {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: displayModel.count === 0 && !root.dmenuActive

                    Text {
                      text: "󰈉"
                      color: root.blossomPink
                      font.family: root.fontFamily
                      font.pixelSize: 36
                      horizontalAlignment: Text.AlignHCenter
                      width: 260
                    }

                    Text {
                      textFormat: Text.PlainText
                      text: !root.rowsLoaded ? "Loading menu items..." : (root.filterText ? ("No matches for “" + root.filterText + "”") : ("No items in " + root.categoryForMenu(root.activeMenu)))
                      color: root.primaryText
                      font.family: root.fontFamily
                      font.pixelSize: 14
                      font.weight: Font.Medium
                      horizontalAlignment: Text.AlignHCenter
                      width: 260
                    }

                    Text {
                      text: !root.rowsLoaded ? "Please wait a moment." : (root.filterText ? "Check your search terms or choose another category." : "Choose another category or use search to find apps and actions.")
                      color: root.mutedText
                      font.family: root.fontFamily
                      font.pixelSize: 11
                      horizontalAlignment: Text.AlignHCenter
                      width: 260
                    }
                  }
                }
              }
            }
          }

          // Bottom Separator Hairline
          Rectangle {
            width: parent.width
            height: 1
            color: root.borderCol
          }

          // Bottom Footer Status Bar
          Rectangle {
            width: parent.width
            height: 38
            color: Qt.rgba(20 / 255, 17 / 255, 26 / 255, 0.5)

            // Left Quick Actions (Power & Lock)
            Row {
              anchors.left: parent.left
              anchors.leftMargin: 14
              anchors.verticalCenter: parent.verticalCenter
              spacing: 8

              // Lock Button
              Rectangle {
                height: 24
                width: lockBtnContent.implicitWidth + 14
                radius: 6
                color: lockMouse.containsMouse ? root.elevatedSurface : "transparent"
                border.color: lockMouse.containsMouse ? root.sakuraRose : root.borderCol
                border.width: 1

                Row {
                  id: lockBtnContent
                  anchors.centerIn: parent
                  spacing: 4
                  Text { text: ""; color: root.blossomPink; font.family: root.fontFamily; font.pixelSize: 11 }
                  Text { text: "Lock"; color: root.secondaryText; font.family: root.fontFamily; font.pixelSize: 11 }
                }

                MouseArea {
                  id: lockMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.runAction("omarchy-system-lock")
                    root.close()
                  }
                }
              }

              // Reboot Button
              Rectangle {
                height: 24
                width: rebootBtnContent.implicitWidth + 14
                radius: 6
                color: rebootMouse.containsMouse ? root.elevatedSurface : "transparent"
                border.color: rebootMouse.containsMouse ? root.sakuraRose : root.borderCol
                border.width: 1

                Row {
                  id: rebootBtnContent
                  anchors.centerIn: parent
                  spacing: 4
                  Text { text: "󰜉"; color: root.warningCol; font.family: root.fontFamily; font.pixelSize: 11 }
                  Text { text: "Reboot"; color: root.secondaryText; font.family: root.fontFamily; font.pixelSize: 11 }
                }

                MouseArea {
                  id: rebootMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.runAction("omarchy-system-reboot")
                    root.close()
                  }
                }
              }

              // Shutdown Button
              Rectangle {
                height: 24
                width: shutBtnContent.implicitWidth + 14
                radius: 6
                color: shutMouse.containsMouse ? root.elevatedSurface : "transparent"
                border.color: shutMouse.containsMouse ? root.errorCol : root.borderCol
                border.width: 1

                Row {
                  id: shutBtnContent
                  anchors.centerIn: parent
                  spacing: 4
                  Text { text: "󰐥"; color: root.errorCol; font.family: root.fontFamily; font.pixelSize: 11 }
                  Text { text: "Shutdown"; color: root.secondaryText; font.family: root.fontFamily; font.pixelSize: 11 }
                }

                MouseArea {
                  id: shutMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.runAction("omarchy-system-shutdown")
                    root.close()
                  }
                }
              }
            }

            // Right Keyboard Navigation Shortcuts
            Row {
              anchors.right: parent.right
              anchors.rightMargin: 16
              anchors.verticalCenter: parent.verticalCenter
              spacing: 16

              Row {
                spacing: 4
                Text { text: "↑↓"; color: root.blossomPink; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                Text { text: "Navigate"; color: root.mutedText; font.family: root.fontFamily; font.pixelSize: 11 }
              }

              Row {
                spacing: 4
                Text { text: "↵"; color: root.blossomPink; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                Text { text: "Open"; color: root.mutedText; font.family: root.fontFamily; font.pixelSize: 11 }
              }

              Row {
                spacing: 4
                Text { text: "Tab"; color: root.blossomPink; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                Text { text: "Category"; color: root.mutedText; font.family: root.fontFamily; font.pixelSize: 11 }
              }

              Row {
                spacing: 4
                Text { text: "Esc"; color: root.blossomPink; font.family: root.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                Text { text: "Back/Close"; color: root.mutedText; font.family: root.fontFamily; font.pixelSize: 11 }
              }
            }
          }
        }
      }
    }
  }
}
