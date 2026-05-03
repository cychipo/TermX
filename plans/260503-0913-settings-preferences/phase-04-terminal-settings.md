# Phase 04: Terminal Settings

## Overview

- **Priority**: Medium
- **Status**: Pending
- **Brief**: Implement Terminal tab with scrollback, cursor, and bell options

## Requirements

### Functional

- Scrollback lines: NSStepper with text field (1000-100000)
- Cursor style: Segmented control (Block / Underline / Bar)
- Cursor blink: NSSwitch toggle
- Bell: NSSwitch toggles (Visual bell, Audio bell)

### UI Layout (Terminal Tab)

```
┌─────────────────────────────────────────────┐
│ Scrollback                                │
│ Lines: [10000    ] [+][-]                   │
│                                              │
│ Cursor                                     │
│ Style: [Block] [Underline] [Bar]            │
│ Blink:  ○────                              │
│                                              │
│ Bell                                       │
│ Audio bell:  ○────                          │
│ Visual bell: ○────                          │
└─────────────────────────────────────────────┘
```

## Architecture

```
Sources/
├── App/
│   └── TerminalSettingsViewController.swift   # NEW
```

## Implementation Steps

1. Create `TerminalSettingsViewController.swift`

2. Add scrollback section:
   - NSTextField for number input
   - NSStepper for increment/decrement
   - Validation for range 1000-100000

3. Add cursor section:
   - NSSegmentedControl for cursor style
   - NSSwitch for cursor blink

4. Add bell section:
   - NSSwitch for audio bell
   - NSSwitch for visual bell (flashes window)

5. Connect to SettingsStore

6. Add terminal bell action:
   - If audio bell: NSSound.beep()
   - If visual bell: flash window title

## Success Criteria

- Scrollback setting persists and applies to new terminal sessions
- Cursor style change immediately visible
- Bell settings work as expected