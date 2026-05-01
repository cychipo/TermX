# Phase 01: XcodeGen & Project Structure

## Overview
- **Priority:** P0 (Critical)
- **Status:** Pending
- **Description:** Setup XcodeGen config và directory structure cho TermX

## Requirements
- XcodeGen 2.40+ installed
- macOS 13.0+ SDK
- Swift 5.9+

## Architecture

```
TermX/
├── Sources/
│   ├── App/           # main.swift, AppDelegate
│   ├── Core/          # PTY, Shell, ANSI parser
│   ├── Terminal/      # TerminalView, TerminalBuffer
│   ├── UI/            # WindowController, TabController
│   └── Utils/         # Extensions, helpers
├── Resources/         # Assets.xcassets, Entitlements
├── libvtutil/         # C bridge for VT parsing
├── project.yml        # XcodeGen config
└── CMakeLists.txt     # For libvtutil
```

## Files to Create

### project.yml
```yaml
name: TermX
options:
  bundleIdPrefix: com.termx
  deploymentTarget:
    macOS: "13.0"
  xcodeVersion: "15.0"
  generateEmptyDirectories: true

settings:
  base:
    SWIFT_VERSION: "5.9"
    MACOSX_DEPLOYMENT_TARGET: "13.0"
    ENABLE_HARDENED_RUNTIME: YES
    CODE_SIGN_IDENTITY: "-"
    PRODUCT_NAME: TermX

targets:
  TermX:
    type: application
    platform: macOS
    sources:
      - path: Sources
        excludes:
          - "**/.DS_Store"
      - path: Resources
        excludes:
          - "**/.DS_Store"
    settings:
      base:
        INFOPLIST_FILE: Resources/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.termx.app
        COMBINE_HIDPI_IMAGES: YES
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        LD_RUNPATH_SEARCH_PATHS:
          - "@executable_path/../Frameworks"
          - "$(inherited)"
        SWIFT_OBJC_BRIDGING_HEADER: Sources/App/TermX-Bridging-Header.h
    entitlements:
      path: Resources/TermX.entitlements
```

## Implementation Steps

1. [ ] Check XcodeGen installed (`which xcodegen || brew install xcodegen`)
2. [ ] Create directory structure
3. [ ] Create project.yml
4. [ ] Create Info.plist, Entitlements
5. [ ] Create Assets.xcassets with AppIcon
6. [ ] Run `xcodegen generate`
7. [ ] Verify .xcodeproj created

## Success Criteria
- `xcodegen generate` runs without errors
- .xcodeproj opens in Xcode
- Empty app builds and launches

## Next Steps
Phase 02 → App Entry Point & Window Management
