# Hoyup .dotfiles

## Table of Contents

- [Installation](#installation)
- [tmux Configuration](#tmux-configuration)
- [Nix Configuration](#nix-configuration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Installation

1. Install Stow: (Instructions for your system here)
2. Clone the repository: `git clone https://github.com/uuau99999/.dotfiles`
3. Navigate to the repository: `cd ~/.dotfiles`
4. Stow the dotfiles: `stow .`

## tmux Configuration

1. Navigate to the tmux configuration directory: `cd ~/.dotfiles/.config/tmux`
2. Run the preparation script: `./prepare.sh`
3. Open tmux and install plugins: `prefix + I`
4. Reload tmux: `prefix + r`

## Nix Configuration

1. Install Nix: (Instructions for your system here)
2. Copy the configuration template: `cp ~/.dotfiles/nix/nix-config-template.toml ~/.dotfiles/nix/nix-config.toml`
3. Update the configuration file: `~/.dotfiles/nix/nix-config.toml`
4. use nix to switch to the dev environment

   > Linux/WSL, run

   ```bash
   nix run home-manager -- switch --flake ~/.dotfiles/nix/#dev --impure
   ```

   > macOS, run

   ```bash
   # nix run nix-darwin -- switch --flake ~/.dotfiles/nix/#dev --impure
   sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes --access-tokens github.com=your_github_access_token nix-darwin -- switch --flake ~/.dotfiles/nix/#dev --impure
   ```
