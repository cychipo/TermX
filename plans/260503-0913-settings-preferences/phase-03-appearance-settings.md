# Phase 03: Appearance Settings

## Overview

- **Priority**: High
- **Status**: Pending
- **Brief**: Implement Appearance tab with font selection, font size slider, and theme selector

## Requirements

### Functional

- Font picker: NSFontManager to select monospaced font family
- Font size: NSSlider from 10-24 with current size label
- Theme selector: Segmented control (Light / Dark / System)

### UI Layout (Appearance Tab)

```
┌─────────────────────────────────────────────┐
│ Font                                      │
│ ┌─────────────────────────────────┐ [Select]│
│ │ SF Mono                         │        │
│ └─────────────────────────────────┘        │
│                                              │
│ Font Size: 13  ━━━━━━━●━━━━━━━━━  24        │
│                                              │
│ Theme                                      │
│ ○ Light  ● Dark  ○ System                   │
└─────────────────────────────────────────────┘
```

## Architecture

```
Sources/
├── App/
│   └── AppearanceSettingsViewController.swift   # NEW
```

## Implementation Steps

1. Create `AppearanceSettingsViewController.swift`
   - Subclass NSViewController
   - Add font display label + select button
   - Add font size slider with label
   - Add theme segmented control

2. Connect to SettingsStore for:
   - Reading current font name/size
   - Writing font name/size on change
   - Reading/writing theme preference

3. Add preview section showing sample terminal text with current font

4. Post notification on any setting change so TerminalView updates

## Success Criteria

- Font selector opens font panel with monospaced fonts filtered
- Font size changes immediately update preview
- Theme selection triggers system theme observation (or manual switch)
- Settings persist on OK/Cancel behavior correct