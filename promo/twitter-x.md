# X / Twitter

**Thread (3 tweets):**

---

**Tweet 1 (hook):**

Built a macOS menubar monitor for Claude Code + Codex quota.

One glance, no surprises:

✦ 20.2% · 40.5%   🤖 12% · 33%

5h window % · weekly %

100% local. Zero API keys. Single bash script.

https://github.com/kamiwang777/aipulse

---

**Tweet 2 (how it works):**

How AIPulse reads your quota:

Claude Code → ccusage parses local session logs, uses your historical peak as 100% baseline (Anthropic doesn't publish exact limits)

Codex → reads the rate_limits % that OpenAI already embeds in every session JSONL. Literally official data.

No network calls. Ever.

---

**Tweet 3 (CTA):**

Features:
- 5h + weekly dual-window tracking
- Burn rate projection
- Color thresholds (green → cyan → yellow → red)
- EN/ZH, cyberpunk/mono themes
- Extensible: PRs welcome for Cursor, Aider, Gemini CLI

Install:
curl -fsSL https://raw.githubusercontent.com/kamiwang777/aipulse/main/install.sh | bash

Star if useful ⭐
