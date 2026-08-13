#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PROJECT="$ROOT/CoffeeBar/CoffeeBar.xcodeproj"
SCHEME="CoffeeBar"

if [[ -z "${DEVELOPER_DIR:-}" && -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

VERSION=$($ROOT/scripts/read-version.sh)
EXPECTED_TAG=${1:-"v$VERSION"}
RELEASE_ROOT="$ROOT/build/release"
ARCHIVE="$RELEASE_ROOT/CoffeeBar.xcarchive"
APP="$ARCHIVE/Products/Applications/CoffeeBar.app"
ARTIFACT_NAME="CoffeeBar-macos-universal-$VERSION.zip"
ARTIFACT="$RELEASE_ROOT/$ARTIFACT_NAME"

if [[ "$EXPECTED_TAG" != "v$VERSION" ]]; then
  echo "Tag $EXPECTED_TAG does not match project version v$VERSION" >&2
  exit 1
fi

rm -rf "$RELEASE_ROOT"
mkdir -p "$RELEASE_ROOT"

xcodebuild archive -quiet \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=macOS" \
  -archivePath "$ARCHIVE" \
  -derivedDataPath "$RELEASE_ROOT/DerivedData" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="-" \
  DEVELOPMENT_TEAM=""

if [[ ! -d "$APP" ]]; then
  echo "Archive did not contain CoffeeBar.app" >&2
  exit 1
fi

codesign --verify --deep --strict --verbose=2 "$APP"

ARCHITECTURES=$(lipo -archs "$APP/Contents/MacOS/CoffeeBar")
if [[ "$ARCHITECTURES" != *"arm64"* || "$ARCHITECTURES" != *"x86_64"* ]]; then
  echo "Expected arm64 and x86_64, found: $ARCHITECTURES" >&2
  exit 1
fi

/usr/bin/ditto --norsrc -c -k --keepParent "$APP" "$ARTIFACT"
shasum -a 256 "$ARTIFACT" > "$ARTIFACT.sha256"

printf 'Created %s\n' "$ARTIFACT"
printf 'Created %s\n' "$ARTIFACT.sha256"
