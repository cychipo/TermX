# Phase 07: Validation

## Overview

- **Priority**: High
- **Status**: Pending
- **Brief**: Build validation and manual testing of settings functionality

## Requirements

### Functional

- `make build` succeeds
- All settings persist across app restarts
- Font changes apply to terminal views
- Theme changes apply correctly
- Settings window opens/closes correctly

## Implementation Steps

1. **Build Validation**
   ```bash
   make build
   ```

2. **Runtime Testing**
   - Open app, verify basic terminal works
   - Open Preferences via Cmd+,
   - Change font to different size, verify preview updates
   - Change theme, verify terminal appearance changes
   - Close preferences, restart app
   - Verify settings persisted

3. **Edge Cases**
   - Invalid font size input → clamp to valid range
   - Window already open → focus existing
   - Theme change → observe system preference changes if system selected

## Success Criteria

- Build completes without errors
- Settings functionality works as designed
- No crashes on settings open/close
- Settings persist correctly