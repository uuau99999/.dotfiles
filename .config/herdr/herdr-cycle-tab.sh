#!/usr/bin/env bash
#
# herdr-cycle-tab.sh — 在当前 workspace 内的各 tab 之间循环切换焦点。
#
# 用法:
#   herdr-cycle-tab.sh next   # 切换到下一个 tab(默认)
#   herdr-cycle-tab.sh prev   # 切换到上一个 tab
#
# 行为:
#   - 由 `herdr workspace list` 中 focused=true 的 workspace 确定"当前 workspace"
#     (即用户此刻聚焦的那个)。
#   - 读取 `herdr tab list --workspace <id>` 的 JSON,按其顺序构成一个 tab 环。
#   - 若存在 focused tab,则切换到它的下一个/上一个(首尾循环)。
#   - 若没有 focused tab,则聚焦该 workspace 的第一个 tab。
#   - 若无法确定当前 workspace,或该 workspace 无 tab,则静默退出(返回码 0),
#     不打扰调用方(如快捷键)。
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
  echo "herdr-cycle-tab: 'herdr' not found in PATH" >&2
  exit 127
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "herdr-cycle-tab: 'jq' not found in PATH" >&2
  exit 127
fi

# 确定当前 workspace:取 workspace list 中 focused=true 的那个,即用户此刻聚焦的
# workspace。注意不要用 `herdr pane current`——它返回的是调用命令的 pane 所在
# workspace(随调用点变化),而非全局焦点所在的 workspace。
# 命令失败(如 herdr 未运行)时静默退出。
workspaces_json="$(herdr workspace list 2>/dev/null)" || exit 0
workspace_id="$(
  jq -r '(.result.workspaces // []) | map(select(.focused == true)) | .[0].workspace_id // empty' \
    <<<"$workspaces_json"
)"
[ -n "$workspace_id" ] || exit 0

# 拉取该 workspace 的 tab 列表。tab list 已带 workspace_id 与 focused,
# 但用 --workspace 显式过滤最稳妥(避免跨 workspace 出现多个 focused=true)。
list_json="$(herdr tab list --workspace "$workspace_id" 2>/dev/null)" || exit 0

# 用 jq 计算目标 tab_id:
#   - tabs 为空 -> 输出空串(调用方据此静默退出)
#   - 没有 focused tab -> 一律选第一个(与方向无关,符合需求)
#   - 有 focused tab -> next: (idx + 1) % n ;prev: (idx - 1 + n) % n(首尾循环)
target="$(
  jq -r --arg dir "$direction" '
    (.result.tabs // []) as $t
    | ($t | length) as $n
    | if $n == 0 then ""
      else
        ( [ $t[] | .focused == true ] | index(true) ) as $f
        | (if $f == null then
             0
           elif $dir == "next" then
             ($f + 1) % $n
           else
             ($f - 1 + $n) % $n
           end) as $i
        | $t[$i].tab_id
      end
  ' <<<"$list_json"
)"

# 没有可切换的 tab,静默退出。
[ -n "$target" ] || exit 0

# 执行切换。成功时 herdr 会把 tab JSON 打到 stdout —— 从快捷键触发时属于噪音,
# 故丢弃 stdout;失败信息(stderr)保留,并透传其返回码。
herdr tab focus "$target" >/dev/null
