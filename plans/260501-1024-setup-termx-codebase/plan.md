# Plan: TermX macOS Terminal - Setup Codebase

## Overview
**Status:** Completed  
**Date:** 2026-05-01  
**Type:** Project Setup  

Setup codebase foundation cho TermX - native macOS terminal emulator. Dựa trên user stories với 3 epic chính: Core I/O, Screen/Keyboard, macOS UI.

## Scope
- XcodeGen project config (project.yml)
- App entry point (AppDelegate, main.swift)
- Core models (TerminalSession, PTY, etc.)
- Basic AppKit window/tab structure
- CMakeLists cho C/C++ bridging (libvtutil)

## Phases
| Phase | Name | Status |
|-------|------|--------|
| 01 | XcodeGen & Project Structure | ✅ |
| 02 | App Entry Point & Window Management | ✅ |
| 03 | PTY/Core I/O Foundation | ✅ |
| 04 | Terminal View (Text Rendering) | ✅ |
| 05 | Input Handling (Keyboard/Mouse) | ✅ |

## Key Tech Decisions
- **UI:** AppKit (NSTextView-based rendering)
- **PTY:** Swift Process/Pipe + C wrapper (libvtutil)
- **Language:** Swift 5.9+
- **Build:** XcodeGen + CMake (hybrid)
- **Target:** macOS 13.0+

## Blockers
None - green field project.

## Validation
- `xcodegen generate --spec /Users/tgiap.dev/devs/TermX/project.yml` ✅
- `xcodebuild -project /Users/tgiap.dev/devs/TermX/TermX.xcodeproj -scheme TermX -configuration Debug -derivedDataPath /Users/tgiap.dev/devs/TermX/.derived-data build` ✅

## Next Steps
- Improve ANSI parser to preserve colors instead of stripping escape sequences.
- Add ring-buffer implementation that avoids `removeFirst` for large scrollback.
- Add automated tests for input mapping and buffer behavior.
