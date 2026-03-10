#!/bin/bash
# .claude/hooks/permission-guard.sh
# 三级权限审批：白名单自动批准 → 黑名单自动拒绝 → 其他交给用户
# 用于 PermissionRequest hook

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# ── 辅助函数 ──────────────────────────────────

allow() {
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PermissionRequest",
      decision: { behavior: "allow" }
    }
  }'
  exit 0
}

deny() {
  local msg="$1"
  jq -n --arg msg "$msg" '{
    hookSpecificOutput: {
      hookEventName: "PermissionRequest",
      decision: {
        behavior: "deny",
        message: $msg
      }
    }
  }'
  exit 0
}

# 不输出任何 JSON，Claude Code 会弹出权限对话框让用户决定
pass_through() {
  exit 0
}

# ══════════════════════════════════════════════
# 1) 工具白名单：已知安全的非 Bash 工具自动批准
# ══════════════════════════════════════════════
case "$TOOL_NAME" in
  Read|Glob|Grep|Edit|Write|WebSearch|WebFetch|Task|NotebookEdit)
    allow
    ;;
  mcp__context7__*)
    allow
    ;;
esac

# ══════════════════════════════════════════════
# 2) Bash 命令：黑名单 → 白名单 → 用户审核
# ══════════════════════════════════════════════
if [ "$TOOL_NAME" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

  # ── 2a) 黑名单：危险命令自动拒绝 ──────────────
  DANGEROUS_PATTERNS=(
    'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|--force\s+)*(\/|~|\$HOME|\*)'
    'rm\s+-[a-zA-Z]*r[a-zA-Z]*f'
    'git\s+push\s+.*(-f|--force)'
    'git\s+reset\s+--hard'
    'git\s+clean\s+-[a-zA-Z]*f'
    'git\s+checkout\s+\.'
    'git\s+restore\s+\.'
    'chmod\s+777'
    'mkfs\.'
    'dd\s+if='
    ':\(\)\s*\{.*\|.*&\s*\}\s*;'
    'sudo\s+(rm|shutdown|reboot|mkfs|dd|chmod)'
    '>\s*/dev/(sd|nvme|disk)'
    '(curl|wget)\s+.*\|\s*(ba)?sh'
    '\bshutdown\b'
    '\breboot\b'
    '\binit\s+0\b'
    'mv\s+.*\s+/dev/null'
    'echo\s+.*>\s*/etc/'
  )

  for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qEi "$pattern"; then
      deny "Dangerous command blocked: matches '$pattern'"
    fi
  done

  # ── 2b) 白名单：安全命令自动批准 ──────────────
  # 提取命令的第一个词（处理管道链中的首个命令）
  FIRST_CMD=$(echo "$COMMAND" | sed 's/^\s*//' | awk '{print $1}' | sed 's|.*/||')

  SAFE_COMMANDS=(
    ls pwd cat head tail wc file stat du df
    echo printf test true false
    grep rg find fd which type whereis
    tree sort uniq diff comm xargs tee date env
    git npm pnpm npx yarn
    node python python3 tsx ts-node
    eslint prettier tsc vue-tsc webpack vite turbo
    docker docker-compose podman
    mkdir touch cp mv chmod tar zip unzip
    lsof ps pgrep pkill kill
    curl wget ssh scp
  )

  for safe in "${SAFE_COMMANDS[@]}"; do
    if [ "$FIRST_CMD" = "$safe" ]; then
      allow
    fi
  done

  # ── 2c) 其他 Bash 命令：交给用户审核 ─────────
  pass_through
fi

# ══════════════════════════════════════════════
# 3) 未知工具：交给用户审核
# ══════════════════════════════════════════════
pass_through
