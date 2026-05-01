import AppKit

struct ANSIStyleMapper {
    static let baseFont = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
    static let backgroundColor = NSColor(calibratedWhite: 0.06, alpha: 1)
    static let foregroundColor = NSColor(calibratedWhite: 0.88, alpha: 1)

    static var defaultAttributes: [NSAttributedString.Key: Any] {
        [
            .font: baseFont,
            .foregroundColor: foregroundColor,
            .backgroundColor: backgroundColor
        ]
    }

    static func sanitizedAttributedString(from text: String) -> NSAttributedString {
        let clean = stripANSIEscapeSequences(from: text)
        return NSAttributedString(string: clean, attributes: defaultAttributes)
    }

    private static func stripANSIEscapeSequences(from text: String) -> String {
        var result = ""
        result.reserveCapacity(text.count)
        var iterator = text.makeIterator()

        while let character = iterator.next() {
            guard character == "\u{001B}" else {
                result.append(character)
                continue
            }
            guard iterator.next() == "[" else { continue }
            while let next = iterator.next() {
                if next.isLetter || next == "~" {
                    break
                }
            }
        }
        return result
    }
}
