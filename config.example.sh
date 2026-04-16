# AIPulse configuration
# Copy to ~/.config/aipulse/config.sh and edit.
#
# Uses ":=" conditional assignment so environment variables still win:
#     AIPULSE_LANG=zh ./aipulse.1m.sh   ← one-off override
# To hard-set a value, remove the ":=" and use plain "=".

# ---- Language: en | zh ----
: "${AIPULSE_LANG:=en}"

# ---- Theme: cyberpunk | mono ----
: "${AIPULSE_THEME:=cyberpunk}"

# ---- Hide a tool you don't use (1 = hide) ----
: "${AIPULSE_HIDE_CLAUDE:=0}"
: "${AIPULSE_HIDE_CODEX:=0}"

# ---- Claude Code token limits ----
# "max" = historical peak from your local ccusage data (recommended).
# Or a number in tokens, e.g. 200000000 for 200M.
: "${AIPULSE_CC_5H_LIMIT:=max}"
: "${AIPULSE_CC_WEEK_LIMIT:=max}"

# ---- Optional subscription details shown in the dropdown ----
# Leave blank if you do not want to show them.
# Claude price auto-maps from AIPULSE_CLAUDE_SUBSCRIPTION when left blank:
# Pro -> $20/mo, Max (5x) -> $100/mo, Max (20x) -> $200/mo
: "${AIPULSE_CLAUDE_SUBSCRIPTION:=}"
: "${AIPULSE_CLAUDE_PRICE:=}"
: "${AIPULSE_CLAUDE_RENEWS:=}"
# Codex price auto-maps from the detected plan when left blank.
: "${AIPULSE_CODEX_SUBSCRIPTION:=}"
: "${AIPULSE_CODEX_PRICE:=}"
: "${AIPULSE_CODEX_RENEWS:=}"

# ---- Color thresholds (%) ----
: "${AIPULSE_THRESH_INFO:=50}"     # below = green, above = cyan
: "${AIPULSE_THRESH_WARN:=70}"     # above = yellow
: "${AIPULSE_THRESH_DANGER:=90}"   # above = red

# ---- Show dollar figures ----
: "${AIPULSE_SHOW_COST:=1}"

# ---- Binary overrides (uncomment if needed) ----
# : "${AIPULSE_NPX_BIN:=/opt/homebrew/bin/npx}"

export AIPULSE_LANG AIPULSE_THEME AIPULSE_HIDE_CLAUDE AIPULSE_HIDE_CODEX \
       AIPULSE_CC_5H_LIMIT AIPULSE_CC_WEEK_LIMIT \
       AIPULSE_CLAUDE_SUBSCRIPTION AIPULSE_CLAUDE_PRICE AIPULSE_CLAUDE_RENEWS \
       AIPULSE_CODEX_SUBSCRIPTION AIPULSE_CODEX_PRICE AIPULSE_CODEX_RENEWS \
       AIPULSE_THRESH_INFO AIPULSE_THRESH_WARN AIPULSE_THRESH_DANGER \
       AIPULSE_SHOW_COST
