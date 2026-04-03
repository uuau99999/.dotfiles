{ config, pkgs, ... }:
{
  home.file = {
    # Claude Code 主配置
    ".claude/settings.json" = {
      source = ../../.claude/settings.json;
      # 保持文件权限为 600（仅所有者可读写）
      onChange = ''
        echo "Claude Code settings.json updated"
      '';
    };

    # 全局开发指令
    ".claude/CLAUDE.md" = {
      source = ../../.claude/CLAUDE.md;
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

    # 任务完成通知 Hook（跨平台支持）
    ".claude/hooks/task-completion-notify.sh" = {
      source = ../../.claude/hooks/task-completion-notify.sh;
      executable = true;
    };

    # Session 结束自动生成 HANDOFF.md
    ".claude/hooks/session-handoff.sh" = {
      source = ../../.claude/hooks/session-handoff.sh;
      executable = true;
    };
  };
}
