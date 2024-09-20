
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

ll_shell="eza -A --color=always --long --icons=always --smart-group --no-permissions --no-user --no-time"

export FZF_CTRL_T_OPTS="--preview '[ -f {} ] && bat -n --color=always --line-range :500 {} || $ll_shell {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}
# ---- Eza (better ls) -----

alias ll=$ll_shell

function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# starship
eval "$(starship init zsh)"

# custom alias
alias d="nr dev"
alias t="nr test"
alias rmvc="rm -rf node_modules/.vite"
alias b="nr build"
alias i="ni"
alias f="pnpm install --force"
alias ii="npm i -g @antfu/ni"
alias v="nvim"

alias python=python3
alias pip=pip3

# tmux
alias ktmux="pkill -f tmux"
alias ltmux="tmux ls"
alias tma="tmux a"

# tmux fzf keymapping
bindkey -s ^f "~/.config/tmux/tmux-sessionizer\n"
bindkey -s ^p "~/.config/tmux/tmux-fzf\n"
bindkey -s ^x "~/.config/tmux/tmux-clear\n"

