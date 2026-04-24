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
    /usr/bin/osascript <<OSA >/dev/null 2>&1 || true
display notification "${message//"/\"}" with title "$title"
OSA
    ;;
esac

exit 0
