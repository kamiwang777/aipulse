# Hacker News — Show HN

**Title:**
Show HN: AIPulse – macOS menubar monitor for Claude Code and Codex quota usage

**URL:**
https://github.com/kamiwang777/aipulse

**Comment (post immediately after submitting):**

Hi HN, I built AIPulse because I kept burning through my Claude Code Max and Codex Pro limits mid-session without realizing it.

It's a SwiftBar plugin that sits in your macOS menu bar and shows the 5-hour rolling window and weekly quota usage for both tools — side by side, one glance.

```
✦ 20.2% · 40.5%   🤖 12% · 33%
```

How it gets the data:

- **Claude Code**: Anthropic doesn't publish exact token limits, so it uses ccusage (by @ryoppippi) with your historical peak as the 100% baseline. Pragmatic but effective.
- **Codex**: Reads the `rate_limits` block that OpenAI already sends back in every session JSONL — this is the actual percentage the server reports.

No API keys needed, no network calls, 100% local file parsing. Single bash script, ~350 lines.

It's designed to be extensible — each tool is a `fetch_*()` function returning JSON. PRs for Cursor, Aider, Gemini CLI, etc. are very welcome.

Config: i18n (en/zh), themes (cyberpunk/mono), custom thresholds, fixed token limits, hide either tool.

Install: `curl -fsSL https://raw.githubusercontent.com/kamiwang777/aipulse/main/install.sh | bash`

Would love feedback — especially if you have ideas for other AI coding tools to support.
