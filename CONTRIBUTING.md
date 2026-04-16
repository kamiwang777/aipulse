# Contributing to AIPulse

Thanks for your interest! AIPulse is designed to stay tiny and dependency-light, but new **providers** (AI coding tools) are very welcome.

## Adding a new provider

Each provider is a bash function that returns a JSON blob. Look at `fetch_claude` and `fetch_codex` in `aipulse.1m.sh` as templates.

Required output shape (absolute minimum):

```json
{
  "available": true,
  "h5_pct": 12.5,
  "wk_pct": 33.0
}
```

Additional fields are up to you — add them and render them in the dropdown section for your tool.

### Checklist

- [ ] `fetch_yourtool()` function added
- [ ] Rendering section added in the dropdown
- [ ] Logo (emoji) added in the menubar line builder
- [ ] i18n keys added for any new labels
- [ ] `AIPULSE_HIDE_YOURTOOL` config variable added
- [ ] README updated
- [ ] Tested with and without the tool's data files present

## Coding style

- `bash` compatible (not `zsh`-only syntax)
- Parse JSON via `node` one-liners, not `jq` (keeps zero-dep)
- Keep every user-facing string in the `t()` i18n function
- Colors via `theme_color`, never hardcoded

## Localization

Add a new language by extending the `t()` function with a new `case` block. Target: cover every key in the `en` block.

## Testing

Run the plugin directly: `./aipulse.1m.sh`. You should see the SwiftBar-formatted output without errors.

## Questions

Open an issue or discussion on GitHub.
