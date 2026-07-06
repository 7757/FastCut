import AppKit
import SwiftUI

// MARK: - Popup history view

struct HistoryView: View {
    @ObservedObject var store: HistoryStore
    @ObservedObject var model: PopupModel
    @FocusState private var searchFocused: Bool

    private var items: [ClipItem] { model.filtered(store.items) }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            Divider()
            content
            Divider()
            footer
        }
        .frame(width: 540, height: 440)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .onAppear { searchFocused = true }
        .onChange(of: model.focusTick) { _, _ in searchFocused = true }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search clipboard…", text: $model.query)
                .textFieldStyle(.plain)
                .font(.system(size: 15))
                .focused($searchFocused)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    @ViewBuilder private var content: some View {
        if items.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: store.items.isEmpty ? "doc.on.clipboard" : "magnifyingglass")
                    .font(.system(size: 30)).foregroundStyle(.tertiary)
                Text(store.items.isEmpty ? "Nothing copied yet" : "No matches")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(items) { item in
                            Row(item: item, store: store, selected: item.id == model.selectedID)
                                .id(item.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    model.selectedID = item.id
                                    model.confirmSelection()
                                }
                        }
                    }
                    .padding(8)
                }
                .onChange(of: model.selectedID) { _, sel in
                    if let sel {
                        withAnimation(.linear(duration: 0.08)) { proxy.scrollTo(sel, anchor: .center) }
                    }
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 14) {
            hint("↩", "Paste")
            hint("⌘⇧⌫", "Delete")
            hint("⎋", "Close")
            Spacer()
            Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                .foregroundStyle(.secondary)
        }
        .font(.system(size: 11))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private func hint(_ key: String, _ label: String) -> some View {
        HStack(spacing: 4) {
            Text(key)
                .padding(.horizontal, 5).padding(.vertical, 1)
                .background(Color.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(label).foregroundStyle(.secondary)
        }
    }
}

private struct Row: View {
    let item: ClipItem
    let store: HistoryStore
    let selected: Bool

