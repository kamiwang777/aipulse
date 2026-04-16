# AIPulse

> The pulse of your AI coding subscriptions, right in your macOS menu bar.

**AIPulse** is a tiny SwiftBar plugin that shows live **5-hour** and **weekly** quota usage for [Claude Code](https://claude.com/claude-code) and [Codex](https://github.com/openai/codex-cli) — so you never burn through your limit mid-session again.

```
🔴 ✦ 100% (1h13m) · 19%   🟢 🤖 3% · 34%
```

[中文文档](README.zh.md) · [Report a bug](https://github.com/kamiwang777/aipulse/issues) · [Author: Kami (@kamiwang777)](https://github.com/kamiwang777)

---

Current version: `v1.1.0`

## Features

- **Zero-config** — auto-detects Claude Code and Codex from your local data
- **Dual-window tracking** — 5-hour rolling window + weekly window, side by side
- **Independent status lights** — Claude and Codex each show their own title status instead of sharing one color
- **Claude reset countdown** — when Claude's 5h window is exhausted, the title shows how long until it resets
- **Official data sources** — Codex reads the actual `rate_limits` your CLI receives from OpenAI; Claude Code uses [`ccusage`](https://github.com/ryoppippi/ccusage) for token accounting
- **Projection** — see where your 5h window will end at current burn rate
- **Context usage** — for Codex, see how full your current conversation's context window is
- **i18n** — English and Chinese (`AIPULSE_LANG=en|zh`)
- **Themeable** — cyberpunk (default) or mono
- **Graceful degradation** — works if only one of the two tools is installed
- **Privacy** — 100% local, no data ever leaves your Mac

## Screenshot

![AIPulse Screenshot](screenshots/menubar.png)

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

## Upgrade

```bash
cd aipulse
git pull
./install.sh
```

This keeps your existing `~/.config/aipulse/config.sh` intact and refreshes the SwiftBar plugin file in `~/.swiftbar-plugins/`.

After upgrading:
- Click `Refresh` in the AIPulse menu, or restart SwiftBar
- Confirm the footer shows `Version v1.1.0`

## Versioning

- The current release number lives in [`VERSION`](VERSION)
- The SwiftBar plugin metadata mirrors that version in `aipulse.1m.sh`
- User-facing release notes live in [`CHANGELOG.md`](CHANGELOG.md)

For future releases, bump these three places together:
- `VERSION`
- `aipulse.1m.sh` `bitbar.version` and `AIPULSE_VERSION`
- `CHANGELOG.md`

## How it works

### Claude Code

Anthropic does **not publish** exact token limits for Claude Pro/Max subscriptions. AIPulse uses [`ccusage`](https://github.com/ryoppippi/ccusage) with `--token-limit max` — your **highest historical 5-hour window** becomes the 100% baseline. Same approach for the weekly window (highest historical week). This matches what the `ccusage` community has adopted as a pragmatic proxy.

If you know your plan's approximate ceiling (e.g. Max at ~200M tokens per 5h), set `AIPULSE_CC_5H_LIMIT=200000000` for a fixed baseline.

When the Claude 5h window reaches 100%, the title appends a reset countdown like `(1h13m)` based on the active `ccusage` block end time.

The Claude dropdown `Price` also defaults to a local mapping from `AIPULSE_CLAUDE_SUBSCRIPTION`:
- `Pro` -> `$20/mo`
- `Max (5x)` -> `$100/mo`
- `Max (20x)` -> `$200/mo`

If pricing changes later, set `AIPULSE_CLAUDE_PRICE` to override it manually.

### Codex

Codex CLI sessions are stored as JSONL at `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`. Every API response includes a `rate_limits` block from OpenAI showing `primary` (5h) and `secondary` (weekly) percentages directly. AIPulse reads the latest entry — this is **literally** what Codex's internal usage tracker uses.

If the `resets_at` timestamp has passed, the window is marked with `⟳ last X%` (we show 0% until Codex reports fresh data).

The Codex dropdown `Price` defaults to a local mapping from the detected plan, and only uses `AIPULSE_CODEX_PRICE` when you explicitly override it.

## FAQ

**Q: Does this work with Cursor / Aider / Gemini CLI?**
Not yet. AIPulse is designed to be extended — PRs welcome.

**Q: Why does my Claude % sometimes exceed 100%?**
Because the baseline is your historical max. If you set a new record, the app will recalibrate on the next run.

**Q: Why does the title use separate red/green lights for Claude and Codex?**
SwiftBar only supports one text color for the whole title line. AIPulse uses per-tool emoji lights so each provider can show its own state without making the other one look critical.

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
