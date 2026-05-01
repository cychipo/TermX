# TermX Development Guide

## Prerequisites

- macOS 13.0+
- Xcode 15+
- XcodeGen 2.40+

## Generate Project

```bash
xcodegen generate --spec project.yml
```

## Build

```bash
xcodebuild \
  -project TermX.xcodeproj \
  -scheme TermX \
  -configuration Debug \
  -derivedDataPath .derived-data \
  build
```

## Current Architecture

```text
Sources/
├── App/        App lifecycle, windows, tabs
├── Core/       PTY manager, shell session, terminal buffer
├── Terminal/   NSTextView rendering and keyboard input mapping
├── UI/         Scroll view wrapper
└── Utils/      Shared utilities

libvtutil/      C bridge for forkpty and PTY resize
Resources/      Info.plist, entitlements, assets
```

## Notes

- Shell sessions use `forkpty` through `libvtutil`.
- Terminal output currently strips ANSI escape sequences before display.
- Future ANSI work should preserve style spans and update only dirty regions.
