# Dotfiles Project

Nix + home-manager dotfiles for macOS, managed with nix-darwin.

## Project Structure

- `nix/` - Nix configuration files
  - `apps/` - Per-application home-manager modules (zsh, tmux, claude-code, etc.)
  - `darwin/` - nix-darwin system-level config
- `.claude/` - Claude Code configuration (deployed globally via `nix/apps/claude-code.nix`)
  - `CLAUDE_GLOBAL.md` - Global CLAUDE.md injected to `~/.claude/CLAUDE.md` by home-manager
  - `settings.json` - Global Claude Code settings
  - `hooks/` - Hook scripts (lint, notify, handoff, etc.)
  - `skills/` - Custom skill definitions

## Key Convention

- `.claude/CLAUDE_GLOBAL.md` is the **global** instruction file, deployed to `~/.claude/CLAUDE.md` via home-manager
- This file (`.claude/CLAUDE.md`) is the **project-local** instruction for the dotfiles repo itself

## Development Notes

- After changing any file under `.claude/`, run `darwin-rebuild switch` (or equivalent) to deploy
- Hooks must have `executable = true` in their nix module definition
