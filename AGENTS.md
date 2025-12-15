# AGENTS.md

This file provides guidance to CodeBuddy Code when working with code in this repository.

## Overview

This is a macOS-focused dotfiles repository managed with GNU Stow and Nix (via nix-darwin and home-manager). It configures terminal tools, window management, and development environment for a consistent setup across machines.

## Installation Commands

```bash
# Install dotfiles (using GNU Stow)
cd ~/.dotfiles
stow .

# Setup Nix environment (macOS with nix-darwin)
# Note: env.nix auto-detects USER, HOME, and platform - no config file needed
sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake ~/.dotfiles/nix/#dev --impure

# Linux/WSL (home-manager only)
nix run home-manager -- switch --flake ~/.dotfiles/nix/#dev --impure

# Setup tmux plugins
cd ~/.dotfiles/.config/tmux
./prepare.sh
# Then in tmux: prefix + I to install plugins, prefix + r to reload
```

## Repository Architecture

```
.dotfiles/
├── nix/                      # Nix configuration (nix-darwin + home-manager)
│   ├── flake.nix            # Main flake: defines homeConfigurations and darwinConfigurations
│   ├── env.nix              # Auto-detects user/home/platform from environment
│   ├── darwin.nix           # macOS system settings (dock, finder, homebrew casks/brews)
│   ├── home.nix             # Shared home-manager config (packages, dotfile symlinks)
│   ├── home-darwin.nix      # macOS-specific home-manager extensions
│   ├── apps/                # Per-application nix modules
│   │   ├── zsh.nix          # Zsh config with oh-my-zsh, fzf integration, aliases
│   │   ├── aerospace.nix    # AeroSpace tiling WM config (inline TOML)
│   │   ├── nvim.nix         # Neovim package
│   │   ├── tmux.nix         # Tmux package
│   │   └── git.nix          # Git configuration
│   └── programs/            # Additional program modules
├── .config/
│   ├── nvim/                # LazyVim-based Neovim configuration
│   │   ├── init.lua         # Entry point, loads lazy.nvim and telescope extensions
│   │   └── lua/
│   │       ├── config/      # Core config (options, keymaps, autocmds, lazy)
│   │       └── plugins/     # Plugin configurations
│   ├── tmux/
│   │   ├── tmux.conf        # Main tmux config (prefix: C-q, plugins via tpm)
│   │   ├── tmux-sessionizer # Fuzzy session picker script
│   │   ├── tmux-fzf         # FZF integration script
│   │   └── tmux-cht.sh      # Cheat sheet lookup script
│   ├── sketchybar/          # macOS status bar replacement
│   │   ├── sketchybarrc     # Main config (loads items, plugins, helper)
│   │   ├── items/           # Individual bar items (spaces, apps, battery, etc.)
│   │   ├── plugins/         # Scripts for each item
│   │   └── helper/          # C helper for CPU/memory stats
│   ├── alacritty/           # Alacritty terminal config
│   ├── wezterm/             # WezTerm terminal config
│   ├── yazi/                # Yazi file manager config
│   └── starship.toml        # Starship prompt config
├── .hammerspoon/            # Hammerspoon automation
│   ├── init.lua             # App hotkeys (alt+B/C/I/W/etc.), auto-resize
│   └── input-source.lua     # Auto input method switching per app
└── .vimrc                   # Minimal vim config (uses defaults.vim)
```

## Key Configuration Patterns

### Nix Configuration Flow

1. `env.nix` auto-detects user/home/platform from environment variables (requires `--impure`):
   - Uses `SUDO_USER` when running with sudo, falls back to `USER`
   - Determines home path based on platform: `/Users/<user>` on macOS, `/root` on Linux
   - Detects platform via `builtins.currentSystem`
2. `flake.nix` creates two configurations:
   - `homeConfigurations.dev` for Linux/WSL (home-manager only)
   - `darwinConfigurations.dev` for macOS (nix-darwin + home-manager)
3. `darwin.nix` handles system-level macOS settings and Homebrew
4. `home.nix` manages dotfile symlinks and user packages

### Dotfile Management

- GNU Stow creates symlinks from `~/.dotfiles` to `~`
- Nix home-manager also manages some dotfiles via `home.file` in `home.nix`
- Some configs (like aerospace) are generated inline in nix modules

### Tmux Prefix and Key Bindings

- Prefix: `C-q` (not default `C-b`)
- `prefix + r` - Reload config
- `prefix + p` - Session picker
- `prefix + f` - FZF integration
- `prefix + m` - Floax floating pane
- `prefix + i` - Cheat sheet

### Neovim (LazyVim)

- Based on LazyVim distribution
- Telescope with harpoon, fzf, file_browser, ast_grep extensions
- Vue/TypeScript focused with volar LSP
- Catppuccin theme

### AeroSpace Window Management

- Vim-style navigation: `alt+h/j/k/l` for focus, `alt+shift+h/j/k/l` for move
- Workspaces: `alt+1-9`
- Apps auto-assign to workspaces (Ghostty→I, Chrome→C, VS Code→V, etc.)
- Integrates with sketchybar for workspace display

### Hammerspoon App Hotkeys

- `alt+B` - Brave Browser
- `alt+C` - Chrome
- `alt+I` - Ghostty terminal
- `alt+V` - VS Code
- `alt+S` - Spotify
- Auto input method switching based on focused app

## Shell Aliases (from zsh.nix)

```bash
v     # nvim
ll    # eza with icons
yy    # yazi with cd-on-exit
b     # nr build
d     # nr dev
t     # nr test
tma   # tmux a (attach)
gup   # git pull --rebase
```
