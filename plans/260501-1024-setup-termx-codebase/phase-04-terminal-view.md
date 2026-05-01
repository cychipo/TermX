# Phase 04: Terminal View (Text Rendering)

## Overview
- **Priority:** P0 (Critical)
- **Status:** Pending
- **Description:** NSTextView-based terminal rendering với ANSI styling (User Story 1.3)

## Key Insights
- NSTextView cho text rendering (built-in font metrics, line breaking)
- Custom NSTextStorage for attributed string management
- VT sequences update NSAttributedString directly

## Architecture

```
Terminal/
├── TerminalView.swift           # NSTextView subclass
├── TerminalTextStorage.swift   # NSTextStorage subclass
├── TerminalLayoutManager.swift # NSTextLayoutManager
├── ANSIStyleMapper.swift       # ANSI codes → NSColor
└── CursorView.swift            # Blinking cursor overlay
```

## Files to Create

### Sources/Terminal/TerminalView.swift
```swift
class TerminalView: NSTextView {
    var terminalBuffer: TerminalBuffer
    var shellSession: ShellSession

    override init(frame frameRect: NSRect)
    func updateDisplay()
    override func keyDown(with event: NSEvent)
    override func mouseDown(with event: NSEvent)
}
```

### Sources/Terminal/ANSIStyleMapper.swift
- Map ANSI color codes (0-255) → NSColor
- Support True Color (24-bit RGB from \x1b[38;2;R;G;Bm)
- Bold, italic, underline, strikethrough attributes

### Sources/Terminal/CursorView.swift
- NSView overlay for cursor
- Block or underline cursor style
- Blink animation (0.5s on, 0.5s off)

## Implementation Steps

1. [ ] Create ANSIStyleMapper.swift (16 + 256 color palette)
2. [ ] Create TerminalTextStorage
3. [ ] Create TerminalView (basic text display)
4. [ ] Wire TerminalView ↔ TerminalBuffer
5. [ ] Implement cursor rendering
6. [ ] Test ANSI colors (ls --color=auto)

## Success Criteria
- Text displays correctly with monospace font
- ANSI colors render (8 standard + 8 bright + 256)
- Cursor visible and blinks
- True Color (24-bit) works

## Next Steps
Phase 05 → Input Handling
