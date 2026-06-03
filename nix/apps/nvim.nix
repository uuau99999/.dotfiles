{ config, pkgs, nvimPkgs, ... }:
{
  home.packages = [
    pkgs.lazygit
    pkgs.lua51Packages.luacheck
    (pkgs.writeShellScriptBin "sg" ''
      exec ${pkgs.ast-grep}/bin/ast-grep "$@"
    '')
    nvimPkgs.tree-sitter
  ];

  home.file = {
    # ".config/nvim".source = ../../.config/nvim;
    ".config/nvim/init.lua".source = ../../.config/nvim/init.lua;
    ".config/nvim/lua".source = ../../.config/nvim/lua;
    ".config/nvim/defaults".source = ../../.config/nvim/defaults;
    ".config/nvim/stylua.toml".source = ../../.config/nvim/stylua.toml;
    # ".config/nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "~/.dotfiles/.config/nvim/lazy-lock.json";
    # ".config/nvim/lazyvim.json".source = config.lib.file.mkOutOfStoreSymlink "~/.dotfiles/.config/nvim/lazyvim.json";
  };

  programs.neovim = {
    enable = true;
    package = nvimPkgs.neovim-unwrapped;
    # viAlias = true;
    # vimAlias = true;
  };
}
