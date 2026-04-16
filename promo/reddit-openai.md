# r/OpenAI (or r/ChatGPTPro)

**Title:**
AIPulse: macOS menubar monitor for Codex CLI quota — see your 5h and weekly usage % without leaving the terminal

**Body:**

If you use Codex CLI (Pro/Plus), you've probably been rate-limited mid-flow at least once. I built a menubar widget that shows your quota in real time:

```
🤖 12% · 33%
  (5h)  (week)
```

**The cool part:** Codex already writes `rate_limits` with exact percentages in every session JSONL (`~/.codex/sessions/`). AIPulse just reads the latest entry — no API calls, no API keys, no guessing. This is literally what the Codex CLI itself uses internally.

Features:
- 5h rolling window + weekly window, side by side
- Stale detection: if the 5h window has reset, it shows ⟳ instead of a stale number
- Context window usage (how full your current conversation is)
- Reset countdown timers

Also supports Claude Code if you use both tools.

One-line install: `curl -fsSL https://raw.githubusercontent.com/kamiwang777/aipulse/main/install.sh | bash`

GitHub: https://github.com/kamiwang777/aipulse

MIT licensed. Extensible architecture — PRs for Cursor/Aider/Gemini welcome.
