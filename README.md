## Hoyup .dotfiles

#### Usage

     1. install stow
     2. cd ~/ && git clone https://github.com/uuau99999/.dotfiles
     3. cd ~/.dotfiles
     4. stow .

#### tmux conf setup

     1. cd ~/.dotfiles/.config/tmux
     2. ./prepare.sh
     3. enter tmux and enter `prefix + I` to install plugins, then run `prefix + r` to reload

#### nix setup

1.  install nix
2.  cp ~/.dotfiles/nix/nix-config-template.toml ~/.dotfiles/nix/nix-config.toml
3.  upate config in ~/.dotfiles/nix/nix-config.toml
4.

1) linux or wsl, run

```bash
  nix run home-manager -- switch --flake ~/.dotfiles/nix/#dev --impure
```

2. macOS, run

```bash
  nix run nix-darwin -- switch --flake ~/.dotfiles/nix/#dev --impure
```