    var body: some View {
        HStack(spacing: 11) {
            thumbnail
            VStack(alignment: .leading, spacing: 3) {
                Text(previewText)
                    .lineLimit(2)
                    .font(.system(size: 13))
                    .foregroundStyle(selected ? Color.white : Color.primary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(selected ? Color.white.opacity(0.85) : Color.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(selected ? Color.accentColor : Color.clear)
        )
    }

    @ViewBuilder private var thumbnail: some View {
        if item.kind == .image, let img = store.image(for: item) {
            Image(nsImage: img)
                .resizable().interpolation(.medium).scaledToFit()
                .frame(width: 40, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.12)))
                .frame(width: 46, height: 40)
        } else {
            tile.frame(width: 46, height: 40)
        }
    }

    // A colored, rounded tile whose glyph/swatch reflects the content type.
    @ViewBuilder private var tile: some View {
        let kind = ClipContent.classify(item.text ?? "")
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(selected ? Color.white.opacity(0.22) : kind.tint.opacity(0.16))
            .frame(width: 34, height: 34)
            .overlay {
                if case .color(let c) = kind {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color(nsColor: c))
                        .frame(width: 20, height: 20)
                        .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1))
                } else {
                    Image(systemName: kind.symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(selected ? Color.white : kind.tint)
                }
            }
    }

    private var previewText: String {
        if item.kind == .image { return "Image" }
        return (item.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var subtitle: String {
        let when = item.date.formatted(.relative(presentation: .numeric))
        if item.kind == .image {
            if let img = store.image(for: item) {
                return "\(Int(img.size.width))×\(Int(img.size.height)) image · \(when)"
            }
            return "Image · \(when)"
        }
        let kind = ClipContent.classify(item.text ?? "")
        if let label = kind.label { return "\(label) · \(when)" }
        let n = (item.text ?? "").count
        return "\(n) character\(n == 1 ? "" : "s") · \(when)"
    }
}

/// Lightweight content-type detection used to pick a row's icon, tint, and label.
enum ClipContent {
    case url, email, filePath, color(NSColor), number, multiline, text

    static func classify(_ raw: String) -> ClipContent {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = s.lowercased()
        if lower.hasPrefix("http://") || lower.hasPrefix("https://") || lower.hasPrefix("www.") {
            return .url
        }
        if s.hasPrefix("/") || s.hasPrefix("~/") || lower.hasPrefix("file://") {
            return .filePath
        }
        if hexColor(s) != nil { return .color(hexColor(s)!) }
        if isEmail(s) { return .email }
        if isNumberLike(s) { return .number }
        if s.contains("\n") { return .multiline }
        return .text
    }

    var symbol: String {
        switch self {
        case .url:       return "link"
        case .email:     return "envelope.fill"
        case .filePath:  return "folder.fill"
        case .color:     return "paintpalette.fill"
        case .number:    return "number"
        case .multiline: return "text.alignleft"
        case .text:      return "text.quote"
        }
    }

    var tint: Color {
        switch self {
        case .url:       return .blue
        case .email:     return .teal
        case .filePath:  return .indigo
        case .color:     return .pink
        case .number:    return .orange
        case .multiline: return .gray
        case .text:      return .secondary
        }
    }

    var label: String? {
        switch self {
        case .url:      return "Link"
        case .email:    return "Email"
        case .filePath: return "File path"
        case .color:    return "Color"
        case .number:   return "Number"
        default:        return nil
        }
    }

    // MARK: detectors

    private static func isEmail(_ s: String) -> Bool {
        guard !s.contains(" "), !s.contains("\n") else { return false }
        let parts = s.split(separator: "@")
        return parts.count == 2 && !parts[0].isEmpty && parts[1].contains(".")
    }

    private static func isNumberLike(_ s: String) -> Bool {
        guard !s.isEmpty, s.count <= 40, !s.contains("\n") else { return false }
        let allowed = CharacterSet(charactersIn: "0123456789 ,.-+()$¥€£%")
        return s.contains(where: { $0.isNumber })
            && s.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    private static func hexColor(_ s: String) -> NSColor? {
        var h = s.hasPrefix("#") ? String(s.dropFirst()) : s
        guard (h.count == 6 || h.count == 3), h.allSatisfy({ $0.isHexDigit }) else { return nil }
        if h.count == 3 { h = h.map { "\($0)\($0)" }.joined() }
        var v: UInt64 = 0
        Scanner(string: h).scanHexInt64(&v)
        return NSColor(srgbRed: CGFloat((v >> 16) & 0xff) / 255,
                       green: CGFloat((v >> 8) & 0xff) / 255,
                       blue: CGFloat(v & 0xff) / 255, alpha: 1)
    }
}

// MARK: - Preferences

struct PreferencesView: View {
    @ObservedObject var settings = Settings.shared
    let store: HistoryStore

    var body: some View {
        Form {
            Section("Shortcut") {
                LabeledContent("Show clipboard history") {
                    ShortcutRecorder(keyCode: settings.hotKeyCode,
                                     modifiers: settings.hotKeyModifiers) { kc, mods in
                        settings.applyHotKey(code: kc, modifiers: mods)
                    }
                    .frame(width: 150, height: 26)
                }
            }
            Section("Behavior") {
                Toggle("Paste automatically into the active app", isOn: $settings.autoPaste)
                Stepper(value: $settings.maxHistory, in: 10...500, step: 10) {
                    Text("Keep the last \(settings.maxHistory) items")
                }
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
            }
            Section {
                Button("Clear History", role: .destructive) { store.clear() }
                Text("Auto-paste needs Accessibility permission. Passwords from password managers are ignored automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 360)
    }
}

/// A SwiftUI wrapper around an NSButton that records a global shortcut.
struct ShortcutRecorder: NSViewRepresentable {
    var keyCode: UInt32
    var modifiers: UInt32
    var onCommit: (UInt32, UInt32) -> Void

    func makeNSView(context: Context) -> RecorderButton {
        let b = RecorderButton()
        b.onRecord = { kc, mods in onCommit(kc, mods) }
        b.refresh(keyCode: keyCode, modifiers: modifiers)
        return b
    }

    func updateNSView(_ nsView: RecorderButton, context: Context) {
        nsView.refresh(keyCode: keyCode, modifiers: modifiers)
    }
}

final class RecorderButton: NSButton {
    var onRecord: ((UInt32, UInt32) -> Void)?
    private var recording = false
    private var monitor: Any?
    private var curKeyCode: UInt32 = 0
    private var curModifiers: UInt32 = 0

    override init(frame frameRect: NSRect) { super.init(frame: frameRect); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        bezelStyle = .rounded
        setButtonType(.momentaryPushIn)
        target = self
        action = #selector(beginRecording)
    }

    func refresh(keyCode: UInt32, modifiers: UInt32) {
        curKeyCode = keyCode
        curModifiers = modifiers
        if !recording {
            title = ShortcutFormatter.string(keyCode: keyCode, modifiers: modifiers)
        }
    }

    @objc private func beginRecording() {
        guard !recording else { return }
        recording = true
        title = "Type shortcut…"
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self else { return event }
            guard event.type == .keyDown else { return nil }
            if event.keyCode == 53 { self.endRecording(); return nil } // Esc cancels
            let mods = carbonModifiers(from: event.modifierFlags)
            if mods == 0 { NSSound.beep(); return nil }                // require a modifier
            self.curKeyCode = UInt32(event.keyCode)
            self.curModifiers = mods
            self.onRecord?(self.curKeyCode, self.curModifiers)
            self.endRecording()
            return nil
        }
    }

    private func endRecording() {
        recording = false
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
        title = ShortcutFormatter.string(keyCode: curKeyCode, modifiers: curModifiers)
    }
}

// MARK: - Preferences window

final class PreferencesWindowController {
    private var window: NSWindow?
    private let store: HistoryStore

    init(store: HistoryStore) { self.store = store }

    func show() {
        if window == nil {
            let host = NSHostingController(rootView: PreferencesView(store: store))
            let win = NSWindow(contentViewController: host)
            win.title = "FastCut Preferences"
            win.styleMask = [.titled, .closable]
            win.isReleasedWhenClosed = false
            win.center()
            window = win
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
