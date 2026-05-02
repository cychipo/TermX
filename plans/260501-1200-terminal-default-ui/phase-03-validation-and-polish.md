# Phase 03: Validation and Polish

## Context Links

- Plan: [plan.md](plan.md)
- README dev commands: [../../README.md](../../README.md)
- Makefile commands should be used for validation where possible.

## Overview

Priority: High  
Status: pending

Validate that the UI restyle compiles, launches, resembles default macOS Terminal, and does not regress basic terminal behavior.

## Key Insights

- Project rules require build/compile after code changes.
- UI changes should be checked in the running app when possible.
- Recent work fixed IME/input/rendering issues; validation must include these paths to avoid regressions.

## Requirements

Functional:

- Build succeeds.
- App launches.
- Tabs remain operable.
- Terminal input/output still works.
- Vietnamese IME input should still compose and commit correctly.

Non-functional:

- Manual UI comparison should focus on default macOS Terminal similarity, not a new custom design language.
- Keep any final polish small; avoid expanding scope into preferences/theme systems.

## Architecture

No architectural changes expected in this phase. Only validation and minimal polish if the running app exposes spacing/color issues.

## Related Code Files

Modify only if validation reveals small UI issues:

- [../../Sources/App/MainWindowController.swift](../../Sources/App/MainWindowController.swift)
- [../../Sources/UI/TerminalContainerView.swift](../../Sources/UI/TerminalContainerView.swift)
- [../../Sources/UI/TerminalTabBarView.swift](../../Sources/UI/TerminalTabBarView.swift)
- [../../Sources/UI/TerminalTheme.swift](../../Sources/UI/TerminalTheme.swift)
- [../../Sources/UI/TerminalScrollView.swift](../../Sources/UI/TerminalScrollView.swift)
- [../../Sources/Terminal/TerminalView.swift](../../Sources/Terminal/TerminalView.swift)

Create: none  
Delete: none

## Implementation Steps

1. Run `make build`.
2. If build fails, fix real compile errors and rerun `make build`.
3. Launch app with `make dev` or `make rerun`.
4. Manually validate:
   - app opens with native-feeling window chrome,
   - visual style resembles default macOS Terminal,
   - new tab works,
   - tab switching works,
   - close tab works,
   - terminal typing displays text,
   - Enter executes command,
   - Backspace updates command line,
   - Vietnamese IME input commits correctly,
   - scroll view behaves normally after output.
5. Apply only minimal polish for obvious mismatches.

## Todo List

- [ ] Run `make build`.
- [ ] Launch app.
- [ ] Compare UI against default macOS Terminal reference.
- [ ] Validate tab interactions.
- [ ] Validate terminal input/output and Vietnamese IME path.
- [ ] Report validation result.

## Success Criteria

- `make build` passes.
- Running app has the intended Terminal-like look.
- No regression in core terminal workflow.
- Any unvalidated UI checks are explicitly reported.

## Risk Assessment

- Risk: manual UI validation is not possible in the current environment.
  - Mitigation: report exactly what was built and what still needs human visual confirmation.
- Risk: polish expands scope.
  - Mitigation: restrict edits to direct visual mismatches found during validation.

## Security Considerations

No security impact expected. Avoid logging shell input/output during validation unless separately needed for a bug.

## Next Steps

After validation passes, update plan status/progress if implementation is performed through `/cook`.
