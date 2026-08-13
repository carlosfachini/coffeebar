# CoffeeBar Distribution Design

## Understanding summary

- CoffeeBar is a lightweight native macOS menu bar app that prevents idle system sleep.
- The app is distributed as `CoffeeBar.app`, installed in `/Applications`, and remains available from Finder and Launchpad after it leaves the menu bar.
- Homebrew installation uses a separate `carlosfachini/homebrew-tap` repository.
- Releases are built from semantic-version tags such as `v0.1.0` and published through GitHub Releases.
- The project has no Apple Developer Program membership, so releases use ad-hoc code signing and require the documented Gatekeeper override on first launch.
- Launch at Login is optional, uses the native Service Management API, and is disabled by default.
- Update checks are informational. Homebrew remains responsible for installing upgrades.

## Assumptions

- Minimum supported system: macOS 14 Sonoma.
- Release binaries are universal (`arm64` and `x86_64`).
- The app checks GitHub Releases no more than once every 24 hours unless a manual check is requested.
- GitHub version-check failures never affect Keep Awake.
- No analytics, telemetry, accounts, cloud sync, Sparkle, or background server is introduced.
- A SHA-256 digest protects each release archive and is pinned in the Homebrew Cask.

## Architecture

```text
Git tag vX.Y.Z
  -> GitHub Actions tests
  -> universal Release archive
  -> ad-hoc code signature verification
  -> CoffeeBar-macos-universal-X.Y.Z.zip
  -> SHA-256
  -> GitHub Release
  -> Homebrew Cask update
```

```text
CoffeeBarApp
|- AppState
|- SleepManager
|- LaunchAtLoginManager
`- UpdateChecker
```

`LaunchAtLoginManager` wraps `SMAppService.mainApp`. `UpdateChecker` reads the public latest-release endpoint, compares semantic versions, and caches the last attempt. Both services fail closed without changing the sleep assertion.

## Error handling

- An unavailable GitHub API produces no false update notice.
- An invalid or missing release version is ignored.
- A Launch at Login registration failure returns the toggle to its actual system state and shows a short local error.
- A release stops before publication when tests, architecture validation, signature validation, or tag/version validation fails.

## Testing strategy

- Unit tests cover app state, semantic-version comparison, update caching, update availability, and Launch at Login state changes.
- CI runs macOS unit tests and a Release build.
- Release packaging verifies both architectures with `lipo` and verifies the ad-hoc signature with `codesign`.
- Manual release QA covers Homebrew installation, Gatekeeper override, reopen from `/Applications`, menu-bar behavior, and login-item behavior.

## Decision log

| Decision | Alternatives | Reason |
| --- | --- | --- |
| Separate `homebrew-tap` repository | Store a Cask only in the app repository | Standard `owner/tap/name` Homebrew workflow and independent Cask history. |
| Informational update check | Sparkle auto-update | Smaller dependency surface and clearer unsigned-app behavior. |
| Ad-hoc signing | Developer ID and notarization | No paid Apple Developer account will be used. |
| Launch at Login off by default | Register automatically | Explicit user control and no surprise persistence. |
| Install but do not auto-launch | Launch immediately after Homebrew install | Matches Homebrew behavior and lets the user perform Gatekeeper approval intentionally. |

