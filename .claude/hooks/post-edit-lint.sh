#!/bin/bash
# .claude/hooks/post-edit-lint.sh
# PostToolUse hook: after Edit/Write on .ts files,
# run ESLint --fix (auto-repair) + TypeScript check, block if errors remain.

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only trigger on Edit or Write tools
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check TypeScript files
if [[ "$FILE_PATH" != *.ts ]]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ERRORS=""

# Detect which package the file belongs to
PKG_DIR=""
PKG_NAME=""
if [[ "$FILE_PATH" == *"packages/api/"* ]]; then
  PKG_DIR="$PROJECT_DIR/packages/api"
  PKG_NAME="api"
elif [[ "$FILE_PATH" == *"packages/agent/"* ]]; then
  PKG_DIR="$PROJECT_DIR/packages/agent"
  PKG_NAME="agent"
fi

# Skip files not in a known package
if [ -z "$PKG_DIR" ]; then
  exit 0
fi

# 1. TypeScript check
TSC_BIN="$PKG_DIR/node_modules/.bin/tsc"
if [ -x "$TSC_BIN" ]; then
  TSC_OUTPUT=$("$TSC_BIN" --noEmit -p "$PKG_DIR/tsconfig.json" 2>&1) || true
  if [ -n "$TSC_OUTPUT" ]; then
    ERRORS+="=== TypeScript Errors ($PKG_NAME) ===
$TSC_OUTPUT
"
  fi
fi

# 2. ESLint --fix then check (only packages with eslint config)
ESLINT_CONFIG="$PKG_DIR/eslint.config.js"
if [ -f "$ESLINT_CONFIG" ]; then
  RELATIVE_PATH="${FILE_PATH#$PKG_DIR/}"

  # Auto-fix first
  (cd "$PKG_DIR" && npx eslint --fix "$RELATIVE_PATH" 2>&1) || true

  # Check for remaining errors
  ESLINT_OUTPUT=$(cd "$PKG_DIR" && npx eslint "$RELATIVE_PATH" 2>&1) || true
  if echo "$ESLINT_OUTPUT" | grep -qE "✖ [0-9]+ problem"; then
    CLEAN_OUTPUT=$(echo "$ESLINT_OUTPUT" | grep -v "^npm warn" | grep -v "^(node:" | grep -v "^Reparsing" | grep -v "^To eliminate" | grep -v "^(Use \`node")
    if [ -n "$CLEAN_OUTPUT" ]; then
      ERRORS+="=== ESLint Errors ($PKG_NAME) ===
$CLEAN_OUTPUT
"
    fi
  fi
fi

# If errors found, block and report
if [ -n "$ERRORS" ]; then
  jq -n --arg msg "$ERRORS" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      decision: {
        behavior: "block",
        message: $msg
      }
    }
  }'
  exit 0
fi

# No errors — pass through silently
exit 0
