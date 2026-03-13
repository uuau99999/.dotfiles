#!/bin/bash
# ~/.claude/hooks/post-edit-lint-smart.sh
# Smart PostToolUse hook: auto-detect eslint/prettier and run linting

set -euo pipefail

# Check required dependencies
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required but not installed. Install with: brew install jq"
  exit 1
fi

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only trigger on Edit or Write tools
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check JS/TS files
if [[ ! "$FILE_PATH" =~ \.(js|ts|jsx|tsx)$ ]]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Find project root (where package.json exists)
find_project_root() {
  local dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/package.json" ]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

# Check if tool is available in project
has_tool() {
  local tool=$1
  local project_root=$2

  # Check local node_modules
  if [ -x "$project_root/node_modules/.bin/$tool" ]; then
    return 0
  fi

  # Check if installed in package.json
  if [ -f "$project_root/package.json" ]; then
    if jq -e ".devDependencies.\"$tool\" // .dependencies.\"$tool\"" "$project_root/package.json" > /dev/null 2>&1; then
      return 0
    fi
  fi

  return 1
}

PROJECT_ROOT=$(find_project_root "$(dirname "$FILE_PATH")")
if [ -z "$PROJECT_ROOT" ]; then
  # No package.json found, skip linting
  exit 0
fi

ERRORS=""

# Ensure paths are absolute and calculate relative path correctly
FILE_PATH=$(realpath "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")
PROJECT_ROOT=$(realpath "$PROJECT_ROOT" 2>/dev/null || echo "$PROJECT_ROOT")

# Run ESLint if available
if has_tool "eslint" "$PROJECT_ROOT"; then
  # Calculate relative path safely
  if [[ "$FILE_PATH" == "$PROJECT_ROOT"/* ]]; then
    RELATIVE_PATH="${FILE_PATH#$PROJECT_ROOT/}"
  else
    # File is outside project root, use absolute path
    RELATIVE_PATH="$FILE_PATH"
  fi

  # Check if npx is available
  if ! command -v npx &> /dev/null; then
    ERRORS+="=== ESLint Error ===
npx command not found. Please install Node.js and npm.

"
  else
    # Try to auto-fix first
    (cd "$PROJECT_ROOT" && npx eslint --fix "$RELATIVE_PATH" 2>&1) || true

    # Check for remaining errors using exit code
    if ! (cd "$PROJECT_ROOT" && npx eslint "$RELATIVE_PATH" 2>&1 > /dev/null); then
      ESLINT_OUTPUT=$(cd "$PROJECT_ROOT" && npx eslint "$RELATIVE_PATH" 2>&1) || true
      CLEAN_OUTPUT=$(echo "$ESLINT_OUTPUT" | grep -v "^npm warn" | grep -v "^(node:" | grep -v "^Reparsing")
      if [ -n "$CLEAN_OUTPUT" ]; then
        ERRORS+="=== ESLint Errors ===
$CLEAN_OUTPUT

"
      fi
    fi
  fi
fi

# Run Prettier if available
if has_tool "prettier" "$PROJECT_ROOT"; then
  RELATIVE_PATH="${FILE_PATH#$PROJECT_ROOT/}"

  # Check if file needs formatting
  PRETTIER_CHECK=$(cd "$PROJECT_ROOT" && npx prettier --check "$RELATIVE_PATH" 2>&1) || true
  if echo "$PRETTIER_CHECK" | grep -q "Code style issues found"; then
    # Auto-format
    (cd "$PROJECT_ROOT" && npx prettier --write "$RELATIVE_PATH" 2>&1) || true

    # Verify formatting succeeded
    PRETTIER_VERIFY=$(cd "$PROJECT_ROOT" && npx prettier --check "$RELATIVE_PATH" 2>&1) || true
    if echo "$PRETTIER_VERIFY" | grep -q "Code style issues found"; then
      ERRORS+="=== Prettier Errors ===
Failed to format file: $RELATIVE_PATH

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
