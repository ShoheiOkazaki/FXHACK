#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 3 ]]; then
  echo "Usage: $0 YYYY-MM-DD [ja_title] [en_title]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POST_DATE="$1"
JA_TITLE="${2:-}"
EN_TITLE="${3:-}"
POST_DIR="$ROOT_DIR/content/posts/$POST_DATE"
TIMESTAMP="$(date --iso-8601=seconds)"

if [[ -e "$POST_DIR" ]]; then
  echo "Post directory already exists: $POST_DIR" >&2
  exit 1
fi

mkdir -p "$POST_DIR"

cat >"$POST_DIR/index.ja.md" <<EOF
---
title: "$JA_TITLE"
date: $TIMESTAMP
draft: true
summary: ""
tags: []
---

EOF

cat >"$POST_DIR/index.en.md" <<EOF
---
title: "$EN_TITLE"
date: $TIMESTAMP
draft: true
summary: ""
tags: []
---

EOF

echo "Created:"
echo "  $POST_DIR/index.ja.md"
echo "  $POST_DIR/index.en.md"
