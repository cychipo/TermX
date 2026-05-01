# Phase 02: App Entry Point & Window Management

## Overview
- **Priority:** P0 (Critical)
- **Status:** Pending
- **Description:** App lifecycle, main window với tab support

## Key Insights
- Dùng AppKit's NSTabViewController cho native tab support (user story 3.1)
- Menu bar cơ bản: File, Edit, View, Terminal, Help
- Window size persistence via UserDefaults

## Architecture

```
App/
├── main.swift              # Entry point (NSApplication.shared)
├── AppDelegate.swift       # App lifecycle, menu setup
├── MainWindowController.swift
├── MainTabViewController.swift
└── TerminalTab.swift       # Per-tab terminal session
```

## Files to Create

### Sources/App/main.swift
```swift
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
```

### Sources/App/AppDelegate.swift
- `applicationDidFinishLaunching` → setup menu, show window
- `applicationShouldTerminateAfterLastWindowClosed` → true
- Menu: New Tab (Cmd+T), Close Tab (Cmd+W), New Window (Cmd+N)

### Sources/App/MainWindowController.swift
- NSWindowController subclass
- Configurable toolbar
- Tab view controller containment

### Sources/App/MainTabViewController.swift
- NSTabViewController
- Track TerminalSession per tab
- Handle tab add/remove/select

## Implementation Steps

1. [ ] Create main.swift
2. [ ] Create AppDelegate.swift với menu bar
3. [ ] Create MainWindowController
4. [ ] Create MainTabViewController
5. [ ] Create placeholder TerminalTab
6. [ ] Build & verify empty window launches

## Success Criteria
- App launches with window
- Cmd+T creates new tab
- Cmd+W closes current tab
- Multiple windows supported

## Next Steps
Phase 03 → PTY/Core I/O Foundation
