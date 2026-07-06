import AppKit
import Carbon.HIToolbox

extension Notification.Name {
    static let fcHotKeyChanged = Notification.Name("fastcut.hotKeyChanged")
    static let fcMaxHistoryChanged = Notification.Name("fastcut.maxHistoryChanged")
}

/// User-facing preferences, persisted in UserDefaults.
final class Settings: ObservableObject {
    static let shared = Settings()
    private let d = UserDefaults.standard

    // Persist only in the individual setters; the change is announced once via
    // applyHotKey(code:modifiers:) so keyCode+modifiers register together
    // (avoids a transient intermediate combo and a double registration).
    @Published var hotKeyCode: UInt32 {
        didSet { d.set(Int(hotKeyCode), forKey: Keys.hotKeyCode) }
    }
    @Published var hotKeyModifiers: UInt32 {
        didSet { d.set(Int(hotKeyModifiers), forKey: Keys.hotKeyModifiers) }
    }

    /// Set both halves of the shortcut atomically and announce the change once.
    func applyHotKey(code: UInt32, modifiers: UInt32) {
        hotKeyCode = code
        hotKeyModifiers = modifiers
        NotificationCenter.default.post(name: .fcHotKeyChanged, object: nil)
    }
    @Published var maxHistory: Int {
        didSet { d.set(maxHistory, forKey: Keys.maxHistory)
                 NotificationCenter.default.post(name: .fcMaxHistoryChanged, object: nil) }
    }
    @Published var autoPaste: Bool {
        didSet { d.set(autoPaste, forKey: Keys.autoPaste) }
    }
    @Published var launchAtLogin: Bool {
        didSet { d.set(launchAtLogin, forKey: Keys.launchAtLogin)
                 LoginItem.set(launchAtLogin) }
    }

    private enum Keys {
        static let hotKeyCode = "hotKeyCode"
        static let hotKeyModifiers = "hotKeyModifiers"
        static let maxHistory = "maxHistory"
        static let autoPaste = "autoPaste"
        static let launchAtLogin = "launchAtLogin"
    }

    private init() {
        d.register(defaults: [
            Keys.hotKeyCode: kVK_ANSI_V,                 // V
            Keys.hotKeyModifiers: cmdKey | shiftKey,     // ⌘⇧
            Keys.maxHistory: 100,
            Keys.autoPaste: true,
            Keys.launchAtLogin: false,
        ])
        hotKeyCode = UInt32(d.integer(forKey: Keys.hotKeyCode))
        hotKeyModifiers = UInt32(d.integer(forKey: Keys.hotKeyModifiers))
        maxHistory = d.integer(forKey: Keys.maxHistory)
        autoPaste = d.bool(forKey: Keys.autoPaste)
        launchAtLogin = d.bool(forKey: Keys.launchAtLogin)
    }
}
