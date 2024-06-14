#!/usr/bin/env bash

mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

mkdir -p ~/.local/bin
ln -s ~/.config/tmux/tmux-clear ~/.local/bin/tmux-clear
ln -s ~/.config/tmux/tmux-sessionizer ~/.local/bin/tmux-sessionizer

touch ~/.tmux-repo
echo ~/.config/tmux >>~/.tmux-repo
