# Phase 06: Settings Menu Integration

## Overview

- **Priority**: High
- **Status**: Pending
- **Brief**: Add Preferences menu item, wire up window lifecycle, and ensure SettingsStore integration

## Requirements

### Functional

- Add Preferences menu item under TermX menu (before Quit)
- Cmd+, keyboard shortcut opens settings window
- Window singleton (reuses existing if open)
- Settings apply live on change, not just on OK

## Implementation Steps

1. Update `AppDelegate.setupMainMenu()`:
   - Add Preferences menu item with Cmd+, shortcut
   - Add separator before Quit

2. Add `@objc func openPreferences(_ sender: Any?)` to AppDelegate

3. Update `SettingsWindowController`:
   - Make it a singleton or track instance in AppDelegate
   - Implement `showWindow()` override to reuse existing window

4. Handle window close:
   - Close window on Cancel button
   - Changes should apply live (no OK button needed, or OK just hides)

5. Remove "About TermX" separator and place Preferences before Quit:
   ```
   TermX
   ├── About TermX
   ├── ─────────────
   ├── Preferences...         ← Cmd+
   ├── ─────────────
   └── Quit TermX             ← Cmd+Q
   ```

## Success Criteria

- Cmd+, opens settings window
- Clicking Preferences when window open focuses existing window
- Window title shows "Settings" or "Preferences"
- Escape key closes window