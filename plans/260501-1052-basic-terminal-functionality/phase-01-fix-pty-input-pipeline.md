# Phase 01: Fix PTY Input Pipeline

## Context Links

- Plan: `plans/260501-1052-basic-terminal-functionality/plan.md`
- Current files:
  - `Sources/Core/ShellSession.swift`
  - `Sources/Core/PTYManager.swift`
  - `Sources/Terminal/TerminalView.swift`
  - `Sources/Terminal/InputHandler.swift`

## Overview

- **Priority:** P0
- **Status:** Pending
- **Goal:** Make typing reach the shell reliably.

## Key Insight

`ShellSession.start()` dispatches `readLoop()` onto the same serial `ioQueue` used by `send()`. Because `readLoop()` blocks on `read`, later `send()` tasks may never execute. This matches the observed "không gõ text được" issue.

## Requirements

- Read loop must not block writes.
- Writes should be immediate and thread-safe.
- Terminal view must become first responder when clicked/shown.
- Basic key sequences must map correctly.

## Architecture

Use separate paths:

```text
TerminalView.keyDown
  → InputHandler.sequence
  → ShellSession.send
  → PTYManager.write

PTY read source / background read queue
  → ShellSessionDelegate.didReceive
  → TerminalView.append
```

Recommended implementation:

- Keep one read queue for blocking read.
- Use one write queue or direct lock-protected write for writes.
- Optional: use `DispatchSourceRead` on master FD if simpler after setting nonblocking FD.

## Implementation Steps

1. Replace single serial `ioQueue` design in `ShellSession`.
2. Add `readQueue` and `writeQueue`, or convert PTY FD to `DispatchSourceRead`.
3. Ensure `send(_:)` never waits behind `readLoop()`.
4. Add input mappings:
   - Enter → `\r`
   - Backspace/Delete → `\u{7F}`
   - Ctrl+C → ETX `\u{3}`
   - Ctrl+D → EOT `\u{4}`
   - Tab → `\t`
5. In `TerminalView`, override `mouseDown` and `viewDidMoveToWindow`/focus path so click and tab selection make it first responder.
6. Build and manually test `echo hello`.

## Todo List

- [ ] Refactor shell read/write queues.
- [ ] Update input mapping for control keys.
- [ ] Ensure terminal focus on click/show/tab selection.
- [ ] Validate normal typing and Enter.

## Success Criteria

- Typing appears and shell commands execute.
- `Ctrl+C` interrupts running command.
- Backspace deletes in shell prompt.

## Risks

- Writing to closed FD can throw; surface error in terminal and close session cleanly.
