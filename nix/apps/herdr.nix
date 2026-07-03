{...}:
{
  # herdr 配置与 agent pane 切换脚本。
  # 通过 home.file 部署为 symlink 到 ~/.config/herdr/。
  #
  # 注意:config.toml 部署为只读 symlink 后,herdr 无法自行写回该文件
  # (如 onboarding、`herdr config reset-keys`)。今后改配置请改本仓库中的
  # .config/herdr/config.toml 再 rebuild。
  home.file = {
    ".config/herdr/config.toml".source = ../../.config/herdr/config.toml;
    ".config/herdr/herdr-cycle-agent.sh".source = ../../.config/herdr/herdr-cycle-agent.sh;
    ".config/herdr/herdr-cycle-tab.sh".source = ../../.config/herdr/herdr-cycle-tab.sh;
  };
}
