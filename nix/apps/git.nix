{ config, pkgs, ...}:
{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "master";
      pull.rebase = true;
      pull.ff = "only";
      merge.conflictstyle = "zdiff3";
      merge.log = "true";
      rebase.autosquash = true;
      rebase.autostash = true;
      core.ignorecase = "false";
      core.editor = "vim";
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = "true";
      delta.line-numbers = "true";
      delta.dark = "true";
    };
  };
}
