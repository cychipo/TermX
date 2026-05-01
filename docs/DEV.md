# TermX Development Guide

## Prerequisites

- macOS 13.0+
- Xcode 15+
- XcodeGen 2.40+

## Common Commands

Generate Xcode project after changing `project.yml`:

```bash
make generate
```

Build with Xcode incremental cache in `.derived-data`:

```bash
make build
```

Build then open app:

```bash
make dev
```

Run the app binary directly to see stdout/stderr logs:

```bash
make run
```

Open the last built app without rebuilding:

```bash
make open
```

Restart the last built app without rebuilding:

```bash
make rerun
```

Clean local build output:

```bash
make clean
```

## Current Architecture

```text
Sources/
├── App/        App lifecycle, windows, tabs
├── Core/       PTY manager, shell session, terminal buffer
├── Terminal/   NSTextView rendering and keyboard input mapping
├── UI/         AppKit wrappers and tab UI
└── Utils/      Shared utilities

libvtutil/      C bridge for forkpty and PTY resize
Resources/      Info.plist, entitlements, assets
```

## Notes

- Shell sessions use `forkpty` through `libvtutil`.
- Shell reads and writes must stay on separate execution paths because PTY reads block.
- `MainTabViewController` owns terminal sessions; `TerminalTabBarView` is only presentation.
- ANSI support is intentionally incremental: basic SGR colors first, full xterm compatibility later.
- Keep `.derived-data/` ignored and local for Xcode build cache.
