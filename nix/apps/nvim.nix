{ pkgs,...}: 
{ 
  home.packages = with pkgs; [lazygit];

  home.file = {
    ".config/nvim".source = ../../.config/nvim;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}
