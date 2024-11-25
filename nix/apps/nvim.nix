{ config, pkgs,...}: 
{ 
  home.packages = with pkgs; [lazygit];

  home.file = {
    # ".config/nvim".source = ../../.config/nvim;
    ".config/nvim/init.lua".source = ../../.config/nvim/init.lua;
    ".config/nvim/lua".source = ../../.config/nvim/lua;
    ".config/nvim/stylua.toml".source = ../../.config/nvim/stylua.toml;
    # ".config/nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "~/.dotfiles/.config/nvim/lazy-lock.json";
    # ".config/nvim/lazyvim.json".source = config.lib.file.mkOutOfStoreSymlink "~/.dotfiles/.config/nvim/lazyvim.json";
  };

  programs.neovim = {
    enable = true;
    # viAlias = true;
    # vimAlias = true;
  };
}
