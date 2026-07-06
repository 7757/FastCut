import AppKit
import SwiftUI
import Carbon.HIToolbox

/// A borderless panel that is still allowed to become key so the search
/// field inside can receive keyboard input.
final class KeyPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// View-model backing the popup's SwiftUI content.
final class PopupModel: ObservableObject {
    // Selection is tracked by item identity, not by position: a background copy
    // (Universal Clipboard, re-copy, automation) can reorder the list while the
    // popup is open, and the highlight must stay on the item the user chose.
    @Published var query: String = "" { didSet { selectedID = current.first?.id } }
    @Published var selectedID: UUID?
    @Published var focusTick: Int = 0     // bumped to (re)focus the search field

    unowned let store: HistoryStore
    var onConfirm: ((ClipItem) -> Void)?
    var onDelete: ((ClipItem) -> Void)?
    var onClose: (() -> Void)?

    init(store: HistoryStore) { self.store = store }

    func filtered(_ items: [ClipItem]) -> [ClipItem] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return items }
        return items.filter { ($0.text ?? "").lowercased().contains(q) }
    }

    private var current: [ClipItem] { filtered(store.items) }

    /// Reset the highlight to the top of the current list.
    func selectFirst() { selectedID = current.first?.id }

    func move(_ delta: Int) {
        let items = current
        guard !items.isEmpty else { selectedID = nil; return }
        let cur = items.firstIndex { $0.id == selectedID } ?? 0
        let next = min(max(cur + delta, 0), items.count - 1)
        selectedID = items[next].id
    }

    func confirmSelection() {
        guard let id = selectedID, let item = current.first(where: { $0.id == id }) else { return }
        onConfirm?(item)
    }

    /// Paste the item at a specific position (used by ⌘1–⌘9 quick paste).
    func confirmAt(_ index: Int) {
        let items = current
        guard index >= 0, index < items.count else { return }
        onConfirm?(items[index])
    }

    func deleteSelection() {
        let items = current
        guard let id = selectedID, let idx = items.firstIndex(where: { $0.id == id }) else { return }
        onDelete?(items[idx])
        let after = current
        selectedID = after.isEmpty ? nil : after[min(idx, after.count - 1)].id
    }
}

/// Owns the floating popup window, its keyboard handling, and show/hide flow.
final class PopupController: NSObject, NSWindowDelegate {
    let store: HistoryStore
    let model: PopupModel
    private let panel: KeyPanel
    private var keyMonitor: Any?
    private(set) var previousApp: NSRunningApplication?

    /// Called when the user picks an item. The AppDelegate wires this to the
    /// pasteboard-write + auto-paste flow.
    var onConfirm: ((ClipItem) -> Void)?

    private let size = NSSize(width: 540, height: 440)

    init(store: HistoryStore) {
        self.store = store
        self.model = PopupModel(store: store)
        self.panel = KeyPanel(contentRect: NSRect(origin: .zero, size: size),
                              styleMask: [.borderless],
                              backing: .buffered, defer: false)
        super.init()

        model.onConfirm = { [weak self] item in self?.confirm(item) }
        model.onClose = { [weak self] in self?.hide() }
        model.onDelete = { [weak self] item in self?.store.remove(item) }

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.animationBehavior = .utilityWindow
        panel.delegate = self

        let root = HistoryView(store: store, model: model)
        let host = NSHostingView(rootView: root)
        host.frame = NSRect(origin: .zero, size: size)
        panel.contentView = host
    }

    var isVisible: Bool { panel.isVisible }

    func toggle() { panel.isVisible ? hide() : show() }

    func show() {
        previousApp = NSWorkspace.shared.frontmostApplication
        model.query = ""          // didSet selects the first item
        model.selectFirst()
        position()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        model.focusTick &+= 1
        installKeyMonitor()
    }

    func hide() {
        removeKeyMonitor()
        panel.orderOut(nil)
    }

    private func confirm(_ item: ClipItem) {
        hide()
        onConfirm?(item)
    }

    private func position() {
        panel.setContentSize(size)
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
        guard let frame = screen?.visibleFrame else { return }
        let x = frame.midX - size.width / 2
        let y = frame.midY - size.height / 2 + frame.height * 0.08
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    // MARK: Keyboard handling while visible

    private func installKeyMonitor() {
        removeKeyMonitor()
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.panel.isVisible else { return event }
            // ⌘1–⌘9 pastes the 1st–9th item directly.
            if event.modifierFlags.contains(.command),
               let ch = event.charactersIgnoringModifiers, let n = Int(ch), (1...9).contains(n) {
                self.model.confirmAt(n - 1); return nil
            }
            switch Int(event.keyCode) {
            case kVK_DownArrow:
                self.model.move(1); return nil
            case kVK_UpArrow:
                self.model.move(-1); return nil
            case kVK_Return, kVK_ANSI_KeypadEnter:
                self.model.confirmSelection(); return nil
            case kVK_Escape:
                self.hide(); return nil
            case kVK_Delete where event.modifierFlags.contains(.command)
                                && event.modifierFlags.contains(.shift):
                // ⌘⇧⌫ deletes the item. (Plain ⌘⌫ is left for the search field's
                // standard "delete to start of line" text editing.)
                self.model.deleteSelection(); return nil
            default:
                return event   // let the search field handle normal typing
            }
        }
    }

    private func removeKeyMonitor() {
        if let m = keyMonitor { NSEvent.removeMonitor(m); keyMonitor = nil }
    }

    // MARK: NSWindowDelegate

    func windowDidResignKey(_ notification: Notification) {
        // User clicked away -> dismiss.
        if panel.isVisible { hide() }
    }
}
