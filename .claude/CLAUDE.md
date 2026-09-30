# Dotfiles Project

Nix + home-manager dotfiles for macOS, managed with nix-darwin.

## Project Structure

- `nix/` - Nix configuration files
  - `apps/` - Per-application home-manager modules (zsh, tmux, claude-code, etc.)
  - `darwin/` - nix-darwin system-level config
- `.claude/` - Claude Code configuration (`CLAUDE_GLOBAL.md` and hooks deployed via `nix/apps/claude-code.nix`)
  - `CLAUDE_GLOBAL.md` - Global CLAUDE.md injected to `~/.claude/CLAUDE.md` by home-manager
  - `settings.json` - reference copy only; live `~/.claude/settings.json` is a writable file and is not a `home.file`
  - `hooks/` - Hook scripts (lint, notify, etc.)
  - `skills/` - Custom skill definitions

## Key Convention

- `.claude/CLAUDE_GLOBAL.md` is the **global** instruction file, deployed to `~/.claude/CLAUDE.md` via home-manager
- This file (`.claude/CLAUDE.md`) is the **project-local** instruction for the dotfiles repo itself

## Development Notes

- After changing deployed files under `.claude/` (`CLAUDE_GLOBAL.md`, hooks), run `darwin-rebuild switch` (or equivalent). `settings.json` is not deployed
- Hooks must have `executable = true` in their nix module definition
