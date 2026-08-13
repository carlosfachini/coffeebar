#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PROJECT_FILE="$ROOT/CoffeeBar/CoffeeBar.xcodeproj/project.pbxproj"

VERSIONS=$(awk -F' = ' '/MARKETING_VERSION = / { gsub(/;/, "", $2); print $2 }' "$PROJECT_FILE" | sort -u)
VERSION_COUNT=$(printf '%s\n' "$VERSIONS" | awk 'NF { count += 1 } END { print count + 0 }')

if [[ "$VERSION_COUNT" -ne 1 ]]; then
  echo "Expected one MARKETING_VERSION, found: $VERSIONS" >&2
  exit 1
fi

printf '%s\n' "$VERSIONS"

