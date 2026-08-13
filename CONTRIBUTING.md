# Contributing

Thanks for helping improve CoffeeBar.

## Development requirements

- macOS 14 or later.
- Xcode 26 or a compatible later version.

## Open the project

```bash
git clone https://github.com/carlosfachini/coffeebar.git
cd coffeebar
open CoffeeBar/CoffeeBar.xcodeproj
```

Select the `CoffeeBar` scheme and run the **My Mac** destination.

## Run tests

```bash
xcodebuild test \
  -project CoffeeBar/CoffeeBar.xcodeproj \
  -scheme CoffeeBar \
  -destination 'platform=macOS' \
  -derivedDataPath /tmp/CoffeeBarDerivedData \
  CODE_SIGNING_ALLOWED=NO
```

## Project structure

```text
CoffeeBar/
├── CoffeeBar/
│   ├── App/                 # Application entry point and lifecycle
│   ├── Features/MenuBar/    # Menu bar panel
│   ├── Models/              # UI state
│   ├── Services/            # Sleep, login item, and update services
│   └── Assets.xcassets/     # App icon and colors
└── CoffeeBarTests/          # Unit tests
```

Distribution architecture is documented in [docs/DISTRIBUTION_DESIGN.md](docs/DISTRIBUTION_DESIGN.md). Maintainer release instructions are in [RELEASING.md](RELEASING.md).

## Principles

Always:

- Keep code simple.
- Prefer native APIs.
- Avoid unnecessary dependencies.
- Follow Swift conventions.
- Separate UI from services.
- Add or update tests for behavioral changes.

Never:

- Use Electron.
- Add Node.js as an application dependency.
- Execute shell commands when native APIs exist.
