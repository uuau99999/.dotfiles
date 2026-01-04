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
    # (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code
    ast-grep
    gcc
    gnumake
    tmux
    python3
    neofetch
    rustup
    pkg-config
    openssl
    # nodejs_18
    glow
    carapace
    xh
    fnm
    yq
    btop
    duf
    delta
    pipx
    uv
  ];

  fonts.fontconfig.enable = true;

  home.file = {
    ".vimrc".source = ../.vimrc;
    ".config/starship.toml".source = ../.config/starship.toml;
    ".config/yazi/yazi.toml".source = ../.config/yazi/yazi.toml;
    ".config/yazi/theme.toml".source = ../.config/yazi/theme.toml;
    ".config/kitty".source = ../.config/kitty;
    ".config/wezterm".source = ../.config/wezterm;
    ".config/ghostty".source = ../.config/ghostty;
    ".claude/skills".source = ../.claude/skills;
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
  programs.lazydocker.enable = true;

  programs.lazydocker.settings = {
    gui = {
      returnImmediately = true;
    };
    commandTemplates = {
      serviceLogs = "{{ .DockerCompose }} logs --since=120m --follow {{ .Service.Name }}";
    };
  };

  imports = [
    ./apps/zsh.nix
    ./apps/nvim.nix
    ./apps/tmux.nix
    ./apps/git.nix
    ./apps/uv-packages.nix
    ./apps/pipx-packages.nix
  ];
}
