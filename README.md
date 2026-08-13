# CoffeeBar

<p align="center">
  <img src="docs/coffeebar-icon.png" alt="CoffeeBar app icon" width="144" />
</p>

<p align="center"><strong>Keep your Mac awake while your work is running.</strong></p>

<p align="center">
  <a href="https://github.com/carlosfachini/coffeebar/releases/latest"><img src="https://img.shields.io/github/v/release/carlosfachini/coffeebar?style=flat-square" alt="Latest release" /></a>
  <img src="https://img.shields.io/badge/macOS-14%2B-111111?style=flat-square" alt="macOS 14 or later" />
  <a href="https://github.com/carlosfachini/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-carlosfachini%2Ftap-fbb040?style=flat-square" alt="Homebrew tap" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="MIT License" /></a>
</p>

CoffeeBar is a small, native macOS menu bar app that prevents idle system sleep while long-running work finishes. It uses Apple's native activity API, has no accounts or telemetry, and does not change power settings permanently.

<p align="center">
  <img src="docs/coffeebar.png" alt="CoffeeBar menu showing Keep Mac Awake and Launch at Login controls" width="420" />
</p>

## Features

- Native SwiftUI menu bar app with no permanent Dock icon.
- Manual **Keep Mac Awake** switch.
- Clear active/inactive status and menu bar badge.
- Prevents idle system sleep while still allowing display sleep and screen locking.
- Real application in `/Applications`, with a Finder and Launchpad icon.
- Optional **Launch at Login**, disabled by default.
- Daily, privacy-preserving GitHub version check.
- Universal release for Apple Silicon and Intel Macs.
- Zero telemetry and no external runtime dependencies.

## Requirements

- macOS 14 Sonoma or later.
- Homebrew for terminal installation.

## Install

### Homebrew

```bash
brew install --cask carlosfachini/tap/coffeebar
```

Homebrew installs `CoffeeBar.app` in `/Applications`. Installation does not launch the app automatically. Open CoffeeBar from Finder, Launchpad, or Spotlight when ready.

### GitHub Releases

Download the latest universal ZIP from [GitHub Releases](https://github.com/carlosfachini/coffeebar/releases/latest), extract it, and move `CoffeeBar.app` to `/Applications`.

## First launch on macOS

CoffeeBar does not use a paid Apple Developer account, so its releases cannot be notarized. Gatekeeper may block the first launch even though the app is open source and its release checksum is published.

To approve the official build:

1. Open CoffeeBar once from `/Applications`.
2. When macOS blocks it, open **System Settings**.
3. Go to **Privacy & Security**.
4. Scroll to the CoffeeBar message and click **Open Anyway**.
5. Confirm **Open**.

Only override Gatekeeper for a build downloaded from this repository or installed through the official `carlosfachini/tap` Cask.

## Usage

1. Open CoffeeBar.
2. Click the cup in the menu bar.
3. Enable **Keep Mac Awake** while work is running.
4. Disable it when normal idle sleep should resume.

The active panel shows **Active — idle sleep is blocked**, and the menu bar cup gains a small badge. CoffeeBar always starts with Keep Awake inactive.

### Reopen CoffeeBar

Choosing **Quit CoffeeBar** removes its menu bar item. Reopen `/Applications/CoffeeBar.app` from Finder, Launchpad, or Spotlight to restore it.

### Launch at Login

Enable **Launch at Login** in the CoffeeBar panel if the app should return after signing in or restarting the Mac. This option is disabled by default and can be changed at any time.

## Updates

CoffeeBar checks the public latest-release endpoint at most once every 24 hours. When a newer version exists, the panel shows a link to its release notes. The check sends no account or usage information and failure never affects Keep Awake.

Upgrade a Homebrew installation with:

```bash
brew update
brew upgrade --cask carlosfachini/tap/coffeebar
```

CoffeeBar intentionally does not include an automatic updater.

## How it works

```text
MenuBarExtra
  -> AppState
  -> SleepManager
  -> ProcessInfo.beginActivity(.idleSystemSleepDisabled)
```

The activity exists only while Keep Awake is enabled. CoffeeBar ends it when the switch is disabled or the app terminates. Display sleep, screen locking, and manual sleep remain available.

Supporting services are isolated from the sleep state:

```text
LaunchAtLoginManager -> SMAppService.mainApp
UpdateChecker        -> GitHub Releases API, cached for 24 hours
```

## Privacy and security

- No analytics or telemetry.
- No accounts, login, cookies, or API keys.
- No background server.
- No shell commands used by the running app.
- No permanent changes to macOS power settings.
- One optional public GitHub request per day for version information.
- Release ZIPs are ad-hoc signed and published with SHA-256 digests.
- Homebrew verifies the exact release SHA-256 before installation.

## Development

### Prerequisites

- macOS 14 or later.
- Xcode 26 or a compatible later version.

### Open the project

```bash
git clone https://github.com/carlosfachini/coffeebar.git
cd coffeebar
open CoffeeBar/CoffeeBar.xcodeproj
```

Select the `CoffeeBar` scheme and run the **My Mac** destination.

### Test from Terminal

```bash
xcodebuild test \
  -project CoffeeBar/CoffeeBar.xcodeproj \
  -scheme CoffeeBar \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/CoffeeBarDerivedData \
  CODE_SIGNING_ALLOWED=NO
```

### Project structure

```text
CoffeeBar/
├── CoffeeBar/
│   ├── App/                 # Application entry point and lifecycle
│   ├── Features/MenuBar/    # Menu bar panel
│   ├── Models/              # UI state
│   ├── Services/            # Sleep, login item, and update services
│   └── Assets.xcassets/     # App icon and colors
└── CoffeeBarTests/          # Unit tests

.github/workflows/           # CI and tagged releases
homebrew/Casks/              # Cask template
scripts/                     # Version, package, and Cask tooling
docs/                        # Screenshots and distribution design
```

## Releases

Releases follow semantic versioning. Pushing a matching tag such as `v0.1.0` runs tests, builds an ad-hoc-signed universal app, validates both CPU architectures, generates a SHA-256 digest, and publishes the artifacts to GitHub Releases.

See [RELEASING.md](RELEASING.md) for the maintainer workflow and [distribution design](docs/DISTRIBUTION_DESIGN.md) for architectural decisions.

## Uninstall

```bash
brew uninstall --cask carlosfachini/tap/coffeebar
```

Remove app preferences and caches too:

```bash
brew uninstall --cask --zap carlosfachini/tap/coffeebar
```

If Launch at Login was enabled, disable it in CoffeeBar before uninstalling.

## Troubleshooting

### The cup disappeared

CoffeeBar was likely quit. Open `/Applications/CoffeeBar.app` again.

### macOS says the developer cannot be verified

Follow the [first-launch steps](#first-launch-on-macos). This is expected because CoffeeBar is not notarized.

### Keep Awake is on but the Mac display turns off

Expected behavior. CoffeeBar blocks idle **system** sleep, not display sleep or screen locking.

### No update notice appears

The check is cached for 24 hours and fails silently when GitHub is unavailable. Homebrew can always check directly with `brew outdated --cask`.

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Keep changes native, small, private by default, and covered by tests.

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## License

[MIT](LICENSE) © 2026 Carlos Fachini
