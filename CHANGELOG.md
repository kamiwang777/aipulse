# Changelog

## [Unreleased]

### Added
- Independent title status lights for Claude and Codex
- Claude 5-hour reset countdown in the title and dropdown when the active window is exhausted

### Changed
- Menu bar title text now renders in white for better contrast on dark menu bars

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
