#!/usr/bin/env bash
#
# herdr-cycle-agent.sh — 在 herdr 的 agent panes 之间循环切换焦点。
#
# 用法:
#   herdr-cycle-agent.sh next   # 切换到下一个 agent pane(默认)
#   herdr-cycle-agent.sh prev   # 切换到上一个 agent pane
#
# 行为:
#   - 读取 `herdr agent list` 的 JSON 输出,按其顺序构成一个 agent 环。
#   - 若存在 focused pane,则切换到它的下一个/上一个(首尾循环)。
#   - 若没有 focused pane,则聚焦第一个 agent pane。
#   - 若没有任何 agent pane,则静默退出(返回码 0),不打扰调用方(如快捷键)。
#
# 依赖: herdr、jq

set -euo pipefail

direction="${1:-next}"
case "$direction" in
  next | prev) ;;
  *)
    echo "usage: $(basename "$0") [next|prev]" >&2
    exit 2
    ;;
esac

if ! command -v herdr >/dev/null 2>&1; then
  echo "herdr-cycle-agent: 'herdr' not found in PATH" >&2
  exit 127
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "herdr-cycle-agent: 'jq' not found in PATH" >&2
  exit 127
fi

# 拉取 agent 列表。命令失败(如 herdr 未运行)时视为无 agent,静默退出。
list_json="$(herdr agent list 2>/dev/null)" || exit 0

# 用 jq 计算目标 pane_id(herdr 0.8+ 的 `agent focus` 接受 pane_id,
# 不再接受 terminal_id,传 term_* 会返回 agent_not_found)。
#   - agents 为空 -> 输出空串(调用方据此静默退出)
#   - 没有 focused pane -> 一律选第一个(与方向无关,符合需求)
#   - 有 focused pane -> next: (idx + 1) % n ;prev: (idx - 1 + n) % n(首尾循环)
target="$(
  jq -r --arg dir "$direction" '
    (.result.agents // []) as $a
    | ($a | length) as $n
    | if $n == 0 then ""
      else
        ( [ $a[] | .focused == true ] | index(true) ) as $f
        | (if $f == null then
             0
           elif $dir == "next" then
             ($f + 1) % $n
           else
             ($f - 1 + $n) % $n
           end) as $t
        | $a[$t].pane_id
      end
  ' <<<"$list_json"
)"

# 没有可切换的 agent pane,静默退出。
[ -n "$target" ] || exit 0

# 执行切换。成功时 herdr 会把 agent JSON 打到 stdout —— 从快捷键触发时属于噪音,
# 故丢弃 stdout;失败信息(stderr)保留,并透传其返回码。
herdr agent focus "$target" >/dev/null
