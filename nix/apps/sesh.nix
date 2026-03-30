{ config, pkgs,...}: 
{ 
  home.file = {
    ".config/sesh".source = ../../.config/sesh;
  };
}
