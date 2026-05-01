# Phase 03: Terminal Output Semantics

## Context Links

- Plan: `plans/260501-1052-basic-terminal-functionality/plan.md`
- Current files:
  - `Sources/Core/TerminalBuffer.swift`
  - `Sources/Terminal/TerminalView.swift`
  - `Sources/Terminal/ANSIStyleMapper.swift`

## Overview

- **Priority:** P0
- **Status:** Pending
- **Goal:** Make output look like terminal output, not raw appended chunks.

## Requirements

- Handle CR (`\r`) and LF (`\n`) predictably.
- Strip OSC title sequences fully.
- Support basic ANSI SGR colors enough for `ls`, git output, and simple tests.
- Preserve plain text performance.

## Architecture

MVP parser:

```text
Raw PTY bytes
  → TerminalOutputParser
  → attributed fragments / screen text mutations
  → TerminalView textStorage update
```

Keep parser simple:

- Strip control sequences not supported.
- Implement SGR foreground basic 16 colors.
- Reset on `ESC[0m`.
- Convert CRLF/CR to expected text behavior.

## Implementation Steps

1. Create `Sources/Terminal/TerminalOutputParser.swift` or expand `ANSIStyleMapper` if still small.
2. Handle OSC:
   - `ESC ] ... BEL`
   - `ESC ] ... ESC \\`
3. Handle CSI SGR:
   - 0 reset
   - 1 bold
   - 30-37 foreground
   - 90-97 bright foreground
   - 40-47 background optional
4. Handle `\r` by replacing current line content or normalizing prompt output conservatively.
5. Avoid appending empty control-only chunks.
6. Add a small deterministic parser test path if test target exists; if not, validate manually.

## Todo List

- [ ] Add parser for control sequences and SGR colors.
- [ ] Normalize CR/LF behavior.
- [ ] Keep terminal text readable for common commands.
- [ ] Validate ANSI sample command.

## Success Criteria

- Prompt no longer shows `file://...` title sequence garbage.
- `printf '\\e[31mred\\e[0m normal\\n'` shows red then normal if MVP color is implemented.
- `clear` does not dump weird raw escapes.

## Risks

- Full cursor-addressing support is out of scope; interactive full-screen apps may still be imperfect.
