import AppKit

struct TerminalCell: Equatable {
    var character: Character
    var foregroundColor: NSColor
    var backgroundColor: NSColor
    var isBold: Bool
    var isUnderlined: Bool

    static let empty = TerminalCell(
        character: " ",
        foregroundColor: .textColor,
        backgroundColor: .textBackgroundColor,
        isBold: false,
        isUnderlined: false
    )
}
