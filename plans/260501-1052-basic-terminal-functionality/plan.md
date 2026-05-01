---
status: completed
created: 2026-05-01
blockedBy: []
blocks: []
---

# Plan: Basic Terminal Functionality

## Overview

Hoàn thiện chức năng cơ bản nhất để TermX dùng được như terminal tối thiểu: gõ được text, shell nhận input, output sạch, tab hiện rõ để chuyển session, resize đúng PTY, và build/dev workflow ổn định.

## Current Problems

| Problem | Current Symptom | Likely Root Cause |
|---------|-----------------|-------------------|
| Không gõ text được | Nhấn phím không thấy shell phản hồi | `ShellSession` dùng cùng serial queue cho blocking `readLoop` và `write`, làm write bị kẹt sau read |
| Tab không hiện | Không có UI chuyển tab | `tabStyle = .unspecified` ẩn tab toolbar nhưng chưa có custom tab bar thay thế |
| Prompt/output còn thô | Text spacing bất thường, ANSI chưa chuẩn | Output đang append raw chunks, strip ANSI/OSC tối thiểu, chưa xử lý CR/LF theo terminal semantics |
| Resize chưa đúng | PTY size fixed 100x30 | Chưa tính cols/rows từ font metrics + view size |
| Dev workflow còn thiếu | Build cache đã có nhưng README chưa phản ánh đầy đủ | Makefile mới có `open/rerun`, docs cần sync |

## Phases

| Phase | Name | Status | Priority |
|-------|------|--------|----------|
| 01 | Fix PTY Input Pipeline | Completed | P0 |
| 02 | Restore Tab UI & Focus Flow | Completed | P0 |
| 03 | Terminal Output Semantics | Completed | P0 |
| 04 | Resize, Scrollback, and Dev Validation | Completed | P1 |

## Dependencies

- Depends on completed setup plan: `plans/260501-1024-setup-termx-codebase/plan.md`
- No active blocking plans.

## Files to Modify

- `Sources/Core/ShellSession.swift`
- `Sources/Core/PTYManager.swift`
- `Sources/Core/TerminalBuffer.swift`
- `Sources/Terminal/TerminalView.swift`
- `Sources/Terminal/InputHandler.swift`
- `Sources/Terminal/ANSIStyleMapper.swift`
- `Sources/App/MainTabViewController.swift`
- `Sources/App/TerminalTab.swift`
- `Sources/App/MainWindowController.swift`
- `Sources/UI/TerminalContainerView.swift`
- `Sources/UI/TerminalScrollView.swift`
- `Makefile`
- `README.md`
- `docs/DEV.md`

## Success Criteria

- Typing normal characters appears in shell and executes commands.
- Enter, Backspace, arrows, Ctrl+C, Ctrl+D work.
- Multiple tabs can be created, selected, and closed visibly.
- Active tab keeps focus on terminal input.
- Prompt no longer shows OSC/title garbage.
- `pwd`, `echo hello`, `clear`, `ls`, `cat`, `top`/interactive command basics work acceptably.
- Resizing window updates PTY dimensions.
- `make build` succeeds.
- `make dev`, `make open`, `make rerun`, `make run` behavior documented.

## Validation Commands

```bash
make build
make dev
make rerun
```

## Implementation Result

- Fixed PTY input by separating blocking read and write execution paths.
- Added basic keyboard mappings for Enter, Tab, Backspace, arrows, Ctrl+C, Ctrl+D, Ctrl+L.
- Added custom visible tab bar with tab selection and add-tab button.
- Restored terminal focus after tab open/select and on mouse click.
- Added basic ANSI SGR color handling and OSC stripping.
- Replaced scrollback trimming with ring-buffer storage.
- Added resize calculation from terminal view bounds/font metrics.
- Updated README and DEV docs for Makefile dev commands.
- Validation: `make generate && make build` ✅, `make build` ✅.

Manual validation in app:

```bash
pwd
echo hello
ls
printf '\\e[31mred\\e[0m normal\\n'
clear
```

## Risks

- Full VT100/xterm parser is large; do not attempt complete emulator in this plan.
- NSTextView is acceptable for MVP but not final high-performance renderer.
- ANSI color support should be basic and incremental, not a full parser rewrite.

## Handoff

Implement with:

```bash
/cook /Users/tgiap.dev/devs/TermX/plans/260501-1052-basic-terminal-functionality/plan.md --auto
```
