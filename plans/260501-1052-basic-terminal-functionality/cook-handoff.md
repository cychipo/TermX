# Cook Handoff

## Command

```bash
/cook /Users/tgiap.dev/devs/TermX/plans/260501-1052-basic-terminal-functionality/plan.md --auto
```

## Priority

Implement Phase 01 and Phase 02 first. Do not spend time on advanced ANSI or renderer work until typing and tab switching are fixed.

## Acceptance Gate

Do not mark complete unless:

- User can type `echo hello` and see output.
- Cmd+T shows a second visible tab.
- Clicking tabs switches sessions.
- `make build` succeeds.

## Manual Smoke Test

Use `validation-checklist.md`.
