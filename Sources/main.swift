import AppKit

// FastCut — a lightweight macOS clipboard-history manager.
// Entry point: run as an accessory (menu-bar only) app.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)   // no Dock icon; lives in the menu bar
app.run()
