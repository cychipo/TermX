# Phase 01: Settings Storage

## Overview

- **Priority**: High
- **Status**: Pending
- **Brief**: Create UserDefaults-based SettingsStore with type-safe accessors for all terminal settings

## Requirements

### Functional

- Persist all settings in UserDefaults with sensible defaults
- Support reactive updates (NSUserDefaults observation) so UI reflects changes immediately
- Type-safe Swift interface for settings access

### Settings to implement

| Key | Type | Default |
|---|---|---|
| `fontName` | String | "SF Mono" |
| `fontSize` | Double | 13.0 |
| `theme` | String | "system" (light/dark/system) |
| `scrollbackLines` | Int | 10000 |
| `cursorStyle` | String | "block" (block/underline/bar) |
| `cursorBlink` | Bool | true |
| `bellEnabled` | Bool | true |
| `bellSound` | Bool | true |
| `copyOnSelect` | Bool | true |

## Architecture

```
Sources/
├── App/
│   └── SettingsStore.swift    # NEW - UserDefaults wrapper with Observation
```

## Implementation Steps

1. Create `SettingsStore.swift`
   - `ObservableObject` for SwiftUI or `UserDefaults` observation for AppKit
   - Computed properties with get/set delegating to UserDefaults
   - `UserDefaults.didChangeNotification` observation
   - Notification posting on settings change

2. Register defaults in `AppDelegate.applicationDidFinishLaunching`

3. Add NotificationCenter observers in TerminalView/TerminalTheme to react to changes

## Success Criteria

- SettingsStore compiles without errors
- Settings persist in UserDefaults across app launches
- Settings changes propagate to terminal views