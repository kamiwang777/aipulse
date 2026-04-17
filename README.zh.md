# AIPulse

> AI 编程订阅的"脉搏"，常驻你的 macOS 菜单栏。

**AIPulse** 是一个极简的 SwiftBar 插件，实时显示 [Claude Code](https://claude.com/claude-code) 和 [Codex](https://github.com/openai/codex-cli) 的 **5 小时**和**周**配额使用百分比 —— 再也不会写着写着突然被限流。

```
🔴 ✦ 100% (1h13m) · 19%   🟢 🤖 3% · 34%
```

[English](README.md) · [提 issue](https://github.com/kamiwang777/aipulse/issues) · [作者 Kami (@kamiwang777)](https://github.com/kamiwang777)

---

当前版本：`v1.1.0`

## 特性

- **零配置** — 自动检测本地的 Claude Code / Codex 数据
- **双窗口** — 5h 滑动窗口 + 周窗口并排显示
- **独立状态灯** — Claude / Codex 各自显示红绿灯状态，不再共用一个标题颜色
- **Claude 恢复倒计时** — Claude 的 5h 窗口用满后，菜单栏会直接显示恢复还要多久
- **官方数据** — Codex 直读 OpenAI 下发的 `rate_limits`；Claude 优先读取本地官方 `usage` 缓存，缺失时再回退到 [`ccusage`](https://github.com/ryoppippi/ccusage)
- **预测** — 按当前燃烧速率预测 5h 窗口末的百分比
- **上下文占用** — Codex 专属：当前会话 tokens / context window
- **多语言** — 英文 / 中文 (`AIPULSE_LANG=en|zh`)
- **主题** — cyberpunk（默认）/ mono
- **优雅降级** — 只装一个工具也能正常工作
- **隐私** — 100% 本地，不联网

## 截图

![AIPulse Screenshot](screenshots/menubar.png)

## 依赖

- macOS 11+
- [SwiftBar](https://swiftbar.app)（安装脚本自动处理）
- `node` ≥ 18（`brew install node`）
- 以下二者至少一个：**Claude Code** (`~/.claude/projects/`) 或 **Codex** (`~/.codex/sessions/`)

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/kami/aipulse/main/install.sh | bash
```

或手动：

```bash
git clone https://github.com/kamiwang777/aipulse.git
cd aipulse
./install.sh
```

## 配置

编辑 `~/.config/aipulse/config.sh`：

| 变量 | 默认 | 说明 |
|---|---|---|
| `AIPULSE_LANG` | `en` | 语言：`en` \| `zh` |
| `AIPULSE_THEME` | `cyberpunk` | 主题：`cyberpunk` \| `mono` |
| `AIPULSE_HIDE_CLAUDE` | `0` | 设 `1` 隐藏 Claude 板块 |
| `AIPULSE_HIDE_CODEX` | `0` | 设 `1` 隐藏 Codex 板块 |
| `AIPULSE_CC_5H_LIMIT` | `max` | Claude 在 `ccusage` 回退模式下的基准值 |
| `AIPULSE_CC_WEEK_LIMIT` | `max` | 同上，针对周回退 |
| `AIPULSE_THRESH_INFO` | `50` | 绿 → 青阈值（%） |
| `AIPULSE_THRESH_WARN` | `70` | 黄色阈值 |
| `AIPULSE_THRESH_DANGER` | `90` | 红色阈值 |
| `AIPULSE_SHOW_COST` | `1` | 是否显示 `$` 金额 |

改完在 SwiftBar 菜单里点 **Refresh**（或等一分钟自动刷新）。

## 升级

```bash
cd aipulse
git pull
./install.sh
```

这样会保留你现有的 `~/.config/aipulse/config.sh`，同时刷新 `~/.swiftbar-plugins/` 里的插件文件。

升级后：
- 在 AIPulse 菜单里点一次 `Refresh`，或者重启 SwiftBar
- 确认下拉底部显示 `Version v1.1.0`

## 版本管理

- 当前发布版本号放在 [`VERSION`](VERSION)
- SwiftBar 插件元数据里的版本号与它保持一致
- 面向用户的升级记录放在 [`CHANGELOG.md`](CHANGELOG.md)

后续每次发版，至少同步更新这三处：
- `VERSION`
- `aipulse.1m.sh` 里的 `bitbar.version` 和 `AIPULSE_VERSION`
- `CHANGELOG.md`

## 原理

### Claude Code

Claude Code 这边，AIPulse 现在会优先读取 Claude 桌面端本地写下来的官方 `usage` 缓存。这样拿到的 `five_hour` / `seven_day` 百分比，以及重置时间，会更接近 Claude 自己界面里的显示。

[`ccusage`](https://github.com/ryoppippi/ccusage) 仍然保留，用来提供下拉里的 token 总量、燃烧速率、预测和费用估算。如果官方缓存拿不到，AIPulse 才会回退到之前那套 `ccusage` 基准模型。

`AIPULSE_CC_5H_LIMIT` 和 `AIPULSE_CC_WEEK_LIMIT` 现在主要用于回退模式，以及本地估算的计算逻辑。`max` 的意思还是“用你本地 `ccusage` 历史最高窗口/周作为基准”；如果你知道自己套餐的大致上限，也可以手动写固定 token 数。

当 Claude 的 5h 窗口达到 100% 时，标题会追加类似 `(1h13m)` 的恢复倒计时。AIPulse 会优先使用官方缓存里的重置时间，必要时再回退到当前活动 `ccusage` block 的结束时间。

下拉里的 Claude `费用` 默认也会按你配置的 `AIPULSE_CLAUDE_SUBSCRIPTION` 自动映射：
- `Pro` -> `$20/mo`
- `Max (5x)` -> `$100/mo`
- `Max (20x)` -> `$200/mo`

如果后续官网价格有变化，直接手动覆盖 `AIPULSE_CLAUDE_PRICE` 即可。

### Codex

Codex CLI 的 session 保存在 `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`。每次 API 响应都会带一个 `rate_limits` 块，包含 `primary`（5h）和 `secondary`（周）的精确百分比 —— 这是 **OpenAI 服务端直接下发**的数字，Codex 自己也是这么用的。

如果 `resets_at` 时间已过，会显示 `⟳ last X%` 提示该窗口已重置。

下拉里的 Codex `费用` 会优先按本地识别到的 `plan` 自动映射；只有你手动填写 `AIPULSE_CODEX_PRICE` 时才会覆盖。

## 常见问题

**Q: 支持 Cursor / Aider / Gemini CLI 吗？**
目前还没。架构是可扩展的，欢迎 PR。

**Q: 为什么 Claude 偶尔还是会看起来有点不一致？**
现在百分比优先来自 Claude 本地官方缓存，所以已经比以前更接近官方界面。下拉里的 token 和费用仍然是本地 `ccusage` 估算值，所以这些行会明确标成“本地估算”。

**Q: 为什么标题里 Claude 和 Codex 是各自的红绿灯，而不是整条一起变色？**
因为 SwiftBar 标题这一行只能设置一种文字颜色。AIPulse 用每个工具自己的 emoji 状态灯，避免 Claude 爆红时让 Codex 也看起来像告警。

**Q: Codex 显示 `unknown plan`？**
最新那次会话没带 `plan_type`。打开 Codex 随便问一句再刷新就好。

**Q: 怎么改刷新频率？**
重命名文件：`aipulse.30s.sh`（30 秒）、`aipulse.5m.sh`（5 分钟）等。

**Q: 耗电吗？**
基本可忽略。每次只读本地文件和本地应用缓存，不联网。`npx ccusage` 第一次会下载，之后走缓存。

## 隐私

AIPulse **不会**：
- 发送任何数据
- 需要 API key
- 需要登录
- 写入分析

它只读你 CLI 工具已经写在本地的文件。

## 贡献

欢迎 PR，特别是：
- 支持其他 AI 编程工具（Cursor、Aider、Gemini CLI、Windsurf 等）
- 新主题 / 新语言

架构：每个工具是一个 `fetch_*` bash 函数，返回 JSON。新增一个插进去就行。

## 许可

MIT © [Kami (@kamiwang777)](https://github.com/kamiwang777)

## 致谢

- [ccusage](https://github.com/ryoppippi/ccusage) by @ryoppippi —— Claude token 统计的重活全靠它
- [SwiftBar](https://swiftbar.app) —— 让 macOS 菜单栏插件变得极简
- Anthropic & OpenAI —— 感谢（暂时）没有加密本地日志文件 🙏
