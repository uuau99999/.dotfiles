## Development Workflow

### Planning for Complex Tasks

- For non-trivial requirements, automatically use `superpowers:brainstorm` or `superpowers:write-plan` to create a detailed plan
- When user requests implementation based on a plan document, use `superpowers:execute-plan`
- Before implementing, create a detailed plan covering:
  1. current architecture analysis,
  2. proposed changes with rationale,
  3. files to modify,
  4. potential edge cases,
  5. verification steps. Wait for my approval before executing.

## Testing & Verification

### Code Quality Checks

- With check fails, show me the error before proceeding to commit
- For Redis/state management changes, verify synchronization logic at startup, runtime, and cleanup phases

### JS/TS Projects Only (skip if no `package.json`)

- Run `tsc --noEmit` to verify type checking for TypeScript files
- Run ESLint/Prettier checks before committing (if configured)
- Run `npm run build` or `tsc --noEmit` after multi-file refactoring
- When initializing a JS/TS project, configure `.claude/settings.json` with PostToolUse hooks for eslint --fix and prettier --write on Edit/Write

## Hooks Configuration

### Smart Lint Hook (JS/TS projects only)

**Location**: `~/.claude/hooks/post-edit-lint-smart.sh`
- Auto-detects eslint/prettier; skips if no `package.json`
- Triggered on Edit/Write; auto-fixes then validates

### Task Completion Notification

**Location**: `~/.claude/hooks/task-completion-notify.sh`
- Sends system notification on task complete (macOS/Linux/Windows)
- Non-blocking; degrades gracefully

## Session Handoff

### Session 开始时

- 如果 `.claude/HANDOFF.md` 存在，先用 Read 工具读取它以恢复上次工作上下文
- 根据 HANDOFF 中的信息继续工作或等待用户指示

### Session 结束时（自动）

- SessionEnd hook 会自动调用 Claude CLI 生成 `.claude/HANDOFF.md`
- 包含：本次工作摘要、关键决策、未完成事项、近期 git 提交

## Documentation Management

### Project CLAUDE.md Synchronization

**CRITICAL**: Always keep project-level CLAUDE.md (and AGENTS.md if present) up-to-date. Update immediately when:

- Project structure or directory organization changes
- Core project goals or objectives evolve
- Key architectural decisions are made
- Important technical constraints or requirements change
- New critical dependencies or integrations are added

### Technical Insights Recording

- When discovering or implementing important technical background during development, record it in the project's CLAUDE.md under an `## Insights` section
- Include context about why certain technical decisions were made
- Document non-obvious implementation details that future developers should know
- Keep insights concise but informative

## Insights

### UI Verification

- After making UI changes, always verify on a real device or simulator before committing
- Pay special attention to: transparency/overlay effects, animation smoothness, color consistency, and text language (English vs Chinese)

### SwiftUI Best Practices

- When fixing SwiftUI bugs, prefer programmatic navigation over NavigationLink wrappers
- Avoid using `.infinity` for concrete frame dimensions
- Use opacity-based transitions instead of conditional rendering to prevent layout jitter

### Text Processing

- When implementing text processing (markdown stripping, tag removal, structured output), ensure the implementation handles ALL markup symbols (`##`, `**`, `` ` ``, etc.) not just some
- Test with real streaming output before committing

### Build Verification by Language

- **Go projects**: always run `goimports` and `go build` after proto changes
- **TypeScript/Vue projects**: run `oxlint` and type-check after changes
- Always verify builds pass before committing
