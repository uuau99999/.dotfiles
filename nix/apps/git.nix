{ config, pkgs, ...}:
{
  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = true;
      pull.ff = "only";
      merge.conflictstyle = "diff3";
      merge.log = "true";
      rebase.autosquash = true;
      rebase.autostash = true;
      core.ignorecase = "false";
    };
  };
}
