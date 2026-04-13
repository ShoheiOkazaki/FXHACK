#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

HUGO_BIN="${HUGO_BIN:-hugo}"

if ! command -v "$HUGO_BIN" >/dev/null 2>&1; then
  echo "Hugo was not found. Set HUGO_BIN or install Hugo." >&2
  exit 1
fi

HUGO_ENVIRONMENT=production \
HUGO_ENV=production \
"$HUGO_BIN" --gc --minify "$@"
