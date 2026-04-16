# 即刻 / 小红书

**标题：**
用 AI 编程总被限流？一个菜单栏小工具帮你实时看配额

**正文：**

最近 Claude Code 和 Codex 用得多，最痛的一件事就是——写着写着突然限流了，之前毫无预警。

花了一晚上搞了个 macOS 菜单栏小工具 **AIPulse**，常驻顶栏一行字：

✦ 20.2% · 40.5%   🤖 12% · 33%

左边是 5 小时滑动窗口用了多少，右边是这周用了多少。

点开还能看到：
- 进度条 + 颜色预警（绿 → 青 → 黄 → 红）
- 按当前速度预测窗口结束时能烧到多少
- 剩余时间、模型、费用

关键是**零配置**——它直接读你本地的 session 日志，不联网、不要 API key。

一键安装：
curl -fsSL https://raw.githubusercontent.com/kamiwang777/aipulse/main/install.sh | bash

开源地址：github.com/kamiwang777/aipulse

如果你也在用 AI 编程工具，欢迎 star 和反馈。后续会加 Cursor / Gemini 等支持。

**标签：**
#AI编程 #ClaudeCode #Codex #macOS #开发工具 #开源
