# Research Notes

## Current UI State

- `MainWindowController` uses hidden title and transparent titlebar with `.fullSizeContentView`.
- `TerminalContainerView` creates a custom HUD/glass visual effect and a rounded bordered content card.
- `TerminalTabBarView` implements custom rounded pill tabs and a `+` add button.
- `TerminalTheme` uses a custom dark palette with orange accent.
- `TerminalScrollView` hosts the output `TerminalView` and invisible `TerminalInputView` overlay.

## Target Direction

The requested direction is default macOS Terminal similarity, not a more decorative custom terminal. Favor native AppKit chrome, flatter tabs, a continuous dark terminal surface, compact spacing, and high-contrast monospaced text.

## Design Constraints

- Preserve current terminal functionality and input architecture.
- Keep UI changes focused; do not introduce a theme/profile system.
- Centralize visual tokens in `TerminalTheme` where practical.
- Run build after implementation.
