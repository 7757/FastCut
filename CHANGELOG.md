# Changelog

All notable changes to FastCut are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [1.0.2] — 2026-07-06

### Added
- Press **⌘1–⌘9** in the popup to instantly paste the 1st–9th item without moving the selection.

## [1.0.1] — 2026-07-06

### Changed
- Update check now reads the latest version from GitHub's `releases/latest` **redirect** instead of the REST API, so it is no longer subject to the unauthenticated API rate limit (which could cause a false "cannot connect to GitHub" error).

### Fixed
- The "Check for Updates" failure dialog no longer dead-ends — it now offers a **"前往下载页"** button that opens the official download page.

## [1.0.0] — 2026-07-06

### Added
- Initial release — a native menu-bar clipboard-history manager for macOS.
- Global hotkey (default **⌘⇧V**, configurable) to open a searchable history popup.
- Capture of text, images, and copied file paths; type-aware row icons (link, email, file, color, number).
- Keyboard-driven: `↑`/`↓` select, `↩` paste, `⌘⇧⌫` delete, `⎋` close.
- Auto-paste into the previously active app (Accessibility).
- Privacy: ignores entries marked concealed/transient by password managers.
- Persistent history, configurable size, launch at login.
- In-app update checking with a menu-bar notification.
- One-line installer, Homebrew cask, and a landing page.

[1.0.2]: https://github.com/7757/FastCut/releases/tag/v1.0.2
[1.0.1]: https://github.com/7757/FastCut/releases/tag/v1.0.1
[1.0.0]: https://github.com/7757/FastCut/releases/tag/v1.0.0
