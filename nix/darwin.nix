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
  };

  # homebrew
  homebrew.enable = true;
  homebrew.casks = [
    "wireshark"
    "google-chrome"
    # "hammerspoon"
    "kitty"
    "wezterm"
  ];

  homebrew.brews = [
    "koekeishiya/formulae/yabai"
  ];
}
