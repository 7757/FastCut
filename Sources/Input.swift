import AppKit
import Carbon.HIToolbox
import ServiceManagement

// MARK: - Modifier conversion

/// Convert AppKit modifier flags to Carbon modifier flags (used by RegisterEventHotKey).
func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
    var m: UInt32 = 0
    if flags.contains(.command) { m |= UInt32(cmdKey) }
    if flags.contains(.shift)   { m |= UInt32(shiftKey) }
    if flags.contains(.option)  { m |= UInt32(optionKey) }
    if flags.contains(.control) { m |= UInt32(controlKey) }
    return m
}

// MARK: - Global hotkey (Carbon)

// A single global handler dispatches by hotkey id to the registered closures.
private var fcHotKeyActions: [UInt32: () -> Void] = [:]
private var fcCarbonHandlerInstalled = false
private let fcHotKeySignature: OSType = 0x46435554 // 'FCUT'

private func fcInstallCarbonHandler() {
    guard !fcCarbonHandlerInstalled else { return }
    var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                             eventKind: UInt32(kEventHotKeyPressed))
    InstallEventHandler(GetEventDispatcherTarget(), { (_, event, _) -> OSStatus in
        var hkID = EventHotKeyID()
        let err = GetEventParameter(event, EventParamName(kEventParamDirectObject),
                                    EventParamType(typeEventHotKeyID), nil,
                                    MemoryLayout<EventHotKeyID>.size, nil, &hkID)
        if err == noErr { fcHotKeyActions[hkID.id]?() }
        return noErr
    }, 1, &spec, nil, nil)
    fcCarbonHandlerInstalled = true
}

final class HotKeyManager {
    private var ref: EventHotKeyRef?
    private let id: UInt32 = 1
    private var registeredCode: UInt32?
    private var registeredModifiers: UInt32?
    var action: (() -> Void)?

    /// Register the global hotkey. Returns false if the combo could not be
    /// claimed (e.g. already owned by another app); in that case the previously
    /// working hotkey is left intact.
    @discardableResult
    func register(keyCode: UInt32, modifiers: UInt32) -> Bool {
        // Re-registering the identical, already-active combo is a no-op success.
        if ref != nil, registeredCode == keyCode, registeredModifiers == modifiers {
            return true
        }
        fcInstallCarbonHandler()
        fcHotKeyActions[id] = { [weak self] in self?.action?() }
        let hkID = EventHotKeyID(signature: fcHotKeySignature, id: id)
        var newRef: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode, modifiers, hkID,
                                         GetEventDispatcherTarget(), 0, &newRef)
        guard status == noErr, let newRef else {
            NSLog("FastCut: hotkey registration failed (status \(status)); keeping previous hotkey")
            return false
        }
        // Success: only now drop the old registration and swap in the new one,
        // so a failed change never leaves the app with no working hotkey.
        if let old = ref { UnregisterEventHotKey(old) }
        ref = newRef
        registeredCode = keyCode
        registeredModifiers = modifiers
        return true
    }

    func unregister() {
        if let r = ref { UnregisterEventHotKey(r); ref = nil }
        registeredCode = nil
        registeredModifiers = nil
    }
}

// MARK: - Simulated paste (Cmd+V via CGEvent)

enum Paster {
    static func hasAccessibility() -> Bool {
        AXIsProcessTrusted()
    }

    /// Prompt the user to grant Accessibility permission (opens System Settings).
    static func requestAccessibility() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        _ = AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
    }

    static func paste() {
        // Use a private (empty) event-source state so physically-held hotkey
        // modifiers (e.g. the ⇧ from ⌘⇧V) are NOT merged into the synthesized
        // event — otherwise Cmd+V could arrive as Cmd+Shift+V ("paste & match").
        let src = CGEventSource(stateID: .privateState)
        let v = CGKeyCode(kVK_ANSI_V)
        let down = CGEvent(keyboardEventSource: src, virtualKey: v, keyDown: true)
        down?.flags = .maskCommand
        let up = CGEvent(keyboardEventSource: src, virtualKey: v, keyDown: false)
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
}

// MARK: - Launch at login

enum LoginItem {
    static func set(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
        } catch {
            NSLog("FastCut: login-item update failed \(error)")
        }
    }
}

// MARK: - Shortcut display formatting

enum ShortcutFormatter {
    static func string(keyCode: UInt32, modifiers: UInt32) -> String {
        var s = ""
        if modifiers & UInt32(controlKey) != 0 { s += "⌃" }
        if modifiers & UInt32(optionKey)  != 0 { s += "⌥" }
        if modifiers & UInt32(shiftKey)   != 0 { s += "⇧" }
        if modifiers & UInt32(cmdKey)     != 0 { s += "⌘" }
        s += keyName(keyCode)
        return s
    }

    static func keyName(_ code: UInt32) -> String {
        keyMap[Int(code)] ?? "Key\(code)"
    }

    private static let keyMap: [Int: String] = [
        kVK_ANSI_A: "A", kVK_ANSI_B: "B", kVK_ANSI_C: "C", kVK_ANSI_D: "D",
        kVK_ANSI_E: "E", kVK_ANSI_F: "F", kVK_ANSI_G: "G", kVK_ANSI_H: "H",
        kVK_ANSI_I: "I", kVK_ANSI_J: "J", kVK_ANSI_K: "K", kVK_ANSI_L: "L",
        kVK_ANSI_M: "M", kVK_ANSI_N: "N", kVK_ANSI_O: "O", kVK_ANSI_P: "P",
        kVK_ANSI_Q: "Q", kVK_ANSI_R: "R", kVK_ANSI_S: "S", kVK_ANSI_T: "T",
        kVK_ANSI_U: "U", kVK_ANSI_V: "V", kVK_ANSI_W: "W", kVK_ANSI_X: "X",
        kVK_ANSI_Y: "Y", kVK_ANSI_Z: "Z",
        kVK_ANSI_0: "0", kVK_ANSI_1: "1", kVK_ANSI_2: "2", kVK_ANSI_3: "3",
        kVK_ANSI_4: "4", kVK_ANSI_5: "5", kVK_ANSI_6: "6", kVK_ANSI_7: "7",
        kVK_ANSI_8: "8", kVK_ANSI_9: "9",
        kVK_Space: "Space", kVK_Return: "↩", kVK_Tab: "⇥", kVK_Delete: "⌫",
        kVK_Escape: "⎋", kVK_ANSI_Minus: "-", kVK_ANSI_Equal: "=",
        kVK_ANSI_LeftBracket: "[", kVK_ANSI_RightBracket: "]",
        kVK_ANSI_Semicolon: ";", kVK_ANSI_Quote: "'", kVK_ANSI_Comma: ",",
        kVK_ANSI_Period: ".", kVK_ANSI_Slash: "/", kVK_ANSI_Backslash: "\\",
        kVK_ANSI_Grave: "`",
        kVK_LeftArrow: "←", kVK_RightArrow: "→", kVK_UpArrow: "↑", kVK_DownArrow: "↓",
        kVK_F1: "F1", kVK_F2: "F2", kVK_F3: "F3", kVK_F4: "F4", kVK_F5: "F5",
        kVK_F6: "F6", kVK_F7: "F7", kVK_F8: "F8", kVK_F9: "F9", kVK_F10: "F10",
        kVK_F11: "F11", kVK_F12: "F12",
    ]
}
