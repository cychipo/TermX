# Phase 02: Restore Tab UI & Focus Flow

## Context Links

- Plan: `plans/260501-1052-basic-terminal-functionality/plan.md`
- Current files:
  - `Sources/App/MainTabViewController.swift`
  - `Sources/App/TerminalTab.swift`
  - `Sources/App/MainWindowController.swift`
  - `Sources/UI/TerminalContainerView.swift`

## Overview

- **Priority:** P0
- **Status:** Pending
- **Goal:** Show usable tab controls without returning to the ugly native toolbar style.

## Requirements

- User can see tabs.
- User can click tab to switch sessions.
- Cmd+T opens tab.
- Cmd+W closes current tab.
- Active tab visually distinct.
- Terminal focus restored after tab switch.

## Architecture

Replace hidden native tab chrome with custom AppKit tab bar:

```text
TerminalContainerView
├── CustomTabBarView
│   ├── TabButton(zsh)
│   ├── TabButton(zsh)
│   └── AddButton(+)
└── MainTabViewController.view
```

`MainTabViewController` remains source of truth for tab sessions, but exposes callbacks/state to custom tab bar.

## Implementation Steps

1. Create `Sources/UI/TerminalTabBarView.swift`.
2. Add a light custom tab button style:
   - height 36-40pt
   - rounded selected pill
   - muted inactive text
   - + button with 44x44 hit area
3. Update `MainTabViewController` to notify tab bar after open/close/select.
4. Add APIs:
   - `selectTab(at:)`
   - `currentTerminalView` or `focusCurrentTerminal()`
5. Update `TerminalContainerView` layout: tab bar top, terminal content below.
6. Preserve native menu actions Cmd+T/Cmd+W.
7. Focus terminal after every open/select/close.

## Todo List

- [ ] Add custom tab bar view.
- [ ] Wire tab selection and add tab.
- [ ] Update close behavior.
- [ ] Restore terminal focus after switching.

## Success Criteria

- Two tabs are visible and switchable.
- Active tab style obvious.
- After switching tab, typing goes to selected terminal.

## Risks

- Avoid overbuilding tab drag/reorder in this phase. Visible switch/close/add is enough.
