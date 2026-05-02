---
name: terminal-default-ui
description: Restyle TermX to closely match the default macOS Terminal application UI
author: Claude
created: 2026-05-01
status: implemented
blockedBy: []
blocks: []
---

# Terminal Default UI Plan

## Overview

Restyle TermX from the current custom glass/card interface toward the default macOS Terminal look: native window chrome, simple dark terminal surface, compact tab treatment, and minimal decorative effects. This is a visual/UI alignment pass only; terminal core, PTY behavior, IME input, ANSI parsing, and tab functionality should remain unchanged.

## Scope

In scope:

- Make the main window feel closer to macOS Terminal.
- Remove or reduce the current rounded-card/HUD visual treatment.
- Restyle terminal tabs to a flatter native-looking bar.
- Tune terminal colors, font, insets, and scroll view background.
- Build and manually validate the golden path.

Out of scope:

- Preferences UI.
- Full terminal profile/theme system.
- Advanced VT parser/rendering changes.
- Replacing the terminal renderer architecture.

## Phases

| Phase | Status | File | Goal |
|---|---:|---|---|
| 01 | completed | [phase-01-window-chrome-and-container.md](phase-01-window-chrome-and-container.md) | Restore native-feeling window chrome and remove decorative container styling |
| 02 | completed | [phase-02-tabs-terminal-surface-and-theme.md](phase-02-tabs-terminal-surface-and-theme.md) | Match Terminal-like tab bar, terminal surface, font, color, and spacing |
| 03 | completed | [phase-03-validation-and-polish.md](phase-03-validation-and-polish.md) | Build validation completed; manual visual check still needs user confirmation |

## Key Dependencies

- Existing basic terminal functionality plan is complete: [../260501-1052-basic-terminal-functionality/plan.md](../260501-1052-basic-terminal-functionality/plan.md).
- Current UI files are the primary integration points:
  - [Sources/App/MainWindowController.swift](../../Sources/App/MainWindowController.swift)
  - [Sources/UI/TerminalContainerView.swift](../../Sources/UI/TerminalContainerView.swift)
  - [Sources/UI/TerminalTabBarView.swift](../../Sources/UI/TerminalTabBarView.swift)
  - [Sources/UI/TerminalTheme.swift](../../Sources/UI/TerminalTheme.swift)
  - [Sources/UI/TerminalScrollView.swift](../../Sources/UI/TerminalScrollView.swift)

## Success Criteria

- App window visually resembles default macOS Terminal more than the current modern glass/card design.
- Terminal content starts near the window/tab area with Terminal-like padding, not inside a floating rounded card.
- Tabs remain visible, selectable, closable, and addable.
- Terminal typing, Enter, Backspace, Vietnamese IME input, shell output, scrollback, and resize behavior are not regressed.
- `make build` succeeds.
- If possible, app is launched and visually checked via `make dev` or `make rerun`.

## Implementation Command

```bash
/cook plans/260501-1200-terminal-default-ui/plan.md --auto
```
