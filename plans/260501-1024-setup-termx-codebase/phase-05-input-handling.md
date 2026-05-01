# Phase 05: Input Handling

## Overview
- **Priority:** P1 (High)
- **Status:** Pending
- **Description:** Keyboard/mouse input, scrollback, resize (User Stories 2.1, 2.2, 2.3)

## Key Insights
- Keyboard input chuyển thành VT sequences
- Mouse tracking via xterm mouse protocol
- Scrollback via NSScrollView wrapper

## Architecture

```
Terminal/
├── InputHandler.swift       # Key → VT sequence mapping
├── MouseHandler.swift      # xterm mouse protocol
└── ScrollbackController.swift

UI/
└── TerminalScrollView.swift  # NSScrollView wrapper
```

## Files to Create

### Sources/Terminal/InputHandler.swift
```swift
class InputHandler {
    static func keyToVTString(_ event: NSEvent) -> String
    static func modifierMask(_ event: NSEvent) -> UInt16
    // Arrow keys, Delete, Home/End, F-keys, etc.
}
```

### Sources/Terminal/MouseHandler.swift
- Support ButtonPress, ButtonRelease, Drag events
- SGR mouse mode (\x1b[?1006h)
- Shift+click for selection override

### Sources/Terminal/ScrollbackController.swift
- Configurable scrollback size (default: 10,000 lines)
- Scroll wheel speed adjustment
- "Scroll to bottom" on new output

## Implementation Steps

1. [ ] Create InputHandler với full key mapping
2. [ ] Wire TerminalView.keyDown → InputHandler → ShellSession
3. [ ] Create TerminalScrollView (NSScrollView wrapper)
4. [ ] Implement scrollback buffer integration
5. [ ] Add mouse support (optional for v1)

## Success Criteria
- All keys work (arrows, delete, fn keys)
- Scroll wheel navigates history
- Window resize reflows text
- Selection works (Cmd+C to copy)

## Next Steps
- Phase 06 → Settings & Preferences
- Phase 07 → Vibrancy & Polish
