# Phase 04: Resize, Scrollback, and Dev Validation

## Context Links

- Plan: `plans/260501-1052-basic-terminal-functionality/plan.md`
- Current files:
  - `Sources/Core/TerminalBuffer.swift`
  - `Sources/Terminal/TerminalView.swift`
  - `Sources/Core/ShellSession.swift`
  - `Makefile`
  - `README.md`
  - `docs/DEV.md`

## Overview

- **Priority:** P1
- **Status:** Pending
- **Goal:** Make MVP stable under resize/scroll/dev loop.

## Requirements

- Resize window updates PTY cols/rows.
- Scrollback does not use costly `removeFirst` for large buffers.
- Dev commands are documented and cache-friendly.
- Build validation passes.

## Architecture

```text
TerminalView.bounds/font metrics
  → calculate columns/rows
  → ShellSession.resize
  → termx_resize_pty
```

Scrollback:

```text
CircularBuffer<String>
  O(1) append
  bounded memory
```

## Implementation Steps

1. Compute character cell size from `TerminalTheme.font`.
2. On terminal view resize, debounce and call `session.resize(columns:rows:)`.
3. Replace `TerminalBuffer.lines.removeFirst` with ring buffer semantics.
4. Keep rendered NSTextStorage simple for now; buffer is backing storage, not source of truth for full screen redraw yet.
5. Update README/DEV for:
   - `make generate`
   - `make build`
   - `make dev`
   - `make open`
   - `make rerun`
   - `make run`
6. Validate `make build`.
7. Manual app validation checklist.

## Todo List

- [ ] Add resize calculation.
- [ ] Add ring buffer scrollback.
- [ ] Update docs.
- [ ] Run build and manual smoke test.

## Success Criteria

- Window resize updates shell wrapping for new output.
- Large output does not visibly freeze due to buffer trimming.
- `make build` succeeds.
- README and DEV reflect latest Makefile.

## Risks

- Full reflow of historical text is out of scope; only PTY resize for future output is required.
