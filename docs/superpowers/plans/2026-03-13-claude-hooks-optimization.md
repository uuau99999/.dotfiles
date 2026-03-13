# Claude Hooks Optimization Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 优化 Claude Code hooks 配置，添加智能 lint 检查和跨平台任务完成通知

**Architecture:**
- 重构现有的 PostToolUse hook，使其能够智能检测项目中是否安装了 eslint/prettier
- 创建通用的跨平台通知脚本，支持 macOS、Linux 和 Windows
- 使用项目本地 hooks（`.claude/hooks/`）而非全局 hooks，保持与现有架构一致
- 更新 settings.json 配置，整合新的 hooks

**Tech Stack:**
- Bash scripting (hooks)
- jq (JSON processing) - 必需依赖
- Claude Code hooks API
- Platform-specific notification commands (osascript, notify-send, powershell)

**Hook Paths:**
- 项目本地: `.claude/hooks/` (当前项目使用)
- 全局: `~/.claude/hooks/` (系统级配置)

---

## Chunk 1: Lint Hook Implementation

### Task 1: 创建智能 Lint Hook 脚本

**Files:**
- Create: `.claude/hooks/post-edit-lint-smart.sh`
- Modify: `.claude/settings.json`

- [ ] **Step 1: 编写 lint hook 脚本框架**

创建基础脚本结构，包含依赖检查、输入解析和文件类型检测：

```bash
#!/bin/bash
# .claude/hooks/post-edit-lint-smart.sh
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
```

- [ ] **Step 2: 添加工具检测函数**

添加检测 eslint 和 prettier 是否安装的函数：

```bash
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
```

- [ ] **Step 3: 实现 ESLint 检查逻辑**

```bash
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
```

- [ ] **Step 4: 实现 Prettier 检查逻辑**

```bash
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
```

- [ ] **Step 5: 添加错误报告逻辑**

```bash
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
```

- [ ] **Step 6: 设置脚本执行权限**

```bash
chmod +x .claude/hooks/post-edit-lint-smart.sh
```

- [ ] **Step 7: 验证脚本语法和依赖**

```bash
# Check bash syntax
bash -n .claude/hooks/post-edit-lint-smart.sh
```

Expected: 无输出表示语法正确

- [ ] **Step 7.5: 测试工具检测逻辑**

创建测试环境验证函数：

```bash
# Create test project structure
mkdir -p /tmp/test-lint-hook/node_modules/.bin
touch /tmp/test-lint-hook/node_modules/.bin/eslint
chmod +x /tmp/test-lint-hook/node_modules/.bin/eslint
echo '{"devDependencies": {"eslint": "^8.0.0", "prettier": "^3.0.0"}}' > /tmp/test-lint-hook/package.json

# Test find_project_root function
TEST_DIR="/tmp/test-lint-hook/src/components"
mkdir -p "$TEST_DIR"
# Should find /tmp/test-lint-hook

# Test has_tool function
# Should detect eslint and prettier

# Cleanup
rm -rf /tmp/test-lint-hook
```

Expected: 函数能够正确检测项目根目录和工具

- [ ] **Step 8: Commit lint hook**

```bash
git add .claude/hooks/post-edit-lint-smart.sh
git commit -m "feat: add smart lint hook with auto-detection"
```

---

## Chunk 2: Notification Hook Implementation

### Task 2: 创建跨平台通知脚本

**Files:**
- Create: `.claude/hooks/task-completion-notify.sh`

- [ ] **Step 1: 编写通知脚本框架**

```bash
#!/bin/bash
# .claude/hooks/task-completion-notify.sh
# Send system notification when task completes

set -euo pipefail

# Check if jq is available
if ! command -v jq &> /dev/null; then
  # Silently exit if jq not available (don't block on notification)
  exit 0
fi

# Get notification message from input or use default
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Task completed"')
TITLE="Claude Code"
```

- [ ] **Step 2: 添加平台检测函数**

```bash
# Detect operating system
detect_os() {
  case "$(uname -s)" in
    Darwin*)
      echo "macos"
      ;;
    Linux*)
      echo "linux"
      ;;
    CYGWIN*|MINGW*|MSYS*)
      echo "windows"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

OS=$(detect_os)
```

- [ ] **Step 3: 实现 macOS 通知**

```bash
# Send notification based on OS
send_notification() {
  local title=$1
  local message=$2

  case "$OS" in
    macos)
      osascript -e "display notification \"$message\" with title \"$title\""
      ;;
```

- [ ] **Step 4: 实现 Linux 通知**

