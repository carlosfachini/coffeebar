# CoffeeBar

## Vision

CoffeeBar is a native macOS menu bar application whose goal is to keep the Mac awake while long-running work is executing.

The application must remain lightweight, native and require no external dependencies.

It should feel like a first-party macOS utility.

---

## Principles

- Native macOS only
- SwiftUI
- No Electron
- No Node
- No Shell Wrappers
- Minimal Interface
- Menu Bar First
- Privacy First
- Zero Telemetry

---

## Current Scope

Current version focuses only on:

- Prevent Idle Sleep
- Menu Bar
- Native APIs

## Version 0.1 Architecture

CoffeeBar runs as an agent application with no main window or permanent Dock icon.

```text
MenuBarExtra
→ AppState
→ SleepManager
→ ProcessInfo
```

- `MenuBarExtra` owns the native menu bar interface.
- `AppState` exposes the current `isActive` state to SwiftUI.
- `SleepManager` owns the activity returned by `ProcessInfo` and makes activation and deactivation idempotent.
- `ApplicationDelegate` releases any active sleep assertion before termination.

### Version 0.1 Decisions

- Use SwiftUI `MenuBarExtra` instead of a custom `NSStatusItem`.
- Use `.idleSystemSleepDisabled` so display sleep and session locking remain available.
- Keep state in memory and start inactive on every launch.
- Use the official `https://github.com/carlosfachini/coffeebar` repository for public links and update metadata.
- Use no timers, subprocesses, external dependencies, analytics or telemetry.

## Version 0.1 Distribution

- Install `CoffeeBar.app` in `/Applications` through a Homebrew Cask.
- Keep a separate `carlosfachini/homebrew-tap` repository for the public Cask.
- Publish universal GitHub Release ZIPs with ad-hoc signing and SHA-256 digests.
- Document Gatekeeper's **Privacy & Security > Open Anyway** flow because no Apple Developer account is used.
- Offer native Launch at Login through `SMAppService`, disabled by default.
- Check GitHub Releases at most once per day and show an informational update link.
- Keep upgrades under Homebrew or manual Release control; do not add an automatic updater.

Future versions may include:

- Smart Mode
- Process Detection
- AI Agent Monitoring

---

## Technologies

Swift

SwiftUI

MenuBarExtra

ProcessInfo

---

## Non Goals

Do not implement:

- Analytics
- Cloud Sync
- Login
- Accounts
- Background servers
- Auto Updates
- External dependencies

unless explicitly requested.

---

## Philosophy

Every feature must make the application feel like a native Apple utility.

Avoid feature bloat.

Prefer simplicity over flexibility.

The application should solve one problem extremely well.
