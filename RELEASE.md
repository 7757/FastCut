# Release Checklist

Follow this **top to bottom** every time you cut a FastCut release. Do not skip steps — this
list exists so nothing is forgotten. It is kept in sync with the reusable playbook in Claude's
project memory (`app-release-playbook`).

Let **NEW** be the new version, e.g. `1.0.2`.

## 1. Code, version & changelog
- [ ] Land all changes for this release on `main`.
- [ ] Bump `CFBundleShortVersionString` in **`build.sh`** to `NEW`.
- [ ] Add a `## [NEW] — YYYY-MM-DD` entry to **`CHANGELOG.md`** (Added / Changed / Fixed) and the link reference at the bottom.
- [ ] Mirror the highlights into the website changelog: the `#changelog` list in **`docs/index.html`** AND its translations in **`docs/i18n.js`** (all of `en` / `zh` / `ja` / `ko`).

## 2. Build & verify
- [ ] `./build.sh` — signs with the stable **"FastCut Self Signed"** identity (run `Assets/setup-signing.sh` once if the keychain is missing; otherwise Accessibility permission resets every build).
- [ ] Confirm version: `/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' FastCut.app/Contents/Info.plist` → `NEW`.
- [ ] Smoke-launch and verify the actual change works.
- [ ] Reinstall locally: quit FastCut, `rm -rf /Applications/FastCut.app`, `cp -R FastCut.app /Applications/` (do **NOT** re-`codesign --sign -` — that re-ad-hoc's it), `open`.

## 3. Package — TWO assets, both names
- [ ] `ditto -c -k --keepParent FastCut.app /tmp/FastCut-NEW-macOS.zip`
- [ ] `cp /tmp/FastCut-NEW-macOS.zip /tmp/FastCut-macOS.zip`  ← **stable name**, required by `install.sh`
- [ ] `shasum -a 256 /tmp/FastCut-NEW-macOS.zip`  ← note the hash for the cask

## 4. GitHub release
- [ ] `gh release create vNEW /tmp/FastCut-NEW-macOS.zip /tmp/FastCut-macOS.zip --repo 7757/FastCut --target main --title "FastCut NEW" --notes "<CHANGELOG entry>"`
- [ ] Verify it is **Latest**: `gh release list --repo 7757/FastCut`.

## 5. Homebrew cask — repo `7757/homebrew-fastcut`
- [ ] In `Casks/fastcut.rb`, set `version "NEW"` and the new `sha256`.
- [ ] Commit + push the tap.

## 6. Publish docs / site
- [ ] Commit + push `main` (build.sh, CHANGELOG.md, docs/*).
- [ ] Confirm Pages rebuilt: `gh api repos/7757/FastCut/pages/builds/latest --jq .status` == `built`.

## 7. Sanity checks
- [ ] Latest redirect updated (CDN cache ~1 min): `curl -fsSL -o /dev/null -w '%{url_effective}\n' 'https://github.com/7757/FastCut/releases/latest?x=1'` → `vNEW`.
- [ ] Installer asset reachable: `curl -sIL -o /dev/null -w '%{http_code}\n' https://github.com/7757/FastCut/releases/latest/download/FastCut-macOS.zip` → `200`.
- [ ] (Optional) Run the installer end-to-end: `curl -fsSL https://7757.github.io/FastCut/install.sh | bash`.

## Always
- **All docs and release notes are in English.** The website marketing copy (`docs/`) is the only intentionally translated surface (en/zh/ja/ko); everything else — README (canonical), CHANGELOG, RELEASE, GitHub release notes, commit messages — is English.
- Commits are authored by **musk only** — never add a `Co-Authored-By: Claude` trailer.
- The app is self-signed (not notarized): the installer clears quarantine; manual `.app` downloads need right-click → Open on first launch.
- Keep the four language versions (README `*.md` and website `docs/i18n.js`) in sync when copy changes.
