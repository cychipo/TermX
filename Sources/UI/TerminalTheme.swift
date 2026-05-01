import AppKit

struct TerminalTheme {
    static let windowBackground = NSColor(calibratedRed: 0.055, green: 0.060, blue: 0.065, alpha: 1)
    static let terminalBackground = NSColor(calibratedRed: 0.025, green: 0.027, blue: 0.030, alpha: 0.96)
    static let foreground = NSColor(calibratedRed: 0.88, green: 0.90, blue: 0.92, alpha: 1)
    static let mutedForeground = NSColor(calibratedRed: 0.50, green: 0.54, blue: 0.58, alpha: 1)
    static let accent = NSColor(calibratedRed: 0.95, green: 0.53, blue: 0.23, alpha: 1)
    static let border = NSColor(calibratedWhite: 1, alpha: 0.08)
    static let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
}
