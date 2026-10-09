# Changelog

All notable CoffeeBar changes are documented in this file.

## 0.2.0

### Added

- Auto-off for Keep Awake sessions: 30 minutes by default, 1 hour, or manual disable.

## 0.1.0

### Added

- Native macOS menu bar application built with SwiftUI `MenuBarExtra`.
- Manual **Keep Mac Awake** toggle, inactive on every launch.
- Idle system sleep prevention through `ProcessInfo.beginActivity` with `.idleSystemSleepDisabled`.
- Idempotent sleep activity lifecycle managed by `SleepManager`.
- Distinct inactive and active SF Symbols in the menu bar.
- Bundle-derived version display and native Quit action.
- Cleanup of active sleep prevention before application termination.
- Native Launch at Login control, disabled by default.
- Cached GitHub Releases check with an informational update notice.
- Finder and Launchpad app icon.
- Homebrew Cask template and tagged GitHub Release automation.
- Universal release packaging with ad-hoc signing and SHA-256 verification.
- Public installation, Gatekeeper, maintenance and release documentation.

### Changed

- Configured CoffeeBar as an agent application without a permanent Dock icon.
- Set application marketing version to `0.1.0`.

### Distribution note

- Releases are not notarized because CoffeeBar does not use a paid Apple Developer account. First launch requires macOS **Privacy & Security > Open Anyway** approval.
