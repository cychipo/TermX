import AppKit

struct ANSIStyleMapper {
    static var baseFont: NSFont { TerminalTheme.font }
    static var backgroundColor: NSColor { TerminalTheme.terminalBackground }
    static var foregroundColor: NSColor { TerminalTheme.foreground }

    static var defaultAttributes: [NSAttributedString.Key: Any] {
        attributes(foregroundColor: foregroundColor, isBold: false)
    }

    static func sanitizedAttributedString(from text: String) -> NSAttributedString {
        let output = NSMutableAttributedString()
        let scalars = Array(text.unicodeScalars)
        var currentColor = foregroundColor
        var isBold = false
        var index = 0
        var plain = String.UnicodeScalarView()
        plain.reserveCapacity(scalars.count)

        func flushPlain() {
            guard !plain.isEmpty else { return }
            output.append(NSAttributedString(
                string: String(plain),
                attributes: attributes(foregroundColor: currentColor, isBold: isBold)
            ))
            plain.removeAll(keepingCapacity: true)
        }

        while index < scalars.count {
            let scalar = scalars[index]
            guard scalar.value == 0x1B else {
                if scalar.value != 0x07 {
                    plain.append(scalar)
                }
                index += 1
                continue
            }

            flushPlain()
            index += 1
            guard index < scalars.count else { break }
            let introducer = scalars[index]

            if introducer == "[" {
                index += 1
                var sequence = ""
                while index < scalars.count {
                    let value = scalars[index].value
                    let character = Character(scalars[index])
                    index += 1
                    if value >= 0x40 && value <= 0x7E {
                        if character == "m" {
                            applySGR(sequence, color: &currentColor, isBold: &isBold)
                        }
                        break
                    }
                    sequence.append(character)
                }
                continue
            }

            if introducer == "]" {
                index = skipOSC(in: scalars, from: index + 1)
                continue
            }
        }

        flushPlain()
        return output
    }

    private static func attributes(foregroundColor: NSColor, isBold: Bool) -> [NSAttributedString.Key: Any] {
        [
            .font: NSFont.monospacedSystemFont(ofSize: TerminalTheme.font.pointSize, weight: isBold ? .semibold : .regular),
            .foregroundColor: foregroundColor,
            .backgroundColor: backgroundColor
        ]
    }

    private static func applySGR(_ sequence: String, color: inout NSColor, isBold: inout Bool) {
        let codes = sequence.split(separator: ";").compactMap { Int($0) }
        let normalizedCodes = codes.isEmpty ? [0] : codes
        for code in normalizedCodes {
            switch code {
            case 0:
                color = foregroundColor
                isBold = false
            case 1:
                isBold = true
            case 30...37:
                color = standardColor(index: code - 30, bright: false)
            case 90...97:
                color = standardColor(index: code - 90, bright: true)
            default:
                continue
            }
        }
    }

    private static func standardColor(index: Int, bright: Bool) -> NSColor {
        let normal: [NSColor] = [
            NSColor(calibratedWhite: 0.25, alpha: 1),
            NSColor(calibratedRed: 0.82, green: 0.20, blue: 0.25, alpha: 1),
            NSColor(calibratedRed: 0.24, green: 0.70, blue: 0.34, alpha: 1),
            NSColor(calibratedRed: 0.86, green: 0.64, blue: 0.24, alpha: 1),
            NSColor(calibratedRed: 0.34, green: 0.56, blue: 0.94, alpha: 1),
            NSColor(calibratedRed: 0.72, green: 0.42, blue: 0.88, alpha: 1),
            NSColor(calibratedRed: 0.30, green: 0.76, blue: 0.78, alpha: 1),
            foregroundColor
        ]
        let brightColors: [NSColor] = [
            TerminalTheme.mutedForeground,
            NSColor(calibratedRed: 1.00, green: 0.36, blue: 0.40, alpha: 1),
            NSColor(calibratedRed: 0.39, green: 0.91, blue: 0.50, alpha: 1),
            NSColor(calibratedRed: 1.00, green: 0.78, blue: 0.34, alpha: 1),
            NSColor(calibratedRed: 0.51, green: 0.69, blue: 1.00, alpha: 1),
            NSColor(calibratedRed: 0.85, green: 0.55, blue: 1.00, alpha: 1),
            NSColor(calibratedRed: 0.45, green: 0.93, blue: 0.95, alpha: 1),
            NSColor.white
        ]
        return (bright ? brightColors : normal)[max(0, min(index, 7))]
    }

    private static func skipOSC(in scalars: [UnicodeScalar], from start: Int) -> Int {
        var index = start
        while index < scalars.count {
            let value = scalars[index].value
            if value == 0x07 {
                return index + 1
            }
            if value == 0x1B, index + 1 < scalars.count, scalars[index + 1] == "\\" {
                return index + 2
            }
            index += 1
        }
        return index
    }
}
