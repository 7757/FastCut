#!/bin/bash
# Build FastCut.app from the Swift sources using the command-line toolchain.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/FastCut.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RES="$CONTENTS/Resources"
BIN="$MACOS/FastCut"

echo "▶ Cleaning previous build"
rm -rf "$APP"
mkdir -p "$MACOS" "$RES"

echo "▶ Writing Info.plist"
cat > "$CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>FastCut</string>
    <key>CFBundleDisplayName</key>     <string>FastCut</string>
    <key>CFBundleIdentifier</key>      <string>com.fastcut.clipboard</string>
    <key>CFBundleExecutable</key>      <string>FastCut</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>CFBundleShortVersionString</key> <string>1.0</string>
    <key>CFBundleVersion</key>         <string>1</string>
    <key>LSMinimumSystemVersion</key>  <string>14.0</string>
    <key>LSUIElement</key>             <true/>
    <key>NSHighResolutionCapable</key> <true/>
    <key>NSPrincipalClass</key>        <string>NSApplication</string>
    <key>CFBundleIconFile</key>        <string>AppIcon</string>
</dict>
</plist>
PLIST

echo "▶ Compiling Swift sources"
swiftc -O -swift-version 5 \
    -target arm64-apple-macos14.0 \
    -framework AppKit -framework SwiftUI -framework Carbon \
    -framework ServiceManagement -framework CryptoKit \
    "$ROOT"/Sources/*.swift \
    -o "$BIN"

echo "▶ Installing app icon"
if [ -f "$ROOT/Assets/AppIcon.icns" ]; then
    cp "$ROOT/Assets/AppIcon.icns" "$RES/AppIcon.icns"
    echo "  copied AppIcon.icns"
else
    echo "  (no Assets/AppIcon.icns found — skipping)"
fi

echo "▶ Code signing"
# Prefer a stable self-signed identity so macOS Accessibility permission
# survives rebuilds (its designated requirement is cert-based, not cdhash-based).
# Falls back to ad-hoc if the identity isn't present.
SIGN_ID="FastCut Self Signed"
SIGN_KC="$HOME/Library/Keychains/fastcut-signing.keychain-db"
if [ -f "$SIGN_KC" ] && security find-certificate -c "$SIGN_ID" "$SIGN_KC" >/dev/null 2>&1; then
    security unlock-keychain -p fastcutsign "$SIGN_KC" 2>/dev/null || true
    if codesign --force --deep --sign "$SIGN_ID" --keychain "$SIGN_KC" "$APP" 2>/dev/null; then
        echo "  signed with stable identity: $SIGN_ID"
    else
        echo "  stable signing failed → ad-hoc fallback"
        codesign --force --deep --sign - "$APP" 2>/dev/null || true
    fi
else
    echo "  stable identity not found → ad-hoc (Accessibility perm resets on each rebuild)"
    codesign --force --deep --sign - "$APP" 2>/dev/null || true
fi

echo "✓ Built $APP"
