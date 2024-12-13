{ env, ... }:
let
  user = env.user;
  homeDirectory = env.home;
in 
{
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = 4;
  security.pam.enableSudoTouchIdAuth = true;
  users.users.${user}.home = homeDirectory;
  home-manager.backupFileExtension = "backup";

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
  ];

  homebrew.brews = [
    "coreutils"
    "sqlite3"
    "koekeishiya/formulae/yabai"
    "FelixKratz/formulae/sketchybar"
  ];
}
