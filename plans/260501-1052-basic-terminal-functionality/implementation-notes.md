# Implementation Notes: Basic Terminal Functionality

## Root Cause Notes

### Input freeze

Current `ShellSession` runs blocking `readLoop()` on `ioQueue`, then `send()` also dispatches writes to the same queue. Once `readLoop()` starts, writes queued after it cannot run. Fix by separating read/write paths.

### Hidden tabs

`MainTabViewController.tabStyle = .unspecified` hides the ugly native toolbar but provides no replacement UI. Add custom tab bar instead of reverting to `.toolbar`.

### Focus

`TerminalTab.viewDidAppear()` calls `makeFirstResponder`, but focus may be lost after custom container/layout/tab switch. Focus should be explicit after open/select/click.

### Output semantics

ANSI/OSC stripping improved but still not a terminal parser. MVP should parse enough control sequences to avoid raw garbage and basic colors.

## Non-Goals

- Full xterm compatibility.
- GPU renderer.
- Split panes.
- Preferences UI.
- Tab drag/reorder.
- Full-screen TUIs perfect support.

## Recommended Order

1. Fix read/write queue issue first.
2. Add terminal focus fixes.
3. Add custom tab bar.
4. Improve parser output.
5. Add resize/ring buffer.

This order makes the app usable fastest and avoids polishing broken input.
