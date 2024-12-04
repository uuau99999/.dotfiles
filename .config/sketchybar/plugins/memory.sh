#!/bin/bash

ram_percentage_format="%3.1f%%"

sum_macos_vm_stats() {
  grep -Eo '[0-9]+' |
    awk '{ a += $1 * 4096 } END { print a }'
}

# page size of 4096 bytes
stats="$(vm_stat)"

used_and_cached=$(
  echo "$stats" |
    grep -E "(Pages active|Pages inactive|Pages speculative|Pages wired down|Pages occupied by compressor)" |
    sum_macos_vm_stats
)

cached=$(
  echo "$stats" |
    grep -E "(Pages purgeable|File-backed pages)" |
    sum_macos_vm_stats
)

free=$(
  echo "$stats" |
    grep -E "(Pages free)" |
    sum_macos_vm_stats
)

used=$((used_and_cached - cached))
total=$((used_and_cached + free))

memory_usage=$(echo "$used $total" | awk -v format="$ram_percentage_format" '{printf(format, 100*$1/$2)}')

# 获取内存占用百分比
# mem_usage=$(ps -A -o %mem | awk '{mem += $1} END {print mem}')

sketchybar --set mem label="$memory_usage"
