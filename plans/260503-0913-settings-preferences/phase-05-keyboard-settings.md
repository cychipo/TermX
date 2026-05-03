# Phase 05: Keyboard Settings

## Overview

- **Priority**: Low
- **Status**: Pending
- **Brief**: Implement Keyboard tab with option key behavior and key mappings

## Requirements

### Functional

- Option key mapping: Treat option as Escape / Normal / Meta
- Copy/Paste shortcuts display (informational)
- Option key behavior selection via popup button

### UI Layout (Keyboard Tab)

```
┌─────────────────────────────────────────────┐
│ Option Key (⌥) Behavior                    │
│ ┌─────────────────────────────────┐         │
│ │ Treat option as Escape      ▼   │         │
│ └─────────────────────────────────┘         │
│                                              │
│ Key mappings (informational):               │
│ ┌─────────────────────────────────┐         │
│ │ Copy            ⌘C              │         │
│ │ Paste           ⌘V              │         │
│ │ Select All      ⌘A              │         │
│ │ Find            ⌘F              │         │
│ └─────────────────────────────────┘         │
└─────────────────────────────────────────────┘
```

## Architecture

```
Sources/
├── App/
│   └── KeyboardSettingsViewController.swift   # NEW
```

## Implementation Steps

1. Create `KeyboardSettingsViewController.swift`

2. Add option key behavior:
   - NSPopUpButton with 3 options:
     - "Treat option as Escape"
     - "Treat option as Meta"
     - "Treat option as normal"
   - Connect to SettingsStore

3. Add key mappings table:
   - NSTableView (read-only) showing current shortcuts
   - Hardcoded for now, no editing UI

4. Future expansion point for custom keybindings

## Success Criteria

- Option key behavior selectable and persisted
- Shortcut reference table visible
- Settings apply to keyboard input handling