# Phase 01: Window Chrome and Container

## Context Links

- Plan: [plan.md](plan.md)
- Window controller: [../../Sources/App/MainWindowController.swift](../../Sources/App/MainWindowController.swift)
- Container view: [../../Sources/UI/TerminalContainerView.swift](../../Sources/UI/TerminalContainerView.swift)
- Theme tokens: [../../Sources/UI/TerminalTheme.swift](../../Sources/UI/TerminalTheme.swift)

## Overview

Priority: High  
Status: pending

Move TermX away from a custom floating-card/glass look and toward the default macOS Terminal structure: native titlebar/window feel, continuous terminal background, and minimal custom decoration.

## Key Insights

- Current `MainWindowController` hides the title and uses a transparent titlebar.
- Current `TerminalContainerView` applies `.hudWindow` material, rounded corners, border, and large outer margins.
- Default Terminal is visually simpler: titlebar/tabs above a continuous dark terminal surface, not a rounded panel floating inside the window.

## Requirements

Functional:

- Preserve window resize, close, minimize, and tab behavior.
- Preserve `MainTabViewController.openNewTab()` startup behavior.
- Keep `TerminalContainerView` as the host unless removing it clearly simplifies the code without creating churn.

Non-functional:

- Prefer native AppKit window behavior over custom chrome.
- Keep changes small and reversible.
- Avoid changing PTY, renderer, or input code in this phase.

## Architecture

`MainWindowController` remains responsible for window setup. `TerminalContainerView` remains responsible for arranging the tab bar and terminal content, but its visual role should be reduced from decorative shell to plain layout host.

## Related Code Files

Modify:

- [../../Sources/App/MainWindowController.swift](../../Sources/App/MainWindowController.swift)
- [../../Sources/UI/TerminalContainerView.swift](../../Sources/UI/TerminalContainerView.swift)
- [../../Sources/UI/TerminalTheme.swift](../../Sources/UI/TerminalTheme.swift)

Create: none  
Delete: none

## Implementation Steps

1. Review the current screenshot and default macOS Terminal reference visually before editing.
2. In `MainWindowController`, prefer native titlebar behavior:
   - consider showing the title again or using less transparent titlebar styling,
   - keep standard traffic-light controls,
   - keep `.fullSizeContentView` only if it still matches the target visual.
3. In `TerminalContainerView`, remove or minimize:
   - `.hudWindow` material,
   - rounded content card radius,
   - decorative border,
   - large outer margins.
4. Make the content area fill the window more directly below the tab/title region.
5. Keep background colors aligned through `TerminalTheme`, not scattered raw colors.

## Todo List

- [ ] Adjust window titlebar settings toward native Terminal behavior.
- [ ] Simplify `TerminalContainerView` material/background.
- [ ] Remove floating card visual treatment.
- [ ] Verify tab controller still opens initial tab.

## Success Criteria

- Window no longer looks like a rounded glass/card app.
- Terminal area feels attached to the native window chrome.
- Window controls and resizing still work.

## Risk Assessment

- Risk: changing titlebar transparency may affect layout height.
  - Mitigation: run app and resize window after changes.
- Risk: removing container styling may expose background mismatch.
  - Mitigation: centralize colors in `TerminalTheme`.

## Security Considerations

No security impact expected. Do not alter shell process, PTY bytes, or command execution.

## Next Steps

Proceed to tab bar and terminal surface restyling in Phase 02.
