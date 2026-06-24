#!/usr/bin/env bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

input=$(cat)
last_message=$(printf '%s' "$input" | jq -r '.last_assistant_message // empty')
title="Codex"
message=${last_message:-"Turn completed"}

case "$(uname -s)" in
  Darwin*)
    /usr/bin/osascript \
      -e 'on run argv' \
      -e 'display notification (item 2 of argv) with title (item 1 of argv)' \
      -e 'end run' \
      "$title" "$message" >/dev/null 2>&1 || true
    ;;
esac

exit 0
