{ config, pkgs, ...}: 
{
  home.file = {
    ".config/tmux/tmux.conf".source =  ../../.config/tmux/tmux.conf;
    ".config/tmux/tmux-cht.sh".source =  ../../.config/tmux/tmux-cht.sh;
    ".config/tmux/tmux-clear".source = ../../.config/tmux/tmux-clear;
    ".config/tmux/tmux-fzf".source = ../../.config/tmux/tmux-fzf;
    ".config/tmux/tmux-preview".source = ../../.config/tmux/tmux-preview;
    ".config/tmux/tmux-sessionizer".source = ../../.config/tmux/tmux-sessionizer;
    ".config/tmux/tmux-lastsession".source = ../../.config/tmux/tmux-lastsession;
    ".config/tmux/tmux-tldr".source = ../../.config/tmux/tmux-tldr;
    ".tmux/plugins/tpm".source = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tpm";
      rev = "v3.1.0";
      sha256 = "sha256-CeI9Wq6tHqV68woE11lIY4cLoNY8XWyXyMHTDmFKJKI=";
    };
    ".config/tmux/plugins/catppuccin/tmux".source = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "tmux";
      rev = "b2f219c";
      sha256 = "sha256-Is0CQ1ZJMXIwpDjrI5MDNHJtq+R3jlNcd9NXQESUe2w=";
    };
  };
}
