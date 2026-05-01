import Foundation

struct TerminalBuffer {
    private(set) var lines: [String]
    private let maxLineCount: Int

    init(maxLineCount: Int = 10_000) {
        self.maxLineCount = maxLineCount
        self.lines = []
        self.lines.reserveCapacity(min(maxLineCount, 1_024))
    }

    mutating func append(_ text: String) {
        guard !text.isEmpty else { return }
        lines.append(text)
        trimIfNeeded()
    }

    mutating func clear() {
        lines.removeAll(keepingCapacity: true)
    }

    var text: String {
        lines.joined()
    }

    private mutating func trimIfNeeded() {
        guard lines.count > maxLineCount else { return }
        lines.removeFirst(lines.count - maxLineCount)
    }
}
