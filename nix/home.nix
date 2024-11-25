# home.nix
# home-manager switch 

{ config, pkgs, env, ... }:

let 
  user = env.user;
  homeDirectory = env.home;
in

{
  home.username = "${user}";
  home.homeDirectory = "${homeDirectory}";
  home.stateVersion = "23.05"; # Please read the comment before changing.
  # Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ast-grep
    gcc
    gnumake
    tmux
    python3
    neofetch
    rustup
    pkg-config
    openssl
    nodejs_18
  ];

  home.file = {
    ".config/starship.toml".source = ../.config/starship.toml;
    ".config/yazi/yazi.toml".source = ../.config/yazi/yazi.toml;
    ".config/yazi/theme.toml".source = ../.config/yazi/theme.toml;
    ".config/kitty".source = ../.config/kitty;
    ".config/wezterm".source = ../.config/wezterm;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  home.sessionVariables = {
  };
  home.sessionPath = [
    "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
  ];
  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.yazi.enable = true;
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;

  imports = [
    ./apps/zsh.nix
    ./apps/nvim.nix
    ./apps/tmux.nix
    ./apps/git.nix
  ];
}
