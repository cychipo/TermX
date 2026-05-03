# Scout Report: Settings/Preferences Feature

## Codebase Scan

### Current State

**TerminalTheme.swift** - Static struct with hardcoded colors/fonts:
```swift
struct TerminalTheme {
    static let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
    static let foreground = NSColor(calibratedWhite: 0.92, alpha: 1)
    static let background = NSColor.black
    // ...
}
```

**ANSIStyleMapper.swift** - Uses TerminalTheme for default styling:
```swift
static let baseFont = TerminalTheme.font
static let backgroundColor = TerminalTheme.terminalBackground
```

**TerminalView.swift** - Configures with ANSIStyleMapper at init:
```swift
backgroundColor = ANSIStyleMapper.backgroundColor
font = ANSIStyleMapper.baseFont
textColor = ANSIStyleMapper.foregroundColor
```

**AppDelegate.swift** - Menu setup with no Preferences entry.

### Findings

1. **SettingsStore needed** - No UserDefaults wrapper exists. Must create one.

2. **Theme integration** - TerminalTheme uses `static let`, must become dynamic via SettingsStore observation.

3. **Menu integration** - AppDelegate.setupMainMenu() needs Preferences entry before Quit.

4. **No existing preferences** - No settings infrastructure at all.

## Recommendations

### High Priority

1. Create `SettingsStore.swift` first - all other components depend on it
2. Refactor `TerminalTheme` to use SettingsStore (or create runtime accessor)
3. Add SettingsWindowController with basic structure

### Medium Priority

4. Implement each tab progressively
5. Wire up menu integration

### Low Priority

6. Add keyboard shortcuts display
7. Future: profile management

## Files to Create/Modify

| Action | File |
|---|---|
| Create | Sources/App/SettingsStore.swift |
| Create | Sources/App/SettingsWindowController.swift |
| Create | Sources/App/SettingsTabViewController.swift |
| Create | Sources/App/AppearanceSettingsViewController.swift |
| Create | Sources/App/TerminalSettingsViewController.swift |
| Create | Sources/App/KeyboardSettingsViewController.swift |
| Modify | Sources/App/AppDelegate.swift - add menu item |
| Modify | Sources/UI/TerminalTheme.swift - dynamic properties |
| Modify | Sources/Terminal/ANSIStyleMapper.swift - use SettingsStore |
| Modify | Sources/Terminal/TerminalView.swift - observe settings changes |

## Summary

**Status:** READY TO IMPLEMENT

Settings infrastructure is minimal - need to create everything from scratch. No blockers identified. The plan covers all essential settings with proper fallback values and sensible defaults.

**Unresolved Questions:**
- Should scrollback apply to existing buffer or only new sessions?
- Visual bell implementation needs InputHandler coordination?