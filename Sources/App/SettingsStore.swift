import AppKit

extension Notification.Name {
    static let termXSettingsDidChange = Notification.Name("termXSettingsDidChange")
}

enum TerminalThemeMode: String, CaseIterable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

enum TerminalOptionKeyBehavior: String, CaseIterable {
    case escape
    case meta
    case normal

    var title: String {
        switch self {
        case .escape: "Treat option as Escape"
        case .meta: "Treat option as Meta"
        case .normal: "Treat option as Normal"
        }
    }
}

final class SettingsStore {
    static let shared = SettingsStore()

    private enum Key {
        static let fontName = "fontName"
        static let fontSize = "fontSize"
        static let theme = "theme"
        static let scrollbackLines = "scrollbackLines"
        static let bellSound = "bellSound"
        static let visualBell = "visualBell"
        static let optionKeyBehavior = "optionKeyBehavior"
    }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Key.fontName: "Menlo",
            Key.fontSize: 13.0,
            Key.theme: TerminalThemeMode.system.rawValue,
            Key.scrollbackLines: 10_000,
            Key.bellSound: true,
            Key.visualBell: false,
            Key.optionKeyBehavior: TerminalOptionKeyBehavior.normal.rawValue
        ])
    }

    var fontName: String {
        get { defaults.string(forKey: Key.fontName) ?? "Menlo" }
        set { set(newValue, forKey: Key.fontName) }
    }

    var fontSize: CGFloat {
        get {
            let value = defaults.double(forKey: Key.fontSize)
            return value > 0 ? CGFloat(value) : 13
        }
        set { set(Double(min(max(newValue, 10), 24)), forKey: Key.fontSize) }
    }

    var theme: TerminalThemeMode {
        get { TerminalThemeMode(rawValue: defaults.string(forKey: Key.theme) ?? "") ?? .system }
        set { set(newValue.rawValue, forKey: Key.theme) }
    }

    var scrollbackLines: Int {
        get {
            let value = defaults.integer(forKey: Key.scrollbackLines)
            return min(max(value, 1_000), 100_000)
        }
        set { set(min(max(newValue, 1_000), 100_000), forKey: Key.scrollbackLines) }
    }

    var bellSound: Bool {
        get { defaults.object(forKey: Key.bellSound) as? Bool ?? true }
        set { set(newValue, forKey: Key.bellSound) }
    }

    var visualBell: Bool {
        get { defaults.bool(forKey: Key.visualBell) }
        set { set(newValue, forKey: Key.visualBell) }
    }

    var optionKeyBehavior: TerminalOptionKeyBehavior {
        get { TerminalOptionKeyBehavior(rawValue: defaults.string(forKey: Key.optionKeyBehavior) ?? "") ?? .normal }
        set { set(newValue.rawValue, forKey: Key.optionKeyBehavior) }
    }

    var terminalFont: NSFont {
        NSFont(name: fontName, size: fontSize) ?? NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }

    private func set<T: Equatable>(_ value: T, forKey key: String) {
        let current = defaults.object(forKey: key) as? T
        guard current != value else { return }
        defaults.set(value, forKey: key)
        NotificationCenter.default.post(name: .termXSettingsDidChange, object: self)
    }
}
