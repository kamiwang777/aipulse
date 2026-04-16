# AIPulse

> The pulse of your AI coding subscriptions, right in your macOS menu bar.

**AIPulse** is a tiny SwiftBar plugin that shows live **5-hour** and **weekly** quota usage for [Claude Code](https://claude.com/claude-code) and [Codex](https://github.com/openai/codex-cli) — so you never burn through your limit mid-session again.

```
✦ 4.1% · 35.4%   🤖 12% · 33%
```

[中文文档](README.zh.md) · [Report a bug](https://github.com/kamiwang777/aipulse/issues) · [Author: Kami (@kamiwang777)](https://github.com/kamiwang777)

---

## Features

- **Zero-config** — auto-detects Claude Code and Codex from your local data
- **Dual-window tracking** — 5-hour rolling window + weekly window, side by side
- **Official data sources** — Codex reads the actual `rate_limits` your CLI receives from OpenAI; Claude Code uses [`ccusage`](https://github.com/ryoppippi/ccusage) for token accounting
- **Projection** — see where your 5h window will end at current burn rate
- **Context usage** — for Codex, see how full your current conversation's context window is
- **i18n** — English and Chinese (`AIPULSE_LANG=en|zh`)
- **Themeable** — cyberpunk (default) or mono
- **Graceful degradation** — works if only one of the two tools is installed
- **Privacy** — 100% local, no data ever leaves your Mac

## Screenshot

![menubar](screenshots/menubar.svg)

## Requirements

- macOS 11+
- [SwiftBar](https://swiftbar.app) (installer handles this)
- `node` ≥ 18 (`brew install node`)
- At least one of: **Claude Code** (`~/.claude/projects/`) or **Codex** (`~/.codex/sessions/`)

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/kami/aipulse/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/kamiwang777/aipulse.git
cd aipulse
./install.sh
```

## Configuration

Edit `~/.config/aipulse/config.sh` (created on first install):

| Variable | Default | Description |
|---|---|---|
| `AIPULSE_LANG` | `en` | Language: `en` \| `zh` |
| `AIPULSE_THEME` | `cyberpunk` | Colors: `cyberpunk` \| `mono` |
| `AIPULSE_HIDE_CLAUDE` | `0` | Set `1` to hide Claude section |
| `AIPULSE_HIDE_CODEX` | `0` | Set `1` to hide Codex section |
| `AIPULSE_CC_5H_LIMIT` | `max` | `max` (historical peak) or a token count |
| `AIPULSE_CC_WEEK_LIMIT` | `max` | Same as above, weekly |
| `AIPULSE_THRESH_INFO` | `50` | % threshold to switch green → cyan |
| `AIPULSE_THRESH_WARN` | `70` | % threshold to switch to yellow |
| `AIPULSE_THRESH_DANGER` | `90` | % threshold to switch to red |
| `AIPULSE_SHOW_COST` | `1` | Show `$` figures in dropdown |

After editing, click **Refresh** in the SwiftBar menu (or wait a minute).

## How it works

### Claude Code

Anthropic does **not publish** exact token limits for Claude Pro/Max subscriptions. AIPulse uses [`ccusage`](https://github.com/ryoppippi/ccusage) with `--token-limit max` — your **highest historical 5-hour window** becomes the 100% baseline. Same approach for the weekly window (highest historical week). This matches what the `ccusage` community has adopted as a pragmatic proxy.

If you know your plan's approximate ceiling (e.g. Max at ~200M tokens per 5h), set `AIPULSE_CC_5H_LIMIT=200000000` for a fixed baseline.

### Codex

Codex CLI sessions are stored as JSONL at `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`. Every API response includes a `rate_limits` block from OpenAI showing `primary` (5h) and `secondary` (weekly) percentages directly. AIPulse reads the latest entry — this is **literally** what Codex's internal usage tracker uses.

If the `resets_at` timestamp has passed, the window is marked with `⟳ last X%` (we show 0% until Codex reports fresh data).

## FAQ

**Q: Does this work with Cursor / Aider / Gemini CLI?**
Not yet. AIPulse is designed to be extended — PRs welcome.

**Q: Why does my Claude % sometimes exceed 100%?**
Because the baseline is your historical max. If you set a new record, the app will recalibrate on the next run.

**Q: My Codex shows `unknown plan`.**
The latest session didn't include `plan_type`. Open Codex, ask one question, refresh.

**Q: Can I change the refresh interval?**
Rename the plugin file: `aipulse.30s.sh` (30 sec), `aipulse.5m.sh` (5 min), etc.

**Q: Does it affect battery?**
Negligibly. Each refresh parses local files, no network calls. One `npx ccusage` invocation caches itself after first run.

## Privacy

AIPulse does **not**:
- Send any data anywhere
- Require an API key
- Require login
- Write analytics

It only reads local files that your CLI tools already write.

## Contributing

PRs welcome! Particularly:
- Support for other AI coding tools (Cursor, Aider, Gemini CLI, Windsurf, etc.)
- Additional themes
- More languages

Architecture: each tool is a `fetch_*` bash function returning a JSON blob. Add one, plug it into the dropdown renderer, ship.

## License

MIT © [Kami (@kamiwang777)](https://github.com/kamiwang777)

## Acknowledgments

- [ccusage](https://github.com/ryoppippi/ccusage) by @ryoppippi — does all the heavy lifting for Claude token accounting
- [SwiftBar](https://swiftbar.app) — makes macOS menu bar apps trivial
- Anthropic & OpenAI — for not (yet) encrypting their local log files 🙏
