#!/bin/bash
# .claude/hooks/permission-guard.sh
# 三级权限审批:黑名单自动拒绝 → 白名单自动批准 → 其他交给用户
# 注册为 PreToolUse hook,输出 permissionDecision(allow/deny/ask)。
#
# 重要:Claude Code 的权限决策走 PreToolUse + hookSpecificOutput.permissionDecision。
#   - allow: 自动批准,不弹窗
#   - deny:  自动拒绝
#   - ask:   走正常权限流程(弹窗让用户决定)

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# ── 辅助函数:输出 PreToolUse 决策 ──────────────

allow() {
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow"
    }
  }'
  exit 0
}

deny() {
  local msg="$1"
  jq -n --arg msg "$msg" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $msg
    }
  }'
  exit 0
}

# 转人工审核:显式 ask,走正常权限弹窗
ask() {
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask"
    }
  }'
  exit 0
}

# ══════════════════════════════════════════════
# 1) 工具白名单:已知安全的非 Bash 工具自动批准
# ══════════════════════════════════════════════
case "$TOOL_NAME" in
  Read|Glob|Grep|Edit|Write|WebSearch|WebFetch|Task|NotebookEdit|TodoWrite)
    allow
    ;;
  mcp__context7__*)
    allow
    ;;
esac

# ══════════════════════════════════════════════
# 2) Bash 命令:黑名单 → 白名单 → 用户审核
# ══════════════════════════════════════════════
if [ "$TOOL_NAME" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

  # ── 2a) 黑名单:危险命令自动拒绝(全命令正则扫描) ──
  DANGEROUS_PATTERNS=(
    # rm 作用于根级目标(/ ~ $HOME 裸* /*),目标后须紧跟空白/行尾,
    # 因此 `rm -rf /` 命中而 `rm -rf /tmp/x` 放行
    'rm\s+(-[a-zA-Z]+\s+|--[a-z-]+\s+)*(/\*|~/\*|/|~|\$HOME|\*)(\s|$)'
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

  # ── 2b) 白名单:复合命令逐段校验,全部命中才放行 ──
  SAFE_COMMANDS=(
    # 文件/查看
    ls pwd cat head tail wc file stat du df tree
    # shell 内建/文本处理
    echo printf test true false cd export
    sed awk cut sort uniq comm tr basename dirname
    grep rg find fd which type whereis xargs tee read
    # 时间/环境
    date env sleep
    # 版本控制/包管理
    git npm pnpm npx yarn jq
    # 运行时/工具链
    node python python3 tsx ts-node
    eslint prettier tsc vue-tsc oxlint webpack vite turbo
    go goimports cargo rustc
    # nix / 本仓库高频
    nix darwin-rebuild home-manager brew
    # 容器
    docker docker-compose podman
    # 文件操作(非破坏性变体由黑名单兜底)
    mkdir touch cp mv chmod ln tar zip unzip gzip gunzip
    # 进程/网络(危险变体由黑名单兜底)
    lsof ps pgrep pkill kill
    curl wget ssh scp rsync
  )

  # 判断单个词是否在白名单中
  is_safe() {
    local word="$1"
    local s
    for s in "${SAFE_COMMANDS[@]}"; do
      [ "$word" = "$s" ] && return 0
    done
    return 1
  }

  # 按 && || | ; 拆分复合命令,逐段提取首个有效命令词校验。
  # 任意一段不在白名单 → 转人工审核(ask)。
  # 用换行替换分隔符,便于逐行处理。
  SEGMENTS=$(echo "$COMMAND" | sed -E 's/\|\||&&|[|;]/\n/g')

  all_safe=1
  has_segment=0
  while IFS= read -r segment; do
    # 去掉首尾空白
    segment="$(echo "$segment" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [ -z "$segment" ] && continue
    has_segment=1

    # 剥离前导环境变量赋值(FOO=bar BAZ=qux cmd ...)
    # 逐词跳过形如 NAME=value 的 token
    first_word=""
    for token in $segment; do
      case "$token" in
        *=*)
          # 形如 KEY=VALUE 的环境变量赋值,跳过
          case "$token" in
            [A-Za-z_]*=*) continue ;;
          esac
          ;;
      esac
      first_word="$token"
      break
    done

    # 去掉路径前缀(/usr/bin/node → node)
    first_word="$(echo "$first_word" | sed 's|.*/||')"

    if [ -z "$first_word" ] || ! is_safe "$first_word"; then
      all_safe=0
      break
    fi
  done <<< "$SEGMENTS"

  if [ "$has_segment" = "1" ] && [ "$all_safe" = "1" ]; then
    allow
  fi

  # ── 2c) 其他 Bash 命令:交给用户审核 ─────────
  ask
fi

# ══════════════════════════════════════════════
# 3) 未知工具:交给用户审核
# ══════════════════════════════════════════════
ask
