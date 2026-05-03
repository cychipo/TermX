import AppKit

struct TerminalTheme {
    static var windowBackground: NSColor {
        isLightMode ? NSColor.windowBackgroundColor : NSColor(calibratedWhite: 0.10, alpha: 1)
    }

    static var tabBarBackground: NSColor {
        isLightMode ? NSColor(calibratedWhite: 0.88, alpha: 1) : NSColor(calibratedWhite: 0.20, alpha: 1)
    }

    static var selectedTabBackground: NSColor {
        isLightMode ? NSColor(calibratedWhite: 0.98, alpha: 1) : NSColor(calibratedWhite: 0.12, alpha: 1)
    }

    static var terminalBackground: NSColor {
        isLightMode ? NSColor.white : NSColor.black
    }

    static var foreground: NSColor {
        isLightMode ? NSColor(calibratedWhite: 0.10, alpha: 1) : NSColor(calibratedWhite: 0.92, alpha: 1)
    }

    static var mutedForeground: NSColor {
        isLightMode ? NSColor(calibratedWhite: 0.38, alpha: 1) : NSColor(calibratedWhite: 0.68, alpha: 1)
    }

    static var accent: NSColor {
        isLightMode ? NSColor.black : NSColor.white
    }

    static var border: NSColor {
        NSColor(calibratedWhite: isLightMode ? 0.75 : 0, alpha: 0.35)
    }

    static var font: NSFont {
        SettingsStore.shared.terminalFont
    }

    private static var isLightMode: Bool {
        switch SettingsStore.shared.theme {
        case .light:
            return true
        case .dark:
            return false
        case .system:
            return NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .aqua
        }
    }
}
