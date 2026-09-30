{ config, pkgs, ... }:
{
  # ~/.codex/hooks.json is a writable regular file and is not deployed.
  # The in-repo .codex/hooks.json is a reference copy only.
  home.file = {
    ".codex/hooks/permission_request.py" = {
      source = ../../.codex/hooks/permission_request.py;
      executable = true;
    };

    ".codex/hooks/pre_tool_use_policy.py" = {
      source = ../../.codex/hooks/pre_tool_use_policy.py;
      executable = true;
    };
  };
}
