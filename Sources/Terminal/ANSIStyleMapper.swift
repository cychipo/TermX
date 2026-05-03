import AppKit

struct ANSIStyleMapper {
    static var baseFont: NSFont { TerminalTheme.font }
    static var backgroundColor: NSColor { TerminalTheme.terminalBackground }
    static var foregroundColor: NSColor { TerminalTheme.foreground }

    static var defaultAttributes: [NSAttributedString.Key: Any] {
        StyleState().attributes
    }

    static func sanitizedAttributedString(from text: String) -> NSAttributedString {
        let output = NSMutableAttributedString()
        let scalars = Array(text.unicodeScalars)
        var state = StyleState()
        var index = 0
        var plain = String.UnicodeScalarView()
        plain.reserveCapacity(scalars.count)

        func flushPlain() {
            guard !plain.isEmpty else { return }
            output.append(NSAttributedString(string: String(plain), attributes: state.attributes))
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
                            state.applySGR(sequence)
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

    private struct StyleState {
        var foreground = ANSIStyleMapper.foregroundColor
        var background = ANSIStyleMapper.backgroundColor
        var isBold = false
        var isDim = false
        var isItalic = false
        var isUnderline = false

        var attributes: [NSAttributedString.Key: Any] {
            var attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: effectiveForeground,
                .backgroundColor: background
            ]
            if isUnderline {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            if isItalic {
                attributes[.obliqueness] = 0.18
            }
            return attributes
        }

        mutating func applySGR(_ sequence: String) {
            let codes = parseCodes(sequence)
            var index = 0
            while index < codes.count {
                let code = codes[index]
                switch code {
                case 0:
                    self = StyleState()
                case 1:
                    isBold = true
                    isDim = false
                case 2:
                    isDim = true
                case 3:
                    isItalic = true
                case 4:
                    isUnderline = true
                case 22:
                    isBold = false
                    isDim = false
                case 23:
                    isItalic = false
                case 24:
                    isUnderline = false
                case 30...37:
                    foreground = ANSIStyleMapper.standardColor(index: code - 30, bright: false)
                case 38:
                    if let resolved = ANSIStyleMapper.extendedColor(codes: codes, index: &index) {
                        foreground = resolved
                    }
                case 39:
                    foreground = ANSIStyleMapper.foregroundColor
                case 40...47:
                    background = ANSIStyleMapper.standardColor(index: code - 40, bright: false)
                case 48:
                    if let resolved = ANSIStyleMapper.extendedColor(codes: codes, index: &index) {
                        background = resolved
                    }
                case 49:
                    background = ANSIStyleMapper.backgroundColor
                case 90...97:
                    foreground = ANSIStyleMapper.standardColor(index: code - 90, bright: true)
                case 100...107:
                    background = ANSIStyleMapper.standardColor(index: code - 100, bright: true)
                default:
                    break
                }
                index += 1
            }
        }

        private var font: NSFont {
            NSFont.monospacedSystemFont(ofSize: TerminalTheme.font.pointSize, weight: isBold ? .semibold : .regular)
        }

        private var effectiveForeground: NSColor {
            isDim ? foreground.blended(withFraction: 0.35, of: background) ?? foreground : foreground
        }

        private func parseCodes(_ sequence: String) -> [Int] {
            let normalized = sequence.replacingOccurrences(of: ":", with: ";")
            let parsed = normalized.split(separator: ";", omittingEmptySubsequences: false).map { Int($0) ?? 0 }
            return parsed.isEmpty ? [0] : parsed
        }
    }

    private static func extendedColor(codes: [Int], index: inout Int) -> NSColor? {
        guard index + 1 < codes.count else { return nil }
        switch codes[index + 1] {
        case 5:
            guard index + 2 < codes.count else { return nil }
            index += 2
            return xtermColor(codes[index])
        case 2:
            guard index + 4 < codes.count else { return nil }
            let red = clampColorComponent(codes[index + 2])
            let green = clampColorComponent(codes[index + 3])
            let blue = clampColorComponent(codes[index + 4])
            index += 4
            return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1)
        default:
            return nil
        }
    }

    private static func standardColor(index: Int, bright: Bool) -> NSColor {
        let normal: [NSColor] = [
            NSColor(calibratedRed: 0.00, green: 0.00, blue: 0.00, alpha: 1),
            NSColor(calibratedRed: 0.76, green: 0.15, blue: 0.13, alpha: 1),
            NSColor(calibratedRed: 0.12, green: 0.62, blue: 0.22, alpha: 1),
            NSColor(calibratedRed: 0.64, green: 0.51, blue: 0.18, alpha: 1),
            NSColor(calibratedRed: 0.22, green: 0.38, blue: 0.80, alpha: 1),
            NSColor(calibratedRed: 0.64, green: 0.23, blue: 0.68, alpha: 1),
            NSColor(calibratedRed: 0.12, green: 0.58, blue: 0.65, alpha: 1),
            ANSIStyleMapper.foregroundColor
        ]
        let brightColors: [NSColor] = [
            TerminalTheme.mutedForeground,
            NSColor(calibratedRed: 1.00, green: 0.33, blue: 0.29, alpha: 1),
            NSColor(calibratedRed: 0.32, green: 0.86, blue: 0.39, alpha: 1),
            NSColor(calibratedRed: 1.00, green: 0.82, blue: 0.35, alpha: 1),
            NSColor(calibratedRed: 0.39, green: 0.58, blue: 1.00, alpha: 1),
            NSColor(calibratedRed: 0.82, green: 0.46, blue: 1.00, alpha: 1),
            NSColor(calibratedRed: 0.36, green: 0.90, blue: 0.94, alpha: 1),
            NSColor(calibratedWhite: 1.00, alpha: 1)
        ]
        return (bright ? brightColors : normal)[max(0, min(index, 7))]
    }

    private static func xtermColor(_ value: Int) -> NSColor {
        let index = max(0, min(value, 255))
        if index < 16 {
            return standardColor(index: index % 8, bright: index >= 8)
        }
        if index < 232 {
            let color = index - 16
            let red = cubeComponent(color / 36)
            let green = cubeComponent((color / 6) % 6)
            let blue = cubeComponent(color % 6)
            return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1)
        }
        let level = CGFloat(8 + (index - 232) * 10) / 255
        return NSColor(calibratedWhite: level, alpha: 1)
    }

    private static func cubeComponent(_ value: Int) -> CGFloat {
        value == 0 ? 0 : CGFloat(55 + value * 40) / 255
    }

    private static func clampColorComponent(_ value: Int) -> CGFloat {
        CGFloat(max(0, min(value, 255))) / 255
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
