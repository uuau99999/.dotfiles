{ config, pkgs, ... }:
{
  # ~/.claude/settings.json is a writable regular file and is not deployed.
  # The in-repo .claude/settings.json is a reference copy only.
  home.file = {
    # 全局开发指令
    ".claude/CLAUDE.md" = {
      source = ../../.claude/CLAUDE_GLOBAL.md;
    };

    # 权限审批钩子
    ".claude/hooks/permission-guard.sh" = {
      source = ../../.claude/hooks/permission-guard.sh;
      # 保持可执行权限
      executable = true;
    };

    # 智能 Lint Hook（自动检测 eslint/prettier）
    ".claude/hooks/post-edit-lint-smart.sh" = {
      source = ../../.claude/hooks/post-edit-lint-smart.sh;
      executable = true;
    };
  };
}
