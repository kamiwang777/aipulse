# V2EX — 分享创造

**标题：**
AIPulse - macOS 菜单栏实时显示 Claude Code / Codex 的 5 小时和周配额百分比

**正文：**

写代码正嗨的时候被限流，是不是很崩溃？

搞了个 SwiftBar 菜单栏小工具 **AIPulse**，一眼看到 Claude Code 和 Codex 的配额还剩多少：

```
✦ 20.2% · 40.5%   🤖 12% · 33%
```

左边 5 小时窗口 %，右边周窗口 %。

**原理：**
- Claude Code：用 ccusage 解析本地 session 日志，历史峰值 = 100%
- Codex：直读 OpenAI 在 session JSONL 里下发的 `rate_limits` 百分比（官方数据）

100% 本地，不联网，不要 API key。单文件 bash 脚本，~350 行。

**安装：**
```bash
curl -fsSL https://raw.githubusercontent.com/kamiwang777/aipulse/main/install.sh | bash
```

支持中英文切换、cyberpunk / mono 两种主题、自定义阈值。MIT 开源。

GitHub: https://github.com/kamiwang777/aipulse

架构是可扩展的（每个工具是一个 `fetch_*` 函数），欢迎 PR 加入 Cursor / Aider / Gemini CLI 等支持。
