# Phase 02: Settings Window UI

## Overview

- **Priority**: High
- **Status**: Pending
- **Brief**: Create NSWindow-based SettingsWindowController with tabbed sections using NSTabView

## Requirements

### Functional

- Settings window with toolbar/tab navigation
- 3 main tabs: Appearance, Terminal, Keyboard
- Window size: ~500x400, resizable
- Window centered on screen on first open

### UI Layout

```
┌─────────────────────────────────────────────┐
│  TermX Settings                    [x][-][+] │
├─────────────────────────────────────────────┤
│  [Appearance] [Terminal] [Keyboard]           │
├─────────────────────────────────────────────┤
│                                             │
│              Tab Content                    │
│                                             │
│                                             │
├─────────────────────────────────────────────┤
│                      [Cancel] [OK]          │
└─────────────────────────────────────────────┘
```

## Architecture

```
Sources/
├── App/
│   └── SettingsWindowController.swift    # NEW
├── UI/
│   └── SettingsTabViewController.swift   # NEW - contains NSTabViewController
```

## Implementation Steps

1. Create `SettingsWindowController.swift`
   - Subclass NSWindowController
   - Create main window with toolbar style
   - Setup closeable/minimizable, not resizable initially

2. Create `SettingsTabViewController.swift`
   - NSTabViewController with 3 child view controllers
   - Each tab contains placeholder view for now

3. Wire up window controller with tab view controller

4. Keep reference to singleton window controller for menu access

## Success Criteria

- Window opens via Cmd+, closes with Escape or Cancel
- Tab switching works
- Basic window chrome matches macOS conventions