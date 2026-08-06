#!/usr/bin/env bash
#
# herdr-cycle-agent.sh — 在 herdr 的 agent panes 之间循环切换焦点。
#
# 用法:
#   herdr-cycle-agent.sh next   # 切换到下一个 agent pane(默认)
#   herdr-cycle-agent.sh prev   # 切换到上一个 agent pane
#
# 行为:
#   - 读取 `herdr agent list` 的 JSON,按其顺序构成 agent 环。
#   - 若存在 blocked agent(需要输入/审批/决策,见 herdr agent 状态文档):
#     按方向快进到最近的一个,跳过中间非 blocked。
#     当前已聚焦的 agent 不参与 blocked 优先(避免唯一 blocked 时无法切走)。
#   - 若没有其它 blocked:普通 next/prev 循环(首尾相接)。
#   - 若没有 focused pane:普通循环选第一个;blocked 优先时从环首/环尾取最近。
#   - 若没有任何 agent pane:静默退出(返回码 0)。
#
# 依赖: herdr、jq
# 说明: herdr 的 blocked 即“尚未处理的待决策”;无需本地 seen 文件。
#   focus 使用 pane_id(herdr 0.8+;terminal_id 会 agent_not_found)。

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

# 计算目标 pane_id:
#   - agents 为空 -> 空串
#   - 其它位置存在 blocked -> 从焦点下一格起按方向取最近 blocked
#   - 否则 next/prev 普通步进(无焦点时固定 0)
target="$(
  jq -r --arg dir "$direction" '
    (.result.agents // []) as $a
    | ($a | length) as $n
    | if $n == 0 then ""
      else
        ([ $a[] | .focused == true ] | index(true)) as $f
        | (
            [ range(0; $n)
              | select(
                  ($a[.].agent_status // "") == "blocked"
                  and ($f == null or . != $f)
                )
            ]
          ) as $blocked
        | (
            if ($blocked | length) > 0 then
              if $f == null then
                if $dir == "next" then $blocked[0]
                else $blocked[-1]
                end
              else
                (
                  [ range(1; $n) as $step
                    | (
                        if $dir == "next" then ($f + $step) % $n
                        else ($f - $step + $n) % $n
                        end
                      ) as $i
                    | select(($blocked | index($i)) != null)
                    | $i
                  ]
                  | .[0]
                )
              end
            else
              if $f == null then 0
              elif $dir == "next" then ($f + 1) % $n
              else ($f - 1 + $n) % $n
              end
            end
          ) as $t
        | $a[$t].pane_id // ""
      end
  ' <<<"$list_json"
)"

[ -n "$target" ] || exit 0

# 执行切换。成功时 herdr 会把 agent JSON 打到 stdout —— 从快捷键触发时属于噪音,
# 故丢弃 stdout;失败信息(stderr)保留,并透传其返回码。
herdr agent focus "$target" >/dev/null
