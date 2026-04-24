{ config, pkgs, ... }:
{
  home.file = {
    ".codex/hooks.json" = {
      source = ../../.codex/hooks.json;
    };

    ".codex/hooks/permission_request.py" = {
      source = ../../.codex/hooks/permission_request.py;
      executable = true;
    };

    ".codex/hooks/pre_tool_use_policy.py" = {
      source = ../../.codex/hooks/pre_tool_use_policy.py;
      executable = true;
    };

    ".codex/hooks/task_completion_notify.sh" = {
      source = ../../.codex/hooks/task_completion_notify.sh;
      executable = true;
    };
  };
}
