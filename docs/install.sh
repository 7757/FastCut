#!/bin/bash
# FastCut one-line installer.
#   curl -fsSL https://7757.github.io/FastCut/install.sh | bash
# Downloads the latest release, installs to /Applications, and launches it.
set -euo pipefail

REPO="7757/FastCut"
APP="/Applications/FastCut.app"
BOLT="⚡"

echo "${BOLT}  Installing FastCut…"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# Stable asset name → no API call, no rate limits.
URL="https://github.com/${REPO}/releases/latest/download/FastCut-macOS.zip"
echo "↓ Downloading the latest release"
if ! curl -fL# "$URL" -o "$TMP/FastCut.zip"; then
  echo "✗ Download failed. Get it manually: https://github.com/${REPO}/releases"
  exit 1
fi

echo "→ Unpacking"
ditto -x -k "$TMP/FastCut.zip" "$TMP/unpack"
SRC="$(/usr/bin/find "$TMP/unpack" -maxdepth 2 -name 'FastCut.app' -print -quit)"
if [ -z "${SRC:-}" ]; then echo "✗ Archive did not contain FastCut.app"; exit 1; fi

echo "→ Quitting any running copy"
osascript -e 'quit app "FastCut"' 2>/dev/null || true
pkill -x FastCut 2>/dev/null || true
sleep 1

echo "→ Installing to ${APP}"
rm -rf "$APP"
ditto "$SRC" "$APP"
xattr -cr "$APP" 2>/dev/null || true   # clear any quarantine flag

echo "→ Launching"
open "$APP"

echo ""
echo "✅ FastCut is installed and running — look for the ${BOLT} in your menu bar."
echo "   Press ⌘⇧V to open your clipboard history."
echo "   For auto-paste: System Settings → Privacy & Security → Accessibility → enable FastCut."
