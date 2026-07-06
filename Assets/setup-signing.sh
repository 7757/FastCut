#!/bin/bash
# Optional — create a STABLE self-signed code-signing identity so that macOS keeps
# granting FastCut its Accessibility permission across rebuilds.
#
# Why: an ad-hoc signature's identity (cdhash) changes on every build, so macOS
# treats each rebuild as a "new" app and makes you re-grant Accessibility every
# time. A fixed self-signed certificate gives the app a stable designated
# requirement (`identifier "com.fastcut.clipboard" and certificate root = …`),
# so you grant Accessibility once and it sticks forever.
#
# Run this ONCE. Afterwards ./build.sh auto-detects and signs with it.
# The certificate has no security value — it only provides a stable code identity.
set -euo pipefail

IDENTITY="FastCut Self Signed"
KC_NAME="fastcut-signing.keychain"
KC_PATH="$HOME/Library/Keychains/${KC_NAME}-db"
PW="fastcutsign"

if [ -f "$KC_PATH" ] && security find-certificate -c "$IDENTITY" "$KC_NAME" >/dev/null 2>&1; then
  echo "Signing identity '$IDENTITY' already exists — nothing to do."
  exit 0
fi

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT; cd "$WORK"

cat > cert.cnf <<'CNF'
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no
[dn]
CN = FastCut Self Signed
O = FastCut Local
[v3]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
CNF

openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 3650 -nodes -config cert.cnf
openssl pkcs12 -export -inkey key.pem -in cert.pem -out identity.p12 -passout pass:"$PW" -name "$IDENTITY"

security create-keychain -p "$PW" "$KC_NAME" 2>/dev/null || true
security set-keychain-settings "$KC_NAME"
security unlock-keychain -p "$PW" "$KC_NAME"
security import identity.p12 -k "$KC_NAME" -P "$PW" -T /usr/bin/codesign -A
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$PW" "$KC_NAME" >/dev/null

# Add to the user's keychain search list so codesign can find it.
OLD=$(security list-keychains -d user | sed 's/[">]//g' | xargs)
security list-keychains -d user -s "$KC_NAME" $OLD >/dev/null

echo "Created signing identity '$IDENTITY' in $KC_PATH"
echo "Now run ./build.sh — it will sign with this identity automatically."
