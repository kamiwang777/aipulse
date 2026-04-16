# r/ClaudeAI

**Title:**
I built a macOS menubar widget that shows your Claude Code 5h/weekly quota usage in real-time

**Body:**

I got tired of getting rate-limited mid-session with no warning, so I built **AIPulse** — a tiny SwiftBar menubar plugin that shows your quota % at a glance.

```
✦ 20.2% · 40.5%
  (5h %)   (week %)
```

**How it works:** It uses [ccusage](https://github.com/ryoppippi/ccusage) to parse your local `~/.claude/projects/` session files. Since Anthropic doesn't publish exact token limits for Pro/Max, it uses your historical peak usage as the 100% baseline — same approach the ccusage community uses.

Click the menubar icon to see:
- 5h + weekly progress bars with color thresholds (green → cyan → yellow → red)
- Projected usage at current burn rate
- Burn rate (tokens/min)
- Remaining time in the 5h window
- Models in use
- Dollar cost (optional, can be hidden)

It also supports **Codex** (reads OpenAI's official rate_limits) if you use both tools.

**Zero config, zero network, zero API keys.** Just local file parsing.

Install: `curl -fsSL https://raw.githubusercontent.com/kamiwang777/aipulse/main/install.sh | bash`

GitHub: https://github.com/kamiwang777/aipulse

Supports English + Chinese, cyberpunk/mono themes, configurable thresholds. MIT licensed, PRs welcome.

Would love to know if this is useful to anyone else!
