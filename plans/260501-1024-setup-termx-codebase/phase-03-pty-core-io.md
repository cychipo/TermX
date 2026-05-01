# Phase 03: PTY/Core I/O Foundation

## Overview
- **Priority:** P0 (Critical)
- **Status:** Pending
- **Description:** Pseudoterminal setup, shell spawning, I/O streaming (User Stories 1.1, 1.2)

## Key Insights
- Dùng `forkpty()` (via C wrapper) để spawn shell với PTY
- Swift Process/Pipe cho IPC đơn giản hơn nhưng hạn chế ANSI support
- Hybrid approach: C libvtutil cho VT parsing + Swift cho business logic

## Architecture

```
Core/
├── PTYManager.swift        # PTY lifecycle, fork/wait
├── ShellSession.swift      # Shell process wrapper
├── ANSIParser.swift        # Parse ANSI escape codes
├── TerminalBuffer.swift    # Screen buffer (grid of cells)
└── TerminalCell.swift      # Single character cell (char, fg, bg, attrs)
```

## libvtutil (C Bridge)
```
libvtutil/
├── vtutil.h
├── vtutil.c
├── vt_parse.c              # ANSI/VT100 parser
├── vt_parse.h
├── CMakeLists.txt
└── vtutil.pc.in           # pkg-config
```

## Files to Create

### Sources/Core/PTYManager.swift
```swift
class PTYManager {
    let masterFD: Int32
    let slaveFD: Int32
    let pid: pid_t

    init() throws
    func writeToShell(_ data: Data) throws
    func readFromShell() -> Data?
    func resize(cols: Int, rows: Int) throws
    func close()
}
```

### Sources/Core/ShellSession.swift
- Spawn user's default shell (`/bin/zsh` hoặc `$SHELL`)
- Setup environment (TERM=xterm-256color)
- Wire PTY ↔ TerminalView callbacks

### Sources/Core/TerminalBuffer.swift
- 2D grid: `[[TerminalCell]]`
- Scrollback buffer (ring buffer, configurable size)
- Methods: `write()`, `scroll()`, `resize()`

## Implementation Steps

1. [ ] Create libvtutil/ with CMakeLists.txt
2. [ ] Implement vt_parse.c (ANSI parser)
3. [ ] Create Sources/Core/PTYManager.swift
4. [ ] Create Sources/Core/ShellSession.swift
5. [ ] Create Sources/Core/TerminalBuffer.swift
6. [ ] Create bridging header
7. [ ] Integrate với MainTabViewController

## Success Criteria
- Shell spawns automatically on new tab
- Typing sends to shell, output displays
- ANSI colors render correctly
- Window resize triggers PTY resize

## Next Steps
Phase 04 → Terminal View (Text Rendering)
