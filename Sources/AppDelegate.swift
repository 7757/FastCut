import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var store: HistoryStore!
    private var monitor: ClipboardMonitor!
    private var popup: PopupController!
    private var hotKey: HotKeyManager!
    private var prefs: PreferencesWindowController!
    private var statusItem: NSStatusItem!
    private var lastGoodCode: UInt32 = 0
    private var lastGoodModifiers: UInt32 = 0
    private var didPromptAccessibility = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        store = HistoryStore()
        monitor = ClipboardMonitor(store: store)
        monitor.start()

        popup = PopupController(store: store)
        popup.onConfirm = { [weak self] item in self?.performPaste(item) }

        prefs = PreferencesWindowController(store: store)

        hotKey = HotKeyManager()
        hotKey.action = { [weak self] in self?.popup.toggle() }
        registerHotKey()

        setupStatusItem()

        NotificationCenter.default.addObserver(forName: .fcHotKeyChanged, object: nil, queue: .main) { [weak self] _ in
            self?.registerHotKey()
        }
        NotificationCenter.default.addObserver(forName: .fcMaxHistoryChanged, object: nil, queue: .main) { [weak self] _ in
            self?.store.trim()
        }

        // Keep the login-item state in sync with the stored preference.
        if Settings.shared.launchAtLogin { LoginItem.set(true) }
    }

    private func registerHotKey() {
        let code = Settings.shared.hotKeyCode
        let mods = Settings.shared.hotKeyModifiers
        if hotKey.register(keyCode: code, modifiers: mods) {
            lastGoodCode = code
            lastGoodModifiers = mods
        } else {
            NSSound.beep()
            let alert = NSAlert()
            alert.messageText = "That shortcut isn’t available"
            alert.informativeText = "It may already be in use by another app. Reverting to the previous shortcut."
            alert.runModal()
            if lastGoodCode != 0 {
                // Re-posts .fcHotKeyChanged (delivered async on the main queue),
                // which re-registers the known-good combo and refreshes the recorder.
                Settings.shared.applyHotKey(code: lastGoodCode, modifiers: lastGoodModifiers)
            }
        }
    }

    // MARK: Status bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "bolt.fill",
                                accessibilityDescription: "FastCut")
            image?.isTemplate = true   // black on light menu bars, white on dark
            button.image = image
        }
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        let shortcut = ShortcutFormatter.string(keyCode: Settings.shared.hotKeyCode,
                                                modifiers: Settings.shared.hotKeyModifiers)
        let show = NSMenuItem(title: "Show Clipboard History",
                              action: #selector(togglePopup), keyEquivalent: "")
        show.target = self
        show.toolTip = shortcut
        menu.addItem(show)
        menu.addItem(.separator())

        let recents = Array(store.items.prefix(8))
        if recents.isEmpty {
            let empty = NSMenuItem(title: "No items yet", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            menu.addItem(empty)
        } else {
            for (i, item) in recents.enumerated() {
                let mi = NSMenuItem(title: menuTitle(for: item),
                                    action: #selector(copyRecent(_:)), keyEquivalent: "")
                mi.target = self
                mi.tag = i
                if item.kind == .image, let img = store.image(for: item) {
                    let thumb = NSImage(size: NSSize(width: 20, height: 16))
                    thumb.lockFocus()
                    img.draw(in: NSRect(x: 0, y: 0, width: 20, height: 16))
                    thumb.unlockFocus()
                    mi.image = thumb
                }
                menu.addItem(mi)
            }
        }

        menu.addItem(.separator())

        if !Paster.hasAccessibility() {
            let ax = NSMenuItem(title: "Enable Auto-Paste (Accessibility)…",
                                action: #selector(enableAccessibility), keyEquivalent: "")
            ax.target = self
            menu.addItem(ax)
        }
        let clear = NSMenuItem(title: "Clear History",
                               action: #selector(clearHistory), keyEquivalent: "")
        clear.target = self
        menu.addItem(clear)
        let pref = NSMenuItem(title: "Preferences…",
                              action: #selector(openPreferences), keyEquivalent: ",")
        pref.target = self
        menu.addItem(pref)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit FastCut",
                                action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    private func menuTitle(for item: ClipItem) -> String {
        if item.kind == .image { return "Image" }
        let flat = (item.text ?? "")
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return flat.count > 48 ? String(flat.prefix(48)) + "…" : flat
    }

    // MARK: Actions

    @objc private func togglePopup() { popup.toggle() }

    @objc private func copyRecent(_ sender: NSMenuItem) {
        let idx = sender.tag
        guard idx >= 0, idx < store.items.count else { return }
        let item = store.items[idx]
        writeToPasteboard(item)
        monitor.ignoreCurrentChange()
        store.moveToFront(item)
    }

    @objc private func clearHistory() { store.clear() }

    @objc private func openPreferences() { prefs.show() }

    @objc private func enableAccessibility() { Paster.requestAccessibility() }

    // MARK: Paste flow

    private func performPaste(_ item: ClipItem) {
        writeToPasteboard(item)
        monitor.ignoreCurrentChange()
        store.moveToFront(item)

        // Only auto-paste when we have a real target app (not ourselves).
        let ourBundleID = Bundle.main.bundleIdentifier
        guard let target = popup.previousApp,
              target.bundleIdentifier != ourBundleID else { return }

        guard Settings.shared.autoPaste else {
            target.activate()
            return
        }
        guard Paster.hasAccessibility() else {
            // Fall back to copy-only, and ask for permission at most once per
            // launch so we never spam the system prompt on every paste.
            target.activate()
            if !didPromptAccessibility {
                didPromptAccessibility = true
                Paster.requestAccessibility()
            }
            return
        }
        target.activate()
        pasteWhenFrontmost(target)
    }

    /// Post Cmd-V only once the target app is actually frontmost, so the paste
    /// never lands in FastCut or whatever app happened to be up. Gives up after
    /// ~0.9s — the item is on the clipboard regardless, so a manual paste works.
    private func pasteWhenFrontmost(_ target: NSRunningApplication, attemptsLeft: Int = 30) {
        if NSWorkspace.shared.frontmostApplication?.processIdentifier == target.processIdentifier {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) { Paster.paste() }
            return
        }
        guard attemptsLeft > 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) { [weak self] in
            self?.pasteWhenFrontmost(target, attemptsLeft: attemptsLeft - 1)
        }
    }

    private func writeToPasteboard(_ item: ClipItem) {
        let pb = NSPasteboard.general
        pb.clearContents()
        switch item.kind {
        case .text:
            pb.setString(item.text ?? "", forType: .string)
        case .image:
            if let img = store.image(for: item) {
                pb.writeObjects([img])
            }
        }
    }
}
