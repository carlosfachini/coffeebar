#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEMPLATE="$ROOT/homebrew/Casks/coffeebar.rb.template"
VERSION=${1:-}
SHA256=${2:-}

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Usage: $0 <version> <sha256>" >&2
  exit 1
fi

if [[ ! "$SHA256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "Invalid SHA-256" >&2
  exit 1
fi

sed \
  -e "s/__VERSION__/$VERSION/g" \
  -e "s/__SHA256__/$SHA256/g" \
  "$TEMPLATE"

