import AppKit

struct TerminalCell: Equatable {
    var character: Character
    var foregroundColor: NSColor
    var backgroundColor: NSColor
    var isBold: Bool
    var isDim: Bool
    var isItalic: Bool
    var isUnderlined: Bool

    static var empty: TerminalCell {
        TerminalCell(
            character: " ",
            foregroundColor: TerminalTheme.foreground,
            backgroundColor: TerminalTheme.terminalBackground,
            isBold: false,
            isDim: false,
            isItalic: false,
            isUnderlined: false
        )
    }

    var attributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: TerminalTheme.font.pointSize, weight: isBold ? .semibold : .regular),
            .foregroundColor: effectiveForeground,
            .backgroundColor: backgroundColor
        ]
        if isItalic {
            attributes[.obliqueness] = 0.18
        }
        if isUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        return attributes
    }

    func styled(character: Character) -> TerminalCell {
        TerminalCell(
            character: character,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            isBold: isBold,
            isDim: isDim,
            isItalic: isItalic,
            isUnderlined: isUnderlined
        )
    }

    private var effectiveForeground: NSColor {
        isDim ? foregroundColor.blended(withFraction: 0.35, of: backgroundColor) ?? foregroundColor : foregroundColor
    }
}
