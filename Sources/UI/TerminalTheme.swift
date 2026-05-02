import AppKit

struct TerminalTheme {
    static let windowBackground = NSColor.windowBackgroundColor
    static let tabBarBackground = NSColor(calibratedWhite: 0.20, alpha: 1)
    static let selectedTabBackground = NSColor(calibratedWhite: 0.12, alpha: 1)
    static let terminalBackground = NSColor.black
    static let foreground = NSColor(calibratedWhite: 0.92, alpha: 1)
    static let mutedForeground = NSColor(calibratedWhite: 0.68, alpha: 1)
    static let accent = NSColor.white
    static let border = NSColor(calibratedWhite: 0, alpha: 0.35)
    static let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
}
