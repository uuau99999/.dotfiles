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

- For TypeScript files: Always run `tsc --noEmit` to verify type checking
- For JavaScript/TypeScript files: Check if project has ESLint or Prettier configured, and run them before committing
- Always run `npm run build` or `tsc --noEmit` to verify TypeScript compilation after multi-file refactoring
- Run ESLint checks before committing code changes
- For Redis/state management changes, verify synchronization logic at startup, runtime, and cleanup phases
- With check fails, Show me the error before proceeding to commit

## Project Setup & Configuration

### JavaScript/TypeScript Project Hooks

When initializing or updating a JavaScript/TypeScript/Node.js project, automatically configure `.claude/settings.json` with the following hooks for code quality automation:

**Detection criteria**: Project has `package.json` and uses ESLint/Prettier (check for config files or package.json dependencies)

**Required hooks configuration**:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | grep -E '\\.(js|ts|tsx|vue)$' | xargs -r eslint --fix"
          },
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | grep -E '\\.(js|ts|tsx|vue|json|md|css|scss)$' | xargs -r npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

**Benefits**:

- Automatic ESLint fixes on every file edit (JS/TS/TSX/Vue only)
- Automatic Prettier formatting on every file edit (code + config files)
- Single-file checking (fast, no full project scan)
- File type filtering (only checks relevant files)

**When to apply**:

- During project initialization when creating `.claude/` directory
- When user asks to "set up hooks" or "configure code quality"
- When you notice the project lacks automated linting/formatting

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
