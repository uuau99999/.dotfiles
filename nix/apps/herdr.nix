{...}:
{
  # herdr agent pane 切换脚本。
  # 通过 home.file 部署为 symlink 到 ~/.config/herdr/,供 zsh alias 调用。
  home.file = {
    ".config/herdr/herdr-cycle-agent.sh".source = ../../.config/herdr/herdr-cycle-agent.sh;
    ".config/herdr/herdr-cycle-tab.sh".source = ../../.config/herdr/herdr-cycle-tab.sh;
  };
}
