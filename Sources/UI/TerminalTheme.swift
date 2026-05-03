import AppKit

struct TerminalTheme {
    static var windowBackground: NSColor {
        isLightMode ? NSColor.windowBackgroundColor : NSColor(calibratedRed: 0.13, green: 0.15, blue: 0.14, alpha: 1)
    }

    static var tabBarBackground: NSColor {
        isLightMode ? NSColor(calibratedWhite: 0.88, alpha: 1) : NSColor(calibratedRed: 0.17, green: 0.18, blue: 0.17, alpha: 1)
    }

    static var selectedTabBackground: NSColor {
        isLightMode ? NSColor(calibratedWhite: 0.98, alpha: 1) : NSColor(calibratedRed: 0.12, green: 0.13, blue: 0.13, alpha: 1)
    }

    static var terminalBackground: NSColor {
        isLightMode ? NSColor.white : NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    }

    static var foreground: NSColor {
        isLightMode ? NSColor(calibratedWhite: 0.10, alpha: 1) : NSColor(calibratedWhite: 0.94, alpha: 1)
    }

    static var mutedForeground: NSColor {
        isLightMode ? NSColor(calibratedWhite: 0.38, alpha: 1) : NSColor(calibratedWhite: 0.62, alpha: 1)
    }

    static var accent: NSColor {
        isLightMode ? NSColor.black : NSColor(calibratedWhite: 0.94, alpha: 1)
    }

    static var border: NSColor {
        NSColor(calibratedWhite: isLightMode ? 0.75 : 0.35, alpha: 0.35)
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