```bash
    linux)
      # Try notify-send (most common)
      if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message"
      # Fallback to zenity
      elif command -v zenity &> /dev/null; then
        zenity --info --title="$title" --text="$message" --timeout=5
      # Fallback to kdialog (KDE)
      elif command -v kdialog &> /dev/null; then
        kdialog --title "$title" --passivepopup "$message" 5
      else
        echo "No notification tool found on Linux"
        return 1
      fi
      ;;
```

- [ ] **Step 5: 实现 Windows 通知**

```bash
    windows)
      # Use simpler PowerShell command for Windows notifications
      # Create a temporary PowerShell script to avoid escaping issues
      TEMP_PS="/tmp/claude-notify-$$.ps1"
      cat > "$TEMP_PS" << 'PSEOF'
Add-Type -AssemblyName System.Windows.Forms
$notification = New-Object System.Windows.Forms.NotifyIcon
$notification.Icon = [System.Drawing.SystemIcons]::Information
$notification.BalloonTipTitle = $args[0]
$notification.BalloonTipText = $args[1]
$notification.Visible = $true
$notification.ShowBalloonTip(5000)
Start-Sleep -Seconds 1
$notification.Dispose()
PSEOF
      powershell.exe -ExecutionPolicy Bypass -File "$TEMP_PS" "$title" "$message" 2>/dev/null || true
      rm -f "$TEMP_PS"
      ;;
```

- [ ] **Step 6: 添加错误处理和退出**

```bash
    *)
      echo "Unsupported operating system: $OS"
      return 1
      ;;
  esac
}

# Send the notification
send_notification "$TITLE" "$MESSAGE"

# Always exit successfully (don't block on notification failure)
exit 0
```

- [ ] **Step 7: 设置脚本执行权限**

```bash
chmod +x .claude/hooks/task-completion-notify.sh
```

- [ ] **Step 8: 测试 macOS 通知**

```bash
echo '{"message": "Test notification"}' | .claude/hooks/task-completion-notify.sh
```

Expected: 在 macOS 上看到系统通知

- [ ] **Step 9: Commit notification hook**

```bash
git add .claude/hooks/task-completion-notify.sh
git commit -m "feat: add cross-platform task completion notification"
```

---

## Chunk 3: Settings Configuration Update

### Task 3: 更新 settings.json 配置

**Files:**
- Modify: `.claude/settings.json`

- [ ] **Step 1: 备份现有配置**

```bash
cp .claude/settings.json .claude/settings.json.backup
```

- [ ] **Step 2: 读取并解析现有配置**

验证当前配置结构：

```bash
jq '.' .claude/settings.json
```

Expected: 输出格式化的 JSON

- [ ] **Step 3: 添加 PostToolUse hook 配置**

更新 settings.json，添加 lint hook（使用项目本地路径）：

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "PROXY_MANAGED",
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:5000"
  },
  "includeCoAuthoredBy": false,
  "model": "opus",
  "hooks": {
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/permission-guard.sh",
            "timeout": 10,
            "statusMessage": "Reviewing permission..."
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/post-edit-lint-smart.sh",
            "timeout": 30,
            "statusMessage": "Running lint checks..."
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "npx -y ccstatusline@latest",
    "padding": 0
  },
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  },
  "outputStyle": "Explanatory",
  "language": "Chinese",
  "gitAttribution": false,
  "mcpServers": {}
}
```

- [ ] **Step 4: 添加 TaskComplete hook 配置**

继续更新 settings.json，添加通知 hook（使用项目本地路径）：

```json
{
  "hooks": {
    "PermissionRequest": [...],
    "PostToolUse": [...],
    "TaskComplete": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/task-completion-notify.sh",
            "timeout": 5,
            "statusMessage": "Sending notification..."
          }
        ]
      }
    ]
  }
}
```

注意：如果配置失败，可以回滚到备份：

```bash
# Rollback if needed
mv .claude/settings.json.backup .claude/settings.json
```

- [ ] **Step 5: 验证 JSON 格式**

```bash
jq '.' .claude/settings.json > /dev/null && echo "Valid JSON" || echo "Invalid JSON"
```

Expected: "Valid JSON"

- [ ] **Step 6: 测试配置加载**

重启 Claude Code 或重新加载配置：

```bash
# 配置会在下次 Claude Code 启动时自动加载
echo "Configuration updated. Restart Claude Code to apply changes."
```

- [ ] **Step 7: Commit settings update**

```bash
git add .claude/settings.json
git commit -m "feat: configure smart lint and notification hooks"
```

---

## Chunk 4: Integration Testing

### Task 4: 端到端测试

**Files:**
- Test: 创建测试文件验证 hooks 功能

- [ ] **Step 1: 创建测试 TypeScript 文件**

```bash
mkdir -p test-hooks
cat > test-hooks/test.ts << 'EOF'
const greeting = "Hello World"
console.log(greeting)
EOF
```

- [ ] **Step 2: 测试 lint hook（有 eslint 的项目）**

在有 eslint 配置的项目中编辑文件：

```bash
# 假设当前项目有 eslint
echo 'const x=1' >> test-hooks/test.ts
```

Expected: Hook 应该自动运行 eslint --fix

- [ ] **Step 3: 测试 lint hook（无 eslint 的项目）**

在没有 eslint 的目录中测试：

```bash
cd /tmp
mkdir test-no-lint
cd test-no-lint
echo 'const x=1' > test.ts
```

Expected: Hook 应该跳过 lint 检查

- [ ] **Step 4: 测试通知 hook**

手动触发通知测试：

```bash
echo '{"message": "Integration test completed"}' | ~/.claude/hooks/task-completion-notify.sh
```

Expected: 收到系统通知

- [ ] **Step 5: 清理测试文件**

```bash
rm -rf test-hooks
```

- [ ] **Step 6: 验证所有 hooks 正常工作**

检查 Claude Code 日志，确认 hooks 执行无错误：

```bash
# 查看最近的 hook 执行日志
tail -n 50 ~/.claude/logs/hooks.log 2>/dev/null || echo "No hook logs found"
```

- [ ] **Step 7: 更新文档**

在 CLAUDE.md 中记录新的 hooks 配置：

```markdown
## Hooks Configuration

