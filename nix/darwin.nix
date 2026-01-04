{ env, ... }:
let
  user = env.user;
  homeDirectory = env.home;
in 
{
  # services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = 5;
  security.pam.services.sudo_local.touchIdAuth = true;
  users.users.${user}.home = homeDirectory;
  home-manager.backupFileExtension = "backup";
  system.primaryUser = user;

  system.defaults = {
    dock.autohide = true;
    dock.orientation = "bottom";
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    NSGlobalDomain._HIHideMenuBar = true;
  };

  # homebrew
  homebrew.enable = true;
  homebrew.casks = [
    "sf-symbols"
    "font-sf-mono"
    "font-sf-pro"
    "wireshark"
    "google-chrome"
    # "hammerspoon"
    "kitty"
    "wezterm"
    "nikitabobko/tap/aerospace"
    "ghostty"
  ];

  homebrew.brews = [
    "coreutils"
    "sqlite3"
    # "koekeishiya/formulae/yabai"
    "FelixKratz/formulae/sketchybar"
    # "uv"
    # "pipx"
    # "fnm"
    "serie"
    "lazysql"
  ];
}
