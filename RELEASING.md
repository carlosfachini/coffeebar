# Releasing CoffeeBar

CoffeeBar releases are unsigned by an Apple Developer ID. They are ad-hoc signed, hashed, and published through GitHub Releases.

The public Homebrew tap lives at `carlosfachini/homebrew-tap`. It checks the
latest public CoffeeBar Release every six hours and updates its Cask using its
own scoped `GITHUB_TOKEN`; no personal access token is required.

## Prepare a release

1. Update `MARKETING_VERSION` in both CoffeeBar target configurations.
2. Increment `CURRENT_PROJECT_VERSION` in both CoffeeBar target configurations.
3. Move entries from the unreleased changelog into the new version section.
4. Run tests.
5. Commit the release preparation.
6. Create and push the matching tag:

   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

The Release workflow validates that the tag matches the project version, tests the app, builds a universal archive, applies an ad-hoc signature, verifies both CPU architectures, creates the ZIP and SHA-256 file, and publishes the GitHub Release.

The tap will discover the Release automatically. To update it immediately instead of waiting for the schedule:

```bash
gh workflow run update-cask.yml --repo carlosfachini/homebrew-tap
```

## Local package verification

```bash
scripts/package-release.sh v0.1.0
codesign --verify --deep --strict --verbose=2 \
  build/release/CoffeeBar.xcarchive/Products/Applications/CoffeeBar.app
shasum -a 256 -c build/release/CoffeeBar-macos-universal-0.1.0.zip.sha256
```

Render a Cask manually:

```bash
SHA=$(awk '{print $1}' build/release/CoffeeBar-macos-universal-0.1.0.zip.sha256)
scripts/render-cask.sh 0.1.0 "$SHA" > coffeebar.rb
```

## Public installation QA

```bash
brew install --cask carlosfachini/tap/coffeebar
```

Then verify:

- `CoffeeBar.app` exists in `/Applications` and has its icon.
- The first blocked launch can be approved at **System Settings > Privacy & Security > Open Anyway**.
- Opening the app restores the menu bar item.
- Keep Awake activates and deactivates.
- Launch at Login is off initially, can be enabled, and survives sign-out/sign-in.
- `brew upgrade --cask carlosfachini/tap/coffeebar` installs a later release.
