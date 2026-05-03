# 2026-05-03 Settings Preferences

Implemented TermX Preferences from `plans/260503-0913-settings-preferences/plan.md`.

## Key Changes

- Added `SettingsStore` backed by `UserDefaults` for font, theme, scrollback, bell, and option-key behavior.
- Added AppKit Preferences window with Appearance, Terminal, and Keyboard tabs.
- Added `Cmd+,` Preferences menu integration.
- Made terminal font/theme settings apply live to open terminal views.
- Applied scrollback line count to new terminal buffers.
- Added audio/visual bell behavior and option-key handling.
- Updated `docs/DEV.md` with Preferences usage.

## Validation

- Regenerated Xcode project after adding Swift files.
- `make build` succeeded.
- `make rerun` opened the built app.

## Notes

- Cursor style/blink and editable custom shortcut mapping were deferred because current renderer does not expose cursor drawing state yet.
- `libvtutil/vtutil.c` had pre-existing changes from the prior cwd fix and was not part of this implementation.
