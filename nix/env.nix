let
  # When running with sudo, use SUDO_USER; otherwise fall back to USER
  sudoUser = builtins.getEnv "SUDO_USER";
  currentUser = builtins.getEnv "USER";
  user = if sudoUser != "" then sudoUser else currentUser;
  
  platform = builtins.currentSystem;

  # Determine home directory based on platform
  # macOS: /Users/<username>, WSL: /home/<username>, Linux: /root
  isDarwin = builtins.match ".*-darwin" platform != null;
  isWSL = builtins.getEnv "WSL_DISTRO_NAME" != "";
  home = if isDarwin then "/Users/${user}"
         else if isWSL then "/home/${user}"
         else "/root";
in {
  inherit user home platform;
}