### Smart Lint Hook
- Automatically detects if project has eslint/prettier installed
- Only runs on JS/TS files
- Auto-fixes issues when possible

### Task Completion Notification
- Sends system notification when tasks complete
- Cross-platform support (macOS, Linux, Windows)
```

- [ ] **Step 8: Final commit**

```bash
git add .claude/CLAUDE.md
git commit -m "docs: document new hooks configuration"
```

---

## Verification Checklist

### Lint Hook 验证
- [ ] Lint hook 能在 node_modules/.bin 中检测到 eslint
- [ ] Lint hook 能在 package.json devDependencies 中检测到 eslint
- [ ] Lint hook 能在 package.json dependencies 中检测到 prettier
- [ ] Lint hook 在没有 package.json 的目录中跳过检查
- [ ] Lint hook 只在 JS/TS/JSX/TSX 文件上运行
- [ ] Lint hook 能够自动修复 eslint 问题
- [ ] Lint hook 能够自动格式化 prettier 问题
- [ ] Lint hook 在缺少 jq 时报错并退出
- [ ] Lint hook 在缺少 npx 时报告错误但不崩溃
- [ ] Lint hook 能正确处理包含空格的文件路径

### 通知 Hook 验证
- [ ] 通知 hook 在 macOS 上使用 osascript 正常工作
- [ ] 通知 hook 在 Linux 上尝试 notify-send（如果可测试）
- [ ] 通知 hook 在 Linux 上降级到 zenity（如果可测试）
- [ ] 通知 hook 在 Windows 上使用 PowerShell（如果可测试）
- [ ] 通知 hook 在缺少 jq 时静默退出（不阻塞）
- [ ] 通知 hook 失败不会阻塞任务完成

### 配置验证
- [ ] settings.json 配置格式正确（通过 jq 验证）
- [ ] PostToolUse hook 路径正确（项目本地路径）
- [ ] TaskComplete hook 路径正确（项目本地路径）
- [ ] 所有脚本都有执行权限（chmod +x）
- [ ] 文档已更新（CLAUDE.md）

### 边界情况验证
- [ ] 在 monorepo 中能找到正确的 package.json
- [ ] 文件路径在项目根目录外时能正确处理
- [ ] 相对路径计算在各种场景下都正确
- [ ] Hook 超时设置合理（lint: 30s, notify: 5s）

---

## Notes

### Hook 路径策略
- **项目本地 hooks** (`.claude/hooks/`): 用于项目特定的 lint 和通知逻辑
- **全局 hooks** (`~/.claude/hooks/`): 用于系统级的权限控制（如 permission-guard.sh）
- 当前实现使用项目本地路径，保持与现有 post-edit-lint.sh 的一致性

### 错误处理策略
- Lint hook: 严格模式，发现错误时阻塞（block behavior）
- 通知 hook: 宽松模式，失败时静默退出（不阻塞任务完成）
- 依赖检查: jq 是必需的，缺失时 lint hook 报错，notify hook 静默退出

### 性能考虑
- Lint hook 超时设置为 30 秒，适应大文件的 lint 时间
- 通知 hook 超时设置为 5 秒，避免阻塞用户体验
- 使用智能检测避免在无工具项目中执行无效操作

### 跨平台兼容性
- 脚本使用 `set -euo pipefail` 确保错误处理
- Windows PowerShell 使用临时脚本文件避免复杂的转义问题
- Linux 通知使用多级降级策略（notify-send → zenity → kdialog）
