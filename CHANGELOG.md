# Changelog

## [Unreleased]

## [1.1.0] - 2026-04-16

### Added
- Independent title status lights for Claude and Codex
- Claude 5-hour reset countdown in the title and dropdown when the active window is exhausted
- Local subscription details in the dropdown for Claude Code and Codex
- Automatic Codex plan + renewal detection from local auth metadata
- Automatic Claude renewal date inference from local account metadata
- Dropdown summary line: agent name, subscription plan, and days remaining until renewal
- Visible plugin version in the dropdown footer
- Root `VERSION` file for release bookkeeping

### Changed
- Menu bar title text now renders in white for better contrast on dark menu bars
- Claude price now maps locally from the configured subscription plan when not overridden
- Codex price now maps locally from the detected plan when not overridden

### Upgrade notes
- Existing `~/.config/aipulse/config.sh` files remain compatible; new subscription variables are optional
- Refresh SwiftBar after upgrading, or restart SwiftBar if the menu bar does not pick up the new footer version immediately

## [1.0.0] - 2026-04-16

### Added
- Initial release
- Claude Code 5-hour + weekly quota tracking via `ccusage`
- Codex 5-hour + weekly quota tracking via session rate_limits
- i18n: English + Chinese (`AIPULSE_LANG`)
- Themes: cyberpunk + mono (`AIPULSE_THEME`)
- Configurable thresholds, limits, and visibility
- One-line installer (`install.sh`)
- Graceful degradation when only one tool is present
