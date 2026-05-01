# Validation Checklist: Basic Terminal Functionality

## Build

```bash
make build
```

Expected: `BUILD SUCCEEDED`.

## Launch

```bash
make dev
```

Expected: app opens without Xcode.

## Input Smoke Test

Inside TermX:

```bash
echo hello
pwd
ls
```

Expected:

- Characters appear as typed.
- Enter executes command.
- Output appears without OSC/title garbage.

## Control Keys

- Backspace deletes previous character.
- Arrow keys move cursor in shell prompt.
- Ctrl+C interrupts `sleep 10`.
- Ctrl+D exits shell or closes session gracefully.

## Tabs

- Cmd+T creates visible tab.
- Click another tab switches session.
- Cmd+W closes selected tab.
- After switching, typing goes into selected tab.

## Resize

- Resize window narrower.
- Run `printf '1234567890%.0s' {1..20}; echo`.
- New output wraps according to current width.

## ANSI

```bash
printf '\e[31mred\e[0m normal\n'
```

Expected: red text if Phase 03 color support is implemented; at minimum no raw escape text.

## Scrollback

```bash
seq 1 2000
```

Expected: app remains responsive and scroll works.

## Unresolved Questions

- Should closing the last tab close the window or create a fresh shell tab?
- Should tabs be reorderable in MVP? Recommendation: no.
