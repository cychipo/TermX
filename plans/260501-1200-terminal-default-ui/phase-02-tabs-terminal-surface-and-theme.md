# Phase 02: Tabs, Terminal Surface, and Theme

## Context Links

- Plan: [plan.md](plan.md)
- Tab bar: [../../Sources/UI/TerminalTabBarView.swift](../../Sources/UI/TerminalTabBarView.swift)
- Scroll view: [../../Sources/UI/TerminalScrollView.swift](../../Sources/UI/TerminalScrollView.swift)
- Terminal renderer: [../../Sources/Terminal/TerminalView.swift](../../Sources/Terminal/TerminalView.swift)
- Theme tokens: [../../Sources/UI/TerminalTheme.swift](../../Sources/UI/TerminalTheme.swift)

## Overview

Priority: High  
Status: pending

Restyle visible tabs, terminal background, font, text color, and padding so the app resembles default macOS Terminal while preserving existing tab operations and input routing.

## Key Insights

- Current `TerminalTabBarView` uses rounded pill tabs with generous spacing.
- Current terminal surface uses a near-black custom theme, but the surrounding card treatment makes it feel unlike default Terminal.
- `TerminalInputView` is an overlay input receiver; UI changes must not hide, remove, or break first-responder routing.

## Requirements

Functional:

- Keep add tab, close tab, select tab behavior working.
- Keep `TerminalTab.focusTerminal()` behavior working after tab selection.
- Keep terminal input overlay covering the scroll view.
- Keep scrollbars native overlay style.

Non-functional:

- Use a compact, native-looking tab bar.
- Use high contrast foreground/background.
- Keep terminal font monospaced and readable.
- Avoid raw color duplication outside `TerminalTheme` where practical.

## Architecture

`TerminalTabBarView` remains the custom visible tab bar for now. This avoids a larger migration to native AppKit tab UI while still allowing a Terminal-like appearance. `TerminalTheme` should expose the visual tokens needed by tab bar, scroll view, and terminal text.

## Related Code Files

Modify:

- [../../Sources/UI/TerminalTabBarView.swift](../../Sources/UI/TerminalTabBarView.swift)
- [../../Sources/UI/TerminalTheme.swift](../../Sources/UI/TerminalTheme.swift)
- [../../Sources/UI/TerminalScrollView.swift](../../Sources/UI/TerminalScrollView.swift)
- [../../Sources/Terminal/TerminalView.swift](../../Sources/Terminal/TerminalView.swift)

Create: none  
Delete: none

## Implementation Steps

1. Tune `TerminalTheme` toward default Terminal:
   - black or near-black terminal background,
   - near-white foreground,
   - muted gray inactive text,
   - subtle native separator color,
   - System monospaced font at a Terminal-like size.
2. Restyle `TerminalTabBarView`:
   - reduce height if needed,
   - remove pill/card tab shape,
   - use flat selected state and subtle separators,
   - keep close button discoverable but visually quiet,
   - keep add button simple and native-looking.
3. Adjust `TerminalScrollView` and `TerminalView` spacing:
   - reduce oversized inset if it differs from default Terminal,
   - keep enough top/left padding for readability,
   - ensure background is consistent across scroll view and text view.
4. Confirm the invisible input overlay still receives focus after clicking terminal content.

## Todo List

- [ ] Tune `TerminalTheme` colors and font.
- [ ] Restyle tab bar to a flat Terminal-like look.
- [ ] Adjust terminal content inset and scroll view content inset.
- [ ] Recheck first-responder routing after UI changes.

## Success Criteria

- Tabs are visible and closer to macOS Terminal than the current rounded pill design.
- Terminal background is visually continuous and dark.
- Text remains clearly visible with sufficient contrast.
- Typing and tab switching still work.

## Risk Assessment

- Risk: making the input overlay visually or interactively incorrect.
  - Mitigation: do not change `TerminalInputView`; only verify its frame and focus behavior.
- Risk: lowering padding too far hurts readability.
  - Mitigation: compare visually against default Terminal and keep small readable margins.

## Security Considerations

No security impact expected. This phase changes visual styling and layout only.

## Next Steps

Proceed to build/manual validation in Phase 03.
