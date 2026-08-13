# Changelog

All notable CoffeeBar changes are documented in this file.

## 0.1.0

### Added

- Native macOS menu bar application built with SwiftUI `MenuBarExtra`.
- Manual **Keep Mac Awake** toggle, inactive on every launch.
- Idle system sleep prevention through `ProcessInfo.beginActivity` with `.idleSystemSleepDisabled`.
- Idempotent sleep activity lifecycle managed by `SleepManager`.
- Distinct inactive and active SF Symbols in the menu bar.
- Bundle-derived version display and native Quit action.
- Cleanup of active sleep prevention before application termination.

### Changed

- Configured CoffeeBar as an agent application without a permanent Dock icon.
- Set application marketing version to `0.1.0`.

### Pending configuration

- Official GitHub repository URL. The GitHub menu item remains disabled until a Git remote is configured.
