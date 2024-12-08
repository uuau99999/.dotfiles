{...}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "vi-mode" "z" "colored-man-pages" "last-working-dir" "git" ];
    };
    autosuggestion.enable = true;
    initExtra = ''
      # load local zshrc
      [ -s "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
      
      # Add any additional configurations here
      export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # tmux fzf keymapping
      bindkey -s ^f "~/.dotfiles/.config/tmux/tmux-sessionizer\n"
      bindkey -s ^p "~/.dotfiles/.config/tmux/tmux-fzf\n"
      bindkey -s ^x "~/.dotfiles/.config/tmux/tmux-clear\n"
      #nvm
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
      # nvm use >/dev/null 18.18.0
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

    # yazi
    function yy() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          cd -- "$cwd"
            fi
            rm -f -- "$tmp"
    }

    # nvim lazy lock
    [[ ! -f ~/.config/nvim/lazy-lock.json ]] && ln -s ~/.dotfiles/.config/nvim/lazy-lock.json ~/.config/nvim/lazy-lock.json 
    [[ ! -f ~/.config/nvim/lazyvim.json ]] && ln -s ~/.dotfiles/.config/nvim/lazyvim.json ~/.config/nvim/lazyvim.json 

    '';
    shellAliases = {
      b = "nr build";
      c = "bat";
      d = "nr dev";
      i = "ni";
      f = "pnpm install --force";
      t = "nr test";
      v = "nvim";
      rmvc = "rm -rf node_modules/.vite";
      ii = "npm i -g @antfu/ni";
      python = "python3";
      pip = "pip3";
      ktmux = "pkill -f tmux";
      ltmux = "tmux ls";
      tma = "tmux a";
      gup = "git pull --rebase";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    # defaultOptions = [
    #   "--height=100%"
    #   "--layout=reverse"
    #   "--border"
    #   "--info=inline"
    #   "--color=bg:-1,bg+:-1,info:-1,prompt:0,pointer:2,marker:0,spinner:0,header:7"
    # ];
  };
}
