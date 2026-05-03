---
name: settings-preferences
description: Implement a settings/preferences screen for TermX with font, theme, font size, and other configurable options
author: Claude
created: 2026-05-03
status: implemented
blockedBy: []
blocks: []
---

# Settings/Preferences Feature Plan

## Overview

Add a comprehensive settings/preferences screen to TermX, allowing users to customize terminal appearance and behavior. This includes font settings, theme selection, scrollback options, and other terminal preferences. Settings will be persisted via UserDefaults.

## Scope

In scope:

- Settings window UI with categorized sections
- Font family and size selection
- Theme selection (Light/Dark/System)
- Scrollback buffer size configuration
- Terminal cursor style and blink options
- Sound settings (bell)
- Keyboard shortcuts preferences
- Settings persistence via UserDefaults
- Menu bar "Preferences..." entry

Out of scope:

- Profile management (multiple terminal profiles)
- Advanced VT parser configuration
- Custom theme color editors
- Import/export settings

## Phases

| Phase | Status | File | Goal |
|---|---:|---|---|
| 01 | completed | [phase-01-settings-storage.md](phase-01-settings-storage.md) | Create UserDefaults-based SettingsStore with type-safe accessors |
| 02 | completed | [phase-02-settings-window-ui.md](phase-02-settings-window-ui.md) | Create NSWindow-based SettingsWindowController with tabbed sections |
| 03 | completed | [phase-03-appearance-settings.md](phase-03-appearance-settings.md) | Implement Appearance tab: font, colors, theme |
| 04 | completed | [phase-04-terminal-settings.md](phase-04-terminal-settings.md) | Implement Terminal tab: scrollback and bell settings |
| 05 | completed | [phase-05-keyboard-settings.md](phase-05-keyboard-settings.md) | Implement Keyboard tab: option key behavior and shortcut reference |
| 06 | completed | [phase-06-settings-menu-integration.md](phase-06-settings-menu-integration.md) | Add Preferences menu item and window lifecycle management |
| 07 | completed | [phase-07-validation.md](phase-07-validation.md) | Build validation and app launch completed |

## Key Dependencies

- TerminalTheme.swift - current color/font definitions to refactor
- ANSIStyleMapper.swift - font and color usage that needs to respect settings
- AppDelegate.swift - menu setup that needs Preferences entry

## Success Criteria

- Settings window opens via Cmd+,
- All settings persist across app restarts
- Font changes apply immediately to all terminal views
- Theme changes apply immediately (including system theme detection)
- `make build` succeeds without errors

## Implementation Command

```bash
/cook plans/260503-0913-settings-preferences/plan.md --auto
```

## Reports

- [scout-report.md](reports/scout-report.md) - Codebase scan and recommendations