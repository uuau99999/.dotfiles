#!/usr/bin/env bash
# session-handoff.sh — SessionEnd hook
# 在 session 结束时收集会话日志、git 提交记录和上次 HANDOFF，
# 调用 Claude CLI 生成新的 .claude/HANDOFF.md

set -euo pipefail

# --- 读取 stdin ---
INPUT=$(cat)

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)

# 没有 cwd 就没法写文件，静默退出
if [ -z "$CWD" ]; then
  exit 0
fi

HANDOFF_FILE="$CWD/.claude/HANDOFF.md"

# --- 找到 claude CLI ---
CLAUDE_BIN=""
for candidate in "claude" "$HOME/.local/bin/claude"; do
  if command -v "$candidate" &>/dev/null || [ -x "$candidate" ]; then
    CLAUDE_BIN="$candidate"
    break
  fi
done

if [ -z "$CLAUDE_BIN" ]; then
  # 没有 claude CLI，静默退出
  exit 0
fi

# --- 收集数据源 ---

# 1. 会话日志（最后 200 行有意义的对话）
TRANSCRIPT=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ] && command -v jq &>/dev/null; then
  TRANSCRIPT=$(tail -500 "$TRANSCRIPT_PATH" | jq -r '
    if .type == "user" then
      "USER: " + ((.message.content // "") | if type == "array" then map(select(.type == "text") | .text) | join(" ") else . end)
    elif .type == "assistant" then
      "ASSISTANT: " + ((.message.content // []) | map(select(.type == "text") | .text) | join("\n"))
    else empty
    end
  ' 2>/dev/null | grep -v "^ASSISTANT: $" | tail -200 || true)
fi

# 2. Git 提交记录（最近 8 小时）
GIT_LOG=""
if git -C "$CWD" rev-parse --is-inside-work-tree &>/dev/null; then
  GIT_LOG=$(git -C "$CWD" log --oneline -20 --since="8 hours ago" 2>/dev/null || true)
  GIT_DIFF_STAT=$(git -C "$CWD" diff --stat HEAD~5..HEAD 2>/dev/null | tail -20 || true)
  if [ -n "$GIT_DIFF_STAT" ]; then
    GIT_LOG="${GIT_LOG}

Diff stat (last 5 commits):
${GIT_DIFF_STAT}"
  fi
fi

# 3. 上次 HANDOFF
PREV_HANDOFF=""
if [ -f "$HANDOFF_FILE" ]; then
  PREV_HANDOFF=$(cat "$HANDOFF_FILE")
fi

# --- 如果三个数据源都为空，跳过生成 ---
if [ -z "$TRANSCRIPT" ] && [ -z "$GIT_LOG" ] && [ -z "$PREV_HANDOFF" ]; then
  exit 0
fi

# --- 构造 prompt ---
PROMPT="你是一个项目工作交接文档生成器。请直接输出一份 Markdown 格式的 HANDOFF.md 文件内容。

重要：只输出 Markdown 文件本身的内容，不要输出任何解释、说明或元描述。

格式要求：
- 第一行：# Handoff
- 第二行空行
- 第三行：Last updated: $(date '+%Y-%m-%d %H:%M')
- 然后是以下章节（如果某章节无相关信息则省略）：
  1. ## 本次工作摘要（简要列出本次 session 完成的事项）
  2. ## 关键决策（重要的技术决策或架构选择）
  3. ## 未完成事项（需要下次继续的工作）
  4. ## 近期 Git 提交（列出提交记录）
- 使用中文
- 整个文件不超过 80 行

---

### 会话日志（最近的对话记录）:
${TRANSCRIPT:-（无会话日志）}

### Git 提交记录（最近 8 小时）:
${GIT_LOG:-（无 git 提交）}

### 上次 HANDOFF.md:
${PREV_HANDOFF:-（无历史 HANDOFF）}"

# --- 确保输出目录存在 ---
mkdir -p "$(dirname "$HANDOFF_FILE")"

# --- 调用 Claude CLI 生成 HANDOFF.md ---
# 使用 timeout 防止挂起，--print 只输出结果，--dangerously-skip-permissions 跳过权限检查
if OUTPUT=$(echo "$PROMPT" | timeout 90 "$CLAUDE_BIN" --print --dangerously-skip-permissions 2>/dev/null); then
  if [ -n "$OUTPUT" ]; then
    echo "$OUTPUT" > "$HANDOFF_FILE"
  fi
fi

exit 0
